function [mri_aligned,shape,hdm,mri_segmented]=obob_coregister(cfg)
% CIMEC_COREGISTER spatially aligns an anatomical MRI based on a first
% coarse coregistration (selecting fiducials manually) and a second
% automatic coregistration based on the headshape
%
% Use this function as:
%    mri_aligned=obob_coregister(cfg)
%
% where mri_aligned is the resulting co-registered mri
% or if no individual MRI is available (cfg.mrifile = []) this function
% creates an artifical morphed template MRI out of a subject's headshape.
%
% The configuration has the following options:
%---------------------------------------------
%
%  cfg.mrifile      = string pointing to a mri-file, that can be loaded with ft_read_mri(e.g. '/.../Image0001.dcm';)
%                     or must to be set as empty (cfg.mrifile = []) if there is no mrifile available for this subject.
%  cfg.headshape    = string pointing to a file describing a headshape (i.e *.fif, *.ds), that can be loaded with ft_read_headshape
%
%  cfg.sens         = (optional) string pointing to a file with electrodes positions or grad structure
%                     (if you dont specify this field cfg.elec = cfg.headshape)
%
% Optional inputs:
%------------------
% cfg.skipfiducial: 'yes' or 'no' (default); --> Dont use fiducials for coreg ?
% cfg.skiphs      : 'yes' or 'no' (default); --> Dont use heashape for coreg ?
% cfg.cleanhs     : 'yes' (default) or 'no'; --> Clean headshape before using it ?
% cfg.reslice     : 'yes' (default) or 'no';
% cfg.plotresult  : 'yes' (default) or 'no';
% cfg.viewmode    : 'surface' or 'ortho' (default); (see: ft_volumerealign.m options)
%                   --> viewmode options for MRI visualisation when you select manually fiducials locations
% cfg.cutoff      :  numeric value, points lower than this are removed
%                     from the headshape (default = 0)
%                     (if cfg.cutoff = [] --> no cutoff)
%
% The following is required to
% specify the fiducials coordinates:
%   cfg.fiducial.nas    = [i j k], position of nasion
%   cfg.fiducial.lpa    = [i j k], position of LPA
%   cfg.fiducial.rpa    = [i j k], position of RPA
%   cfg.fiducial.zpoint = [i j k], a point with positive z-axis (optional)
%
% Outputs:
%%%%%%%%%%
% mri_aligned   : mri structure co-registered to MEG space
%                 or final morphed MRI (in case of non individual MRI available)
% shape         : headshape (without outliers)
% hdm           : single shell volume conductor model
% mri_segmented : mriF segmented.
%

% Copyright (c) 2013-2016, Gaetan Sanchez, Nadia Mueller, Marco Fusca,
% Philipp Ruhnau & Thomas Hartmann
%
% This file is part of the obob_ownft distribution, see: https://gitlab.com/obob/obob_ownft/
%
%    obob_ownft is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    obob_ownft is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with obob_ownft. If not, see <http://www.gnu.org/licenses/>.
%
%    Please be aware that we can only offer support to people inside the
%    department of psychophysiology of the university of Salzburg and
%    associates.

%% do some initialization...
ft_defaults;
ft_preamble provenance
ft_preamble trackconfig

ft_checkconfig(cfg,'required',{'mrifile' 'headshape'});

%% set the defaults
mrifile   = ft_getopt(cfg, 'mrifile', '');
headshape = ft_getopt(cfg, 'headshape', '');
header    = ft_getopt(cfg, 'header', headshape);
sens      = ft_getopt(cfg, 'sens', '');

if isempty(sens)
  sens = headshape;
end

skipfid   = ft_getopt(cfg, 'skipfiducial', 'no');
skiphs    = ft_getopt(cfg, 'skiphs', 'no');
reslice   = ft_getopt(cfg, 'reslice', 'yes');
plotresult= ft_getopt(cfg, 'plotresult', 'yes');
cleanhs   = ft_getopt(cfg, 'cleanhs', 'yes');
fiducial  = ft_getopt(cfg, 'fiducial', []);
viewmode  = ft_getopt(cfg, 'viewmode', 'ortho');
cutoff    = ft_getopt(cfg, 'cutoff', 0);
unittest  = ft_getopt(cfg, 'unittest', false);

if isfield(cfg,'fiducial')
  if isfield(cfg.fiducial,'nas') && isfield(cfg.fiducial,'lpa') && isfield(cfg.fiducial,'rpa')
    fiducial = ft_getopt(cfg, 'fiducial', '');
  else
    % fiducials have not yet been specified
    fiducial = [];
    warning('Fiducials Not Specified')
  end
end

if ~isempty(fiducial) || strcmp(skipfid, 'yes'),
  warning('Skipping Fiducial Coregistration');
end

if strcmp(cleanhs, 'no'),
  warning('Skipping headshape cleaning');
end

% Get electrode position
%------------------------
if ischar(sens)
  try
    grad = ft_read_sens(sens); % usual way to get sensor position
  catch
    hdr  = ft_read_header(sens); % CTF work around to get sensor position
    grad = hdr.grad;
  end
else
  grad = sens; % when sens is a structure and not a file
end

grad = ft_convert_units(grad, 'mm'); % convert to mm

% load headshape
%-----------------
if ischar(headshape)
  shape = ft_read_headshape(headshape);
elseif isstruct(headshape)
  shape = headshape;
  if isempty(mrifile)
    error(['When you coregister without individual MRI', ...
      'you need to use as input for cfg.headshape the full path of the raw data (*.fif)']);
  end
end
shape = ft_convert_units(shape, 'mm');% make mm

% remove fiducials from the headshape if we want to skip using them
% anyhow..
if strcmp(skipfid, 'yes') && isfield(shape, 'fid')
  shape = rmfield(shape, 'fid');
end %if

if isempty(mrifile)
  %% Coregister WITHOUT individual MRI
  %-----------------------------------
  
  % Remove bad heashape points
  %----------------------------
  [shape] = clean_headshape(shape,cutoff,strcmpi(cleanhs,'yes'));
  
  %------------------------------------------------------
  % Perform interactive coregistration with template MRI
  %-------------------------------------------------------
  
%   % find current obob_init_ft path
%   %---------------------------------
%   basefolder = which('obob_init_ft.m');
%   basepath   = fileparts(basefolder);
%   
%   % Set SPM12 paths
%   %---------------
%   foldernameSPM = 'spm12_for_coreg';
%   addpath([basepath '/external/' foldernameSPM]);
%   addpath([basepath '/external/' foldernameSPM '/matlabbatch']);
  
  
  try
    
    % Convert to SPM
    %----------------
    S = [];
    S.dataset = header;
    S.mode = 'header';
    D = spm_eeg_convert(S);
    
    % set clean headshape
    %--------------------
    shape = ft_convert_units(shape, 'mm');
    if strcmp(skipfid, 'no')
      D = fiducials(D,shape);
    end %if
    
    % interactive SPM graphics
    %--------------------------
    val = 1;
    D.inv{val}.mesh = spm_eeg_inv_mesh([],3); % template mesh fine
    
    spm_figure('Create','Graphics','Graphics','on');
    ok_coreg = 0;
    while ok_coreg == 0
      % set fiducials and do automatic spm morphing of headshape and MNI
      % space to calculate transformation matrix
      if unittest
        [D_new, val] = spm_eeg_inv_check(D);
        meegfid = D_new.fiducials;
        mrifid = D_new.inv{val}.mesh.fid;
        old_pnt = mrifid.fid.pnt;
        mrifid.fid.pnt(1, :) = old_pnt(2, :);
        mrifid.fid.pnt(2, :) = old_pnt(1, :);
        mrifid.fid.label = {'LPA', 'Nasion', 'RPA'}; 
        Dtmp = spm_eeg_inv_datareg_ui(D_new, val, meegfid, mrifid, true);
      else
        Dtmp = spm_eeg_inv_datareg_ui(D);
      end%if
      if unittest
        ok_coreg = 1;
        D = Dtmp;
      else
        switch spm_input('Are you satisfied with this coregistration ?' , 1, 'YES|NO')
          case 'YES'
            ok_coreg = 1;
            D = Dtmp;
          case 'NO'
            ok_coreg = 0;
            clear Dtmp;
        end
      end %if
    end
    
    Atinv = D.inv{val}.datareg(end).fromMNI*D.inv{val}.mesh.Affine;% calculate final TRANSFORMATION MATRIX
    
    % clean
    %-------
%     rmpath([basepath '/external/' foldernameSPM]);
%     rmpath([basepath '/external/' foldernameSPM '/matlabbatch']);
    close all;
    
  catch er
    
    % clean anyway !
    %---------------
%     rmpath([basepath '/external/' foldernameSPM]);
%     rmpath([basepath '/external/' foldernameSPM '/matlabbatch']);
    close all;
    rethrow(er);
  end
  
  
  % output warped MRI
  %-------------------
  mri = ft_read_mri('single_subj_T1.nii');
  mri_aligned = mri;
  mri_aligned.transform = Atinv*mri.transform;
  
else
  %% Coregister WITH individual MRI
  %----------------------------------
  
  % load mri
  if ischar(mrifile)
    mri = ft_read_mri(cfg.mrifile);
  elseif isstruct(mrifile)
    mri = mrifile;
  end
  
  % convert mri to 'mm' otherwise reslicing fails with some formats
  mri = ft_convert_units(mri, 'mm');
  
  % flip mri so that up is up
  if strcmpi(reslice, 'yes')
    mri = ft_volumereslice([], mri);
  end
  
  % coarse coregistration based on fiducials
  if strcmpi(skipfid, 'no')
    
    
    if isfield(fiducial,'nas') && isfield(fiducial,'lpa') && isfield(fiducial,'rpa')
      
      cfg = [];
      cfg.option = 'fids';
      cfg.type   = 'auto';
      [mri_aligned1] = do_coreg(cfg,mri,shape,fiducial);
      
    else
      cfg = [];
      cfg.option   = 'fids';
      cfg.type     = 'manual';
      cfg.viewmode = viewmode;
      [mri_aligned1] = do_coreg(cfg,mri,shape,fiducial);
      
    end
    
    % track fiducial position
    %-------------------------
    fiducial = fiducial_coord(mri_aligned1);
    %--------------------------------
    
  else
    mri_aligned1    = mri;
  end
  
  
  % precise coregistration based on headshape
  if strcmpi(skiphs,'no')
    
    % Clean headshape
    [shape] = clean_headshape(shape,cutoff,strcmpi(cleanhs,'yes'));
    
    % make automatic coregistration based on headshape
    cfg = [];
    cfg.option = 'head';
    cfg.type   = 'auto';
    [mri_aligned2] = do_coreg(cfg,mri_aligned1,shape,fiducial);
    
  else
    mri_aligned2   = mri_aligned1;
  end
  
  if strcmpi(plotresult,'no') % output results without plotting
    mri_aligned = mri_aligned2;
    warning(['plotresult = ''no'' but it''s better to check visually your coregistration results !!']);
    
  elseif strcmpi(plotresult,'yes')
    
    % Interactive figure
    %---------------------
    ok_coreg = 0;
    while ok_coreg == 0
      
      % plot segmented MRI (skin)
      %-------------------------
      cfg        = [];
      cfg.output = 'scalp';
      cfg.smooth = 3;
      seg_align  = ft_volumesegment(cfg, mri_aligned2);
      
      cfg             = [];
      cfg.method      = 'singleshell';
      cfg.numvertices = 20000;
      scalp           = ft_prepare_headmodel(cfg, seg_align);
      scalp           = ft_convert_units(scalp, 'mm');
      
      lastfigure = figure;
      
      % plot MRI face + headshape
      %---------------------------
      ft_plot_vol(scalp,'facealpha',0.5,...
        'facecolor','k',...
        'vertexcolor','none',...
        'edgecolor','none');
      
      ft_plot_headshape(shape,'vertexsize',10)
      
      % plot fiducials
      %----------------
      fidlab = {'nasnew','lpanew','rpanew'};
      for npfid = 1:3
        hold on
        ncoordfid = fiducial.(fidlab{npfid});
        plot3(ncoordfid(1),ncoordfid(2),ncoordfid(3),'o',...
          'MarkerFaceColor','c',...
          'MarkerSize',10,'MarkerEdgeColor','k');
      end
      
      % plot sensors
      %-------------
      hold on
      grad = ft_convert_units(grad, 'mm'); % convert to mm
      plot3(grad.chanpos(:,1),grad.chanpos(:,2),grad.chanpos(:,3),'o',...
        'MarkerFaceColor','g',...
        'MarkerSize', 12,'MarkerEdgeColor','k');
      view(100,10);% right side view
      hold off
      
      %-------------------
      % Interactive QUEST
      %-------------------
      
      % set Callback variables
      %-----------------------
      handles.fig = figure;
      
      uicontrol('Parent',handles.fig,'style','text',...
        'units','normalized','Position',[0.1 0.9 0.8 0.05],...
        'fontsize' , 15,'fontweight','bold',...
        'string','Are you satisfied with this coregistration ?');
      
      ac = {'YES';'NO'};
      pos = {[0.2 0.5 0.2 0.2];[0.6 0.5 0.2 0.2]};
      for bp = 1:length(ac)
        handles.op = ac{bp};
        uicontrol('Parent',handles.fig,'Style','Pushbutton','units','normalized',...
          'Position',pos{bp},...
          'String',ac{bp},...
          'fontsize' , 15,...
          'callback',{@callbackbox,handles}) ;
      end
      %--------------------
      uiwait(handles.fig); % Wait user's response (button press) until uiresume in subfunction callbackbox
      
      
      % Get QUEST box response
      %------------------------
      try
        QUEST = guidata(handles.fig); % Get data of button press
      catch
        QUEST = 'nothing'; % in case handles.fig was closed before
      end
      
      try
        close(handles.fig); % Close figure afterwards
      catch
      end
      %-----------------------
      
      switch QUEST
        
        case 'nothing'
          ok_coreg = 0;
          mri_aligned = mri_aligned2;
          
        case 'YES'
          
          ok_coreg = 1;
          mri_aligned = mri_aligned2;
          
        case 'NO'
          
          % Set Callback variables + interactive box
          %-----------------------------------------
          handles.fig = figure;
          
          ac = {'Headclean'       'Restart to clean the heashape';...
            'Headinteractive' 'Realign the headshape manually';...
            'Headicp'         'Realign the headshape automatically';...
            'Fids'            'Coregister using fiducials only';...
            'Fidinteractive'  'Redefine fiducials position';...
            'Restart'         'Restart before automatic headshape coregistration';...
            'Quit'            'Quit and keep this coregistration...'};
          
          uicontrol(handles.fig,'style','text',...
            'units','normalized','Position',[0.1 0.9 0.8 0.05],...
            'fontsize' , 20,'fontweight','bold',...
            'string','What do you want to do ?');
          for bp = 1:length(ac)
            handles.op = ac{bp,1};
            uicontrol(handles.fig,'Style','Pushbutton','units','normalized','fontsize' , 15,...
              'Position',[0.1 0.85-(bp*0.1) 0.8 0.05],...
              'String',ac{bp,2},...
              'callback',{@callbackbox,handles});
            
          end
          %-------------------------
          uiwait(handles.fig);% Wait user's response (button press) until uiresume in subfunction callbackbox
          
          % Get QUEST box response
          %------------------------
          try
            OP = guidata(handles.fig);% Get data of button press
          catch
            OP = 'nothing';% in case handles.fig was closed before
          end
          
          try
            close(handles.fig);% Close figure afterwards
          catch
          end
          %-----------------------
          
          
          switch OP
            
            case 'nothing'
              ok_coreg = 0;
              mri_aligned = mri_aligned2;
              
            case 'Headclean'
              
              % Clean headshape another time
              [shape] = clean_headshape(shape,cutoff,1);
              
              % Then run another automatic coregistration based on the new-headshape
              cfg = [];
              cfg.option = 'head';
              cfg.type   = 'auto';
              [mri_aligned2] = do_coreg(cfg,mri_aligned2,shape,fiducial);
              
            case 'Headinteractive'
              
              cfg = [];
              cfg.option = 'head';
              cfg.type   = 'manual';
              [mri_aligned2] = do_coreg(cfg,mri_aligned2,shape,fiducial);
              
            case 'Headicp'
              
              cfg = [];
              cfg.option = 'head';
              cfg.type   = 'auto';
              [mri_aligned2] = do_coreg(cfg,mri_aligned2,shape,fiducial);
              
            case 'Fids'
              
              cfg = [];
              cfg.option = 'fids';
              cfg.type   = 'auto';
              [mri_aligned2] = do_coreg(cfg,mri_aligned2,shape,fiducial);
              
            case 'Fidinteractive'
              
              cfg = [];
              cfg.option = 'fids';
              cfg.type   = 'manual';
              cfg.viewmode = viewmode;
              [mri_aligned2] = do_coreg(cfg,mri_aligned2,shape,fiducial);
              
              % track fid coord
              %----------------
              fiducial = fiducial_coord(mri_aligned2);
              %---------------
              
            case 'Restart'
              
              close(lastfigure)
              mri_aligned2   = mri_aligned1; %restart
              
            case 'Quit'
              
              close(lastfigure)
              mri_aligned   = mri_aligned2; % quit as it is
              ok_coreg = 1;
          end
          
          close all;
      end
      
    end
    
  else
  end
  
end

%% Outputs
%-----------
% add coordsys
if ~isfield(shape, 'coordsys')
  mri_aligned.coordsys = 'ctf';
else
  mri_aligned.coordsys = shape.coordsys; % 'neuromag' or 'ctf'
end %if

% Segment
%--------
cfg            = [];
[mri_segmented] = ft_volumesegment(cfg, mri_aligned);

% Prepare headmodel
%-------------------
cfg = [];
cfg.method = 'singleshell';
hdm = ft_prepare_headmodel(cfg,mri_segmented);

%% Final Brain plot
%-------------------
if strcmpi(plotresult,'yes')
  
  % convert to mm (sensors and headshape) for plotting
  grad = ft_convert_units(grad, 'mm');
  shape = ft_convert_units(shape, 'mm');
  
  % plot
  figure;
  ft_plot_vol(hdm);
  
  if isempty(mrifile)
    cfg        = [];
    cfg.output = 'scalp';
    cfg.smooth = 2;
    seg_align  = ft_volumesegment(cfg, mri_aligned);
    
    cfg             = [];
    cfg.method      = 'singleshell';
    cfg.numvertices = 20000;
    scalp           = ft_prepare_headmodel(cfg, seg_align);
    scalp           = ft_convert_units(scalp, 'mm');
    
  end
  
  ft_plot_vol(scalp,'facealpha',0.5,...
    'facecolor','k',...
    'vertexcolor','none',...
    'edgecolor','none');
  
  ft_plot_headshape(shape);
  hold on
  if strcmp(skipfid, 'no')
    plot3(shape.fid.pos(:,1),shape.fid.pos(:,2),shape.fid.pos(:,3),'o',...
      'MarkerFaceColor','c',...
      'MarkerSize',10,'MarkerEdgeColor','k');
  end %if
  
  plot3(grad.chanpos(:,1),grad.chanpos(:,2),grad.chanpos(:,3),'o',...
    'MarkerFaceColor','g',...
    'MarkerSize', 12,'MarkerEdgeColor','k');
  view(100,10);% right side view
  hold off
  
end %if



end

%%%%%%%%%%%%%%%%%
%% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%

function [fiducial] = fiducial_coord(mri_realign)

% track fiducial position (gs)
%------------------------------
fiducial = mri_realign.cfg.fiducial;

fidlabel = fieldnames(fiducial);
for nfid = 1:numel(fidlabel)
  fid_head = ft_warp_apply(mri_realign.transform, fiducial.(fidlabel{nfid}));
  fiducial.(strcat(fidlabel{nfid},'new')) = fid_head;
end
end


function callbackbox(hObject,callbackdata,handles)

if ischar(handles.op)
  
  % save option choice variable
  %---------------------
  data = guidata(hObject);
  data = handles.op;
  guidata(hObject,data);
else
  error('input of this callback function must be a character array !');
end

uiresume(handles.fig); % Stop waiting for the user's response

end
