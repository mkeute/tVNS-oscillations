function [sensspectra_lefthand,sensspectra_righthand, sourcespectra_lefthand, sourcespectra_righthand] = pipeline_motor(subjs, exdir)
subjinfo = readtable('/mnt/data/Studies/tVNS_regrep/StimPlan.xlsx');

success = 0;
% restingspectra = struct;
% restingspectra.Stim = [];
% restingspectra.StimBL = [];
% 
% restingspectra.Sham = [];
% restingspectra.ShamBL = [];
%% read in fif files, filter, downsample, and save to .mat
n=0;
sourcespectra_lefthand = struct;
sensspectra_lefthand = struct;
sourcespectra_righthand = struct;
sensspectra_righthand = struct;
lhtopo = struct;
lhtopo.Stim={};
lhtopo.Sham={};
rhtopo = struct;
rhtopo.Stim={};
rhtopo.Sham={}
for s = 1:length(subjs)
    n=n+1;
    cd([exdir filesep subjs{s}])
    datasets = dir('*.fif');
    datasets = {datasets(:).name};


    

    %%process motor
    for f = 1:length(datasets)


        fname        =  datasets{f};
        if contains(fname, '-1')
            continue
        end
        tmp = strsplit(datasets{f}, '.');
        if ~exist([tmp{1} '_individual_models.mat'])
            continue
        end
        recdate = strsplit(tmp{1},'_');
        recdate = strsplit(recdate{end},'-1');
        recording_date = datetime(str2num(recdate{1}),'ConvertFrom','yyyymmdd');

        recinfo = subjinfo(contains(subjinfo.Var1, subjs{s}),:);
        if recinfo.Var3 == recording_date
            current_cond = recinfo.Var2{1};
        elseif recinfo.Var5 == recording_date
            current_cond = recinfo.Var4{1};
        else
            error('recording date not found')
        end
        if ~exist([tmp{1} '_motor_spectra.mat'], 'file')
            if ~exist([tmp{1} '_motordat_sens.mat'], 'file')
                
                motordat = ana_read_motor(fname)
                if ~isstruct(motordat)
                    continue
                end
                
                
                %         if ~exist([tmp{1} '_resting_ica_unmixing.mat'])
%                 if ~exist([tmp{1} '_motordat.mat'])
                    clear comp rejcfg
                    load([tmp{1} '_resting_ica_unmixing.mat']);
                    
                    scfg = [];
                    scfg.channel =  comp.topolabel;
                    motordat = ft_selectdata(scfg, motordat);
                    comp.trial = {};
                    comp.time = motordat.time;
                    comp.sampleinfo = motordat.sampleinfo;
                    comp.trialinfo = motordat.trialinfo;
                    for t = 1:length(motordat.trial)
                        c = comp.unmixing*motordat.trial{:,t};
                        c = c-mean(c,2);
                        comp.trial{t} = c;
                    end
%                 end
                
                %
                %             cfg = [];
                %             cfg.component = 1:20;       % specify the component(s) that should be plotted
                %             cfg.layout    = 'neuromag306mag.lay'; % specify the layout file that should be used for plotting
                %             cfg.comment   = 'no';
                %             cfg.allowoverlap = 'yes'
                % %                 ft_topoplotIC(cfg, comp)
                %             ft_databrowser(cfg, comp)
                %             rejcfg = [];
                %             rejcfg.component = str2num(input('tbrej?','s')); % to be removed component(s)
                motor_clean = ft_rejectcomponent(rejcfg, comp, motordat);
                close all;
                
                
                motor_clean = ft_rejectvisual([],motor_clean);
                save([tmp{1} '_motordat_sens.mat'], 'motor_clean');
                
                %% TODO do source analysis
                %% TODO do freq analysis, baseline correct
                
            else
                
                load([tmp{1} '_motordat_sens.mat']); %returns resting_clean and resting_spectrum
                
            end
            
            
            % continue from here
            % do sourve analysis separately for left and right hand
            
            
            load([tmp{1} '_individual_models.mat']); %returns resting_clean and resting_spectrum
            %         if ~strcmp(individual_hdm.bnd.coordsys, 'acpc')
            %           individual_hdm = ft_convert_units(ft_convert_coordsys(individual_hdm, 'acpc'),'mm');
            %           close all;
            %           save([tmp{1} '_individual_models.mat'], 'individual_hdm', 'individual_sourcemodel');
            %         end
            if ~strcmp(individual_sourcemodel.coordsys, 'acpc')
                individual_sourcemodel = ft_convert_units(ft_convert_coordsys(individual_sourcemodel, 'acpc'),'mm');
                close all;
                save([tmp{1} '_individual_models.mat'], 'individual_hdm', 'individual_sourcemodel');
                
            end
            
            
            cfg              = [];
            cfg.method       = 'lcmv';
            cfg.headmodel    = individual_hdm; % here you actually need the headmodel. hmm
            cfg.sourcemodel  = individual_sourcemodel;
            cfg.sourcemodel.pos  = [-48, -8,50; 48, -8,50];
            %          cfg.sourcemodel.pos  = [-48, -8,50; 52, -4, 54]; %MNI coordinates of left and right motor cortex, according to http://www.ajnr.org/content/ajnr/suppl/2011/02/07/ajnr.A2330.DC1/2330_materials.pdf
            cfg.sourcemodel.inside  = true(2,1);
            cfg.unit    = 'mm'; % since i didn't use the  sourcemodel I just removed this
            cfg.lcmv.keepfilter = 'yes';
            cfg.keeptrials = 'yes'; % don't really need this
            % PR: you can have it easier
            cfg.lcmv.fixedori   = 'yes'; % using this you don't need to use the euclidian norm below
            source_idx       = ft_sourceanalysis(cfg, motor_clean);
            
            
            %         ft_plot_headmodel(individual_hdm)
            %         cfg =[]
            %         cfg.location = [48, -8,50]
            %         cfg.funparameter = 'pow';
            %         ft_sourceplot(cfg, source_idx)
            
            %% try sourceplot to see where we end up with these coords?
            
            M1left = source_idx.avg.filter{1};
            M1right = source_idx.avg.filter{2};
            chansel = ft_channelselection('MEG', motor_clean.label);
            chansel = match_str(motor_clean.label, chansel);
            
            movsource = motor_clean;
            movsource.label = {'M1left', 'M1right'};
            %         movsource.time = movlock.time;
            movsource.trial = {};
            for t = 1:length(motor_clean.trial)
                movsource.trial{t} = [M1left; M1right] * squeeze(motor_clean.trial{t}(chansel,:));
                
            end
            
            
            
            cfg = [];
            cfg.method = 'wavelet';
            cfg.output = 'pow';
            cfg.keeptrials = 'yes';
            cfg.pad = 'nextpow2';
            cfg.toi = -2:.05:2;
            cfg.foi = 2.^(log2(15):.125:log2(30));
            cfg.gwidth = 6;
            motor_spectrum_source = ft_freqanalysis(cfg, movsource);
            motor_spectrum_sens = ft_freqanalysis(cfg, motor_clean);
            save([tmp{1} '_motor_spectra.mat'], 'motor_spectrum_source', 'motor_spectrum_sens')
            
            
            
        else
            load([tmp{1} '_motor_spectra.mat'])
            
            
        end
%             
%           
            motor_spectrum_sens.powspctrm = 10*log10(motor_spectrum_sens.powspctrm);
            motor_spectrum_source.powspctrm = 10*log10(motor_spectrum_source.powspctrm);

%             blmat = repmat(mean(motor_spectrum_sens.powspctrm(:,:,:,nearest(motor_spectrum_sens.time,-2):nearest(motor_spectrum_sens.time,-1)),4),[1 1 1 size(motor_spectrum_sens.powspctrm,4)]);
%             orig = motor_spectrum_sens.powspctrm;
%             dif = orig - blmat;
%             plot(motor_spectrum_sens.time, squeeze(mean(mean(mean(dif)))))
%             
%             motor_spectrum_sens.powspctrm = motor_spectrum_sens.powspctrm;
%             motor_spectrum_source.powspctrm = motor_spectrum_source.powspctrm-repmat(mean(motor_spectrum_source.powspctrm(:,:,:,nearest(motor_spectrum_source.time,-2):nearest(motor_spectrum_source.time,-1)),4),[1 1 1 size(motor_spectrum_source.powspctrm,4)]);

            scfg_lefthand = [];
            scfg_lefthand.trials = ismember(motor_spectrum_source.trialinfo(:,3), [3,4]);
            
            scfg_righthand = [];
            scfg_righthand.trials = ismember(motor_spectrum_source.trialinfo(:,3), [7,8]);
            motor_spectrum_sens_lefthand = ft_selectdata(scfg_lefthand,motor_spectrum_sens);
            motor_spectrum_sens_righthand = ft_selectdata(scfg_righthand,motor_spectrum_sens);

            scfg_lefthand.channel = 'M1right';
            scfg_righthand.channel = 'M1left';
            motor_spectrum_source_lefthand = ft_selectdata(scfg_lefthand, motor_spectrum_source);
            motor_spectrum_source_righthand = ft_selectdata(scfg_righthand, motor_spectrum_source);
            
            
            cfg = [];
            cfg.baseline = [-2 -1];
            cfg.baselinetype = 'absolute';
            motor_spectrum_sens_lefthand = ft_freqbaseline(cfg, motor_spectrum_sens_lefthand);
            motor_spectrum_sens_righthand = ft_freqbaseline(cfg,motor_spectrum_sens_righthand);

            lhtopo.(current_cond){end+1} = ft_freqdescriptives([],motor_spectrum_sens_lefthand);
            rhtopo.(current_cond){end+1} = ft_freqdescriptives([],motor_spectrum_sens_righthand);

            
            motor_spectrum_source_lefthand = ft_freqbaseline(cfg, motor_spectrum_source_lefthand);
            motor_spectrum_source_righthand = ft_freqbaseline(cfg, motor_spectrum_source_righthand);

            
            
                
             pre = motor_spectrum_sens_lefthand.powspctrm(:,:,:,nearest(motor_spectrum_sens_lefthand.time,-1):nearest(motor_spectrum_sens_lefthand.time,0));
             post = motor_spectrum_sens_lefthand.powspctrm(:,:,:,nearest(motor_spectrum_sens_lefthand.time,0):nearest(motor_spectrum_sens_lefthand.time,1));
             [~,~,~,ttest_sens_lefthand] = ttest(mean(pre-post, [2,3,4]));
             pre = motor_spectrum_sens_righthand.powspctrm(:,:,:,nearest(motor_spectrum_sens_righthand.time,-1):nearest(motor_spectrum_sens_righthand.time,0));
             post = motor_spectrum_sens_righthand.powspctrm(:,:,:,nearest(motor_spectrum_sens_righthand.time,0):nearest(motor_spectrum_sens_righthand.time,1));
             [~,~,~,ttest_sens_righthand] = ttest(mean(pre-post, [2,3,4]));
             
              pre = motor_spectrum_source_lefthand.powspctrm(:,:,:,nearest(motor_spectrum_source_lefthand.time,-1):nearest(motor_spectrum_source_lefthand.time,0));
             post = motor_spectrum_source_lefthand.powspctrm(:,:,:,nearest(motor_spectrum_source_lefthand.time,0):nearest(motor_spectrum_source_lefthand.time,1));
             [~,~,~,ttest_source_lefthand] = ttest(mean(pre-post, [2,3,4]));
             pre = motor_spectrum_source_righthand.powspctrm(:,:,:,nearest(motor_spectrum_source_righthand.time,-1):nearest(motor_spectrum_source_righthand.time,0));
             post = motor_spectrum_source_righthand.powspctrm(:,:,:,nearest(motor_spectrum_source_righthand.time,0):nearest(motor_spectrum_source_righthand.time,1));
             [~,~,~,ttest_source_righthand] = ttest(mean(pre-post, [2,3,4]));
             

             
             pre = motor_spectrum_source_lefthand.powspctrm(:,:,:,nearest(motor_spectrum_source_lefthand.time,-1.25):nearest(motor_spectrum_source_lefthand.time,0.5));
             PMBD_left = mean(pre, [1,2,3,4]) - mean(motor_spectrum_source_lefthand.powspctrm, [1,2,3,4]);
             post = motor_spectrum_source_lefthand.powspctrm(:,:,:,nearest(motor_spectrum_source_lefthand.time,1):nearest(motor_spectrum_source_lefthand.time,1.75));
              PMBR_left = mean(post, [1,2,3,4]) - mean(motor_spectrum_source_lefthand.powspctrm, [1,2,3,4]);

              pre = motor_spectrum_source_righthand.powspctrm(:,:,:,nearest(motor_spectrum_source_righthand.time,-1.25):nearest(motor_spectrum_source_righthand.time,0.5));
             PMBD_right = mean(pre, [1,2,3,4]) - mean(motor_spectrum_source_righthand.powspctrm, [1,2,3,4]);
             post = motor_spectrum_source_righthand.powspctrm(:,:,:,nearest(motor_spectrum_source_righthand.time,1):nearest(motor_spectrum_source_righthand.time,1.75));
              PMBR_right = mean(post, [1,2,3,4]) - mean(motor_spectrum_source_righthand.powspctrm, [1,2,3,4]);

             
%             
%             
%             
%             figure;hold on
%             plot(motor_spectrum_source_lefthand.time, squeeze(nanmean(nanmean(motor_spectrum_source_lefthand.powspctrm))))
%             plot(motor_spectrum_sens_lefthand.time, squeeze(nanmean(nanmean(nanmean(motor_spectrum_sens_lefthand.powspctrm)))))
%             legend({'left hand source', 'lefthand sens'})
%             
%             figure;hold on
%             plot(motor_spectrum_source_righthand.time, squeeze(nanmean(nanmean(motor_spectrum_source_righthand.powspctrm))))
%             plot(motor_spectrum_sens_righthand.time, squeeze(nanmean(nanmean(nanmean(motor_spectrum_sens_righthand.powspctrm)))))
%             legend({'right hand source', 'right hand sens'})



%             sourcespectra(end+1,:) = squeeze(mean(mean(motor_spectrum_source.powspctrm)));
%             sensspectra(end+1,:) = squeeze(mean(mean(motor_spectrum_sens.powspctrm)));
            sourcespectra_lefthand(n).subj = subjs{s};
            sourcespectra_lefthand(n).(current_cond) = squeeze(mean(mean(motor_spectrum_source_lefthand.powspctrm)));
            sourcespectra_lefthand(n).(['t_' current_cond]) = ttest_source_lefthand.tstat;
            sourcespectra_lefthand(n).(['PMBD_' current_cond]) = PMBD_left;
            sourcespectra_lefthand(n).(['PMBR_' current_cond]) = PMBR_left;


            sourcespectra_righthand(n).subj = subjs{s};
            sourcespectra_righthand(n).(current_cond) = squeeze(mean(mean(motor_spectrum_source_righthand.powspctrm)));
            sourcespectra_righthand(n).(['t_' current_cond]) = ttest_source_righthand.tstat;
            sourcespectra_righthand(n).(['PMBD_' current_cond]) = PMBD_right;
            sourcespectra_righthand(n).(['PMBR_' current_cond]) = PMBR_right;

            
            sensspectra_lefthand(n).subj = subjs{s};
            sensspectra_lefthand(n).(current_cond) = squeeze(mean(mean(mean(motor_spectrum_sens_lefthand.powspctrm))));
            sensspectra_lefthand(n).(['t_' current_cond]) = ttest_sens_lefthand.tstat;
            
            sensspectra_righthand(n).subj = subjs{s};
            sensspectra_righthand(n).(current_cond) = squeeze(mean(mean(mean(motor_spectrum_sens_righthand.powspctrm))));
            sensspectra_righthand(n).(['t_' current_cond]) = ttest_sens_righthand.tstat;

%             sourcespectra(n).([current_cond 'BL']) = squeeze(nanmean(nanmean(blspctr,1),3));

%             
%             
%             
%             

%             
     end,end
 
%  
%  tcfg = [];
%  tcfg.layout = 'neuromag306cmb.lay'
%  tcfg.time = [-1.25 .5]
%  ft_topoplotTFR(tcfg,ft_freqgrandaverage([],lhtopo.Sham{:}))
%  save('/mnt/data/Studies/tVNS_regrep/motorspectra.mat','sensspectra_lefthand','sensspectra_righthand', 'sourcespectra_lefthand', 'sourcespectra_righthand')
% success = 1;    