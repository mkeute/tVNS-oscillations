function success = pipeline_headmodels(subjs,exdir)

success = 0;
restingspectra = struct;
restingspectra.Stim = [];
restingspectra.StimBL = [];

restingspectra.Sham = [];
restingspectra.ShamBL = [];
%% read in fif files, filter, downsample, and save to .mat
n=1;
for s = 1:length(subjs)
    cd([exdir filesep subjs{s}])
    datasets = dir('*.fif');
    datasets = {datasets(:).name};


    

    %%process motor
    for f = 1:length(datasets)
% source analysis (only for task-related data)
%        alternative obob version
%        to run this you need SPM12 tho! - the version that comes with
%        fieldtrip is not enough, somwhat low on functions 



       fname = datasets{f};
       tmp = strsplit(fname, '.');
       

        if exist([tmp{1} '_individual_models.mat'])
            continue
        end
    


    %% read individual MRI if exists
    %PR: so when there is no individual source model we will read in a
    %standard bem AND the individual MRI? i would rather add a condition
    %where there is an individual mri and then no standard model is needed
    % also, I can't find anything about building a indiv MRI based scull to
    % align the headshape with.
    % in general your way makes sense for the case where we have no mri
        mridir = dir('*anatomical');

        %if individual MRI data exists, but no sourcemodel has been generated:
        if length(mridir) > 0
            
            cd(mridir(1).name)
            mrifiles = dir;

           cfg = [];
           cfg.mrifile = mrifiles(3).name; % if you leave this empty the function morphs a template brain into the headshape
           
           
           
           
        else
           cfg = [];
           cfg.mrifile = []; % if you leave this empty the function morphs a template brain into the headshape
           
        end
        
        
        
           cfg.headshape = fname;  
           [mri_aligned, shape, individual_hdm, mri_segmented] = obob_coregister(cfg);


       
       
       
%             template = ft_read_headmodel('standard_bem.mat');
%             template = ft_convert_units(template, 'mm');
%             cd(mridir(1).name)
%             mrifiles = dir;
%             mri = ft_read_mri(mrifiles(3).name); %Image Processing Toolbox needs to be installed for this function to work
%             [~, sourcemodel] = ana_process_MRI(mri);

            %            hdm = ft_convert_units(hdm, 'mm');
            %              save idividual_hdm hdm %headmodel will be obtained from
            %              headshape
            %PR: something missing here??? no save process? maybe a few lines
            %gone?

            % PR: no variable individual_sourcemodel
%     else
            [~, individual_sourcemodel] = ana_process_MRI({mri_segmented,mri_aligned});
            
            individual_hdm = ft_convert_units(ft_convert_coordsys(individual_hdm, 'acpc'),'mm');
            individual_sourcemodel = ft_convert_units(ft_convert_coordsys(individual_sourcemodel, 'acpc'),'mm');
%         end
               % i guess now you can save
            cd([exdir filesep subjs{s}])

           save([tmp{1} '_individual_models.mat'], 'individual_hdm', 'individual_sourcemodel')
            close all
        
    end
end
    %% PR:
    % >>for the template data u might also want to have a look at the obob
    % toolbox as it comes with a co-registration function obob_coregister 
    % that (if no indiv mri is present) morphes a standard MRI such that it 
    % fits into the MEG headshape (also using some affine transform i 
    % think) works usually quite nicely. however, there is nothing wrong 
    % with the ft version u adapeted from teh web...but maybe not manually.
    % in sum: stick with it if you like it. in the end it only needs to be 
    % done once per participant and measurement (not sure actually about 
    % the latter). <<
    % 
    % MRI-MEG realignment (first MRI-fiducials then headshape)
    % % coarse realignment based on fiducials 
    % cfg=[];
    % cfg.method      = 'interactive';
    % cfg.coordsys    = 'neuromag';
    % mri_aligned1    = ft_volumerealign(cfg,mri);
    %
    % % make automatic coregistration based on headshape
    % cfg=[];
    % cfg.method                = 'headshape';
    % cfg.headshape             = shape; % get this with   shape = ft_read_headshape(orig); 
    % cfg.headshape.icp         = 'yes'; % some options
    % cfg.headshape.interactive = 'yes';
    % cfg.coordsys              = 'neuromag';
    %
    % mri_aligned   = ft_volumerealign(cfg, mri_aligned1);
    % %% make headmodel for individual brain, cortex, using defaults
    % % segment 
    % seg_align = ft_volumesegment([], mri_aligned);
    %
    % % single shell
    % cfg = [];
    % cfg.method = 'singleshell';
    % hdm = ft_prepare_headmodel(cfg, seg_align);
    %

    %%
    % create individual headmodel from headshape
%     template = ft_read_headmodel('standard_bem.mat');
%     template = ft_convert_units(template, 'mm');
    
%     orig = strsplit(matfiles{m}, '.'); % PR: matfiles defined elsewhere? actually i found it below..hmm
%     orig = [orig{1} '.fif'];
%     shape = ft_read_headshape(orig); % very confusing that you are using headmodel abbrev for headshape..so i just went for shape
%     shape = ft_convert_units(shape, 'mm');
%     cfg = [];
%     cfg.template.headshape      = shape;
%     cfg.checksize               = inf;
%     cfg.individual.headmodel    = template;
%     cfg                         = ft_interactiverealign(cfg);
%     template                    = ft_transform_geometry(cfg.m, template);
%     
%     cfg             = [];
%     cfg.method      = 'singlesphere';
%     sphere_template = ft_prepare_headmodel(cfg, template.bnd(1));
%     
%     cfg              = [];
%     cfg.method      = 'singlesphere';
%     sphere_shape = ft_prepare_headmodel(cfg, shape); % again using hdm for headshape is really confusing me
% 
%     cd([exdir filesep 'data' filesep subjs{s}])
%     save individual_hdm shape % and where is the individual hdm? 
%     
    % i'm assuming u looked here: http://www.fieldtriptoolbox.org/example/fittemplate/
%     
%    % PR: but it seems to me a number of steps are missing, this below is 
%    % from there - although i would like the affine transform more
%    
%    scale = sphere_shape.r/sphere_template.r;
%    
%    T1 = [1 0 0 -sphere_template.o(1);
%      0 1 0 -sphere_template.o(2);
%      0 0 1 -sphere_template.o(3);
%      0 0 0 1                ];
%    
%    S  = [scale 0 0 0;
%      0 scale 0 0;
%      0 0 scale 0;
%      0 0 0 1 ];
%    
%    T2 = [1 0 0 sphere_shape.o(1);
%      0 1 0 sphere_shape.o(2);
%      0 0 1 sphere_shape.o(3);
%      0 0 0 1                 ];
%    
%    
%    transformation = T2*S*T1;
%    
%    template_fit_sphere = ft_transform_geometry(transformation, template);
% 
%    % check
%    figure
%    ft_plot_headmodel(template_fit_sphere) % this is the aligned head model
%    ft_plot_headshape(shape)
%   
%    % create spherical model
%    cfg              = [];
%    cfg.conductivity = [0.33 0.0042 0.33];
%    % couldn't install this properly so I'm going back to my recommendation
%    % from above just use the obob_coregister... see below
%    cfg.method       = 'openmeeg'; 
%    headmodel_sphere = ft_prepare_headmodel(cfg, template_fit_sphere.bnd);
%    
%    figure;
%    ft_plot_mesh(headmodel_sphere.bnd(1))
%    ft_plot_mesh(shape)
%    % now you can save... 
%    
% 
%    
%  end
% 
% 
% 
% 
% 
% 
% 
% %% read in pre-processed files, do all further analyses
% cd(exdir)
% cd data
% 
% subjs = dir;
% subjs = {subjs(:).name};
% subjs(strcmp(subjs, '.') | strcmp(subjs, '..')| strcmp(subjs, '.DS_Store')) = [] % .DS_Store- mac file...
% 
% 
% 
% for s = 1:length(subjs)
%     cd([exdir filesep 'data' filesep subjs{s}])
%     matfiles = dir('vagusmeg*.mat')
%     matfiles = {matfiles(:).name};
%     for m = 1:length(matfiles)
%         clear datall event hdr hdm sourcemodel
%         
% %% get files
%         load(matfiles{m})
%         load([cd filesep 'individual_hdm.mat'])
%         if exist([cd filesep 'individual_sourcemodel.mat'])
%                 load([cd filesep 'individual_sourcemodel.mat']) % where is this coming from?????
%         else
%                 load sourcemodel % or this???
%         end
%         
%         
% 
% 
%         
% 
% 
% %% motor task - find trials and timelock, calculate TFR
%         outfile = [matfiles{m} '_movlock_sens_clean.mat']
%         if ~exist(outfile)
%             hdr.Fs = 300; %adjust to downsampled freq.
%             hdr.nSamples = length(datall.trial{1});
% 
%             movlock = get_motor_timelock(event, datall, hdr)
%             movlock = clean_timelock(movlock)
%             save(outfile, 'movlock')
%         else
%             load(outfile)
%         end
%         
%         
%         
% 
% %% LCMV time-domain source localization
%         cfg              = [];
%         cfg.method       = 'lcmv';
%         cfg.headmodel    = individual_hdm; % here you actually need the headmodel. hmm
%         cfg.sourcemodel.pos  = [-4.8, -0.8,5.0;5.2, 0.4, 5.4]; %MNI coordinates of left and right motor cortex, according to http://www.ajnr.org/content/ajnr/suppl/2011/02/07/ajnr.A2330.DC1/2330_materials.pdf
%         cfg.sourcemodel.inside  = true(2,1);
% %         cfg.unit    = sourcemodel.unit; % since i didn't use the  sourcemodel I just removed this
%         cfg.lcmv.keepfilter = 'yes';
%         cfg.keepleadfield = 'yes'; % don't really need this
%         % PR: you can have it easier
%         cfg.lcmv.fixedori   = 'yes'; % using this you don't need to use the euclidian norm below
%         source_idx       = ft_sourceanalysis(cfg, movlock);
% 
%        
%         
%         M1left = source_idx.avg.filter{1};
%         M1right = source_idx.avg.filter{2};
%         chansel = ft_channelselection('MEG', movlock.label);
%         chansel = match_str(movlock.label, chansel);
%         
%         movsource = movlock;
%         movsource.label = {'M1left', 'M1right'};
% %         movsource.time = movlock.time;
%         movsource.trial = [];ŝ
%         for t = 1:size(movlock.trial,1)
% %             movsource.trial(t,1,:) = sqrt(sum((M1left * squeeze(movlock.trial(t,chansel,:))).^2,1)); %get euclidian norm of 3D dipole vector
% %             movsource.trial(t,2,:) = sqrt(sum((M1left * squeeze(movlock.trial(t,chansel,:))).^2,1));
% %             movsource.trial(t,1,:) = M1left * squeeze(movlock.trial(t,chansel,:)); %get euclidian norm of 3D dipole vector
% %              %PR:btw you multiply with the same filter in your code above (both times left m1
% %             movsource.trial(t,2,:) = M1right * squeeze(movlock.trial(t,chansel,:)); 
%             
%             % also this is even a one-liner, you can apply the filter for
%             % all sources to the data at the same time (since each filter
%             % is in a separate line - matrix multiplication whohoo)
%             movsource.trial(t,:,:) = [M1left; M1right] * squeeze(movlock.trial(t,chansel,:));
%             
%         end
%         
%         
%         frq = get_movfreq(movsource,0,0) %run wavelet convolution on source-level data
%         frq = subtract_baseline(frq, [1 1.75])
%         plot(frq.time, squeeze(mean(mean(mean(frq.powspctrm,3),1),2)))
% 
% 
% 
% 
% 
% 
%     end
% end
% 

