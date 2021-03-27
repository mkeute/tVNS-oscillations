function vislock = get_visual_timelock(event, datall, hdr)

        trl = [];
         arrows = find([event.value] == 103);
         prestim = 500;
         poststim = 2000;
         for a = 1:length(arrows)
            trl(a,1) = event(arrows(a)).sample - prestim;
             trl(a,2) = event(arrows(a)).sample + poststim;
             trl(a,3) = -prestim;
             trl(a,4) = event(arrows(a)).value;
         end

          trl(:,1:3) = round(trl(:,1:3) * (300/1000)); %account for downsampling
         %%
     %cut data into movement trls


         tcfg = []
         tcfg.trl = trl;
         visdat = ft_redefinetrial(tcfg, datall, hdr);

        cfg                   = [];
        cfg.covariance        = 'yes';
        cfg.channel           = 'MEG';
        cfg.vartrllength      = 2;
        cfg.covariancewindow  = 'all';
        cfg.keeptrials        = 'yes';
        vislock               = ft_timelockanalysis(cfg, visdat);
