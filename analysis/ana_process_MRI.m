function [hdm, sourcemodel] = ana_process_MRI(mri)  

        if iscell(mri)
        segmentedmri = mri{1};
        mri = mri{2};

        else
        cfg          = [];
        segmentedmri = ft_volumesegment(cfg, mri);
        end
        % add anatomical information to the segmentation
        segmentedmri.transform = mri.transform;
        segmentedmri.anatomy   = mri.anatomy;

%         cfg              = [];
%         cfg.funparameter = 'gray';
%         ft_sourceplot(cfg, segmentedmri);

        cfg        = [];
        cfg.method = 'singleshell';
        hdm        = ft_prepare_headmodel(cfg, segmentedmri);
        hdm = ft_convert_units(hdm, 'mm');


        template = load('standard_sourcemodel3d8mm'); % 8mm spacing grid
        template.sourcemodel = ft_convert_units(template.sourcemodel, 'mm');

        % inverse-warp the template grid to subject specific coordinates
        cfg                = [];
        cfg.warpmni   = 'yes';
        cfg.template  = template.sourcemodel;
        cfg.nonlinear = 'yes'; % use non-linear normalization
        cfg.mri            = segmentedmri;
        cfg.unit = 'mm';
        sourcemodel        = ft_prepare_sourcemodel(cfg);
