function [mri_out] = do_coreg(cfg,mri,shape,fiducial)
% Do coregistration with individual MRI
%
% cfg.option   : 'fids' or 'head' (default);
% cfg.type     : 'manual' or 'auto' (default);
% cfg.viewmode : 'surface' or 'ortho' (default); (see: ft_volumerealign.m options)

%% set the defaults
wtd  = ft_getopt(cfg, 'option', 'head'); % what to do 
htd  = ft_getopt(cfg, 'type', 'auto'); % how to do
viewmode  = ft_getopt(cfg, 'viewmode', 'ortho');


%% 
switch wtd
  case 'head'
    
    cfg=[];
    cfg.method    = 'headshape';
    cfg.headshape.headshape = shape;
    cfg.coordsys  = shape.coordsys;
    
    switch htd
      case 'auto'
        cfg.headshape.interactive    = 'no';
        cfg.headshape.icp    = 'yes';
      case 'manual'
        cfg.headshape.interactive    = 'yes';
        cfg.headshape.icp    = 'no';
    end
    
    mri_out  = ft_volumerealign(cfg,mri);
    
    
  case 'fids'
    
    switch htd
      
      case 'auto'
        
        cfg=[];
        cfg.method = 'fiducial';
        cfg.coordsys    = shape.coordsys;
        if isfield(fiducial,'nas') && isfield(fiducial,'lpa') && isfield(fiducial,'rpa') %if no fiducials present then this is not the right option
          cfg.fiducial.nas    = fiducial.nas; % position of nasion
          cfg.fiducial.lpa    = fiducial.lpa; % position of LPA
          cfg.fiducial.rpa    = fiducial.rpa; % position of RPA
          if isfield(fiducial,'zpoint'),cfg.fiducial.zpoint= fiducial.zpoint;end %a point with positive z-axis (optional)
          
          mri_out    = ft_volumerealign(cfg,mri);
          
        else
          warning('Fiducials not specified, select another option')
          
        end
        
      case 'manual'
        
        cfg=[];
        cfg.method      = 'interactive';
        cfg.coordsys    = shape.coordsys;
        cfg.viewmode    = viewmode;
        mri_out    = ft_volumerealign(cfg,mri);
        
    end
    
end