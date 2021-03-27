function [sourcespectra,sensspectra] = pipeline_visual(subjs, exdir)
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
sourcespectra = struct;
sensspectra = struct;
for s = 1:length(subjs)
    n=n+1;
    cd([exdir filesep subjs{s}])
    datasets = dir('*.fif');
    datasets = {datasets(:).name};


    

    %%process motor
    for f = 1:length(datasets)


        fname        =  datasets{f}
        
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
        if ~exist([tmp{1} '_visual_spectra.mat'], 'file')
            if ~exist([tmp{1} '_visualdat_sens.mat'], 'file')
                
                visualdat = ana_read_visual(fname);
                if ~isstruct(visualdat)
                    continue
                end
                
                
                %         if ~exist([tmp{1} '_resting_ica_unmixing.mat'])
%                 if ~exist([tmp{1} '_visualdat.mat'], 'file')
                    clear comp rejcfg
                    load([tmp{1} '_resting_ica_unmixing.mat']);
                    
                    scfg = [];
                    scfg.channel =  comp.topolabel;
                    visualdat = ft_selectdata(scfg, visualdat);
                    comp.trial = {};
                    comp.time = visualdat.time;
                    comp.sampleinfo = visualdat.sampleinfo;
                    comp.trialinfo = visualdat.trialinfo;
                    for t = 1:length(visualdat.trial)
                        c = comp.unmixing*visualdat.trial{:,t};
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
                visual_clean = ft_rejectcomponent(rejcfg, comp, visualdat);
                close all;
                
                
                visual_clean = ft_rejectvisual([],visual_clean);
                save([tmp{1} '_visualdat_sens.mat'], 'visual_clean', '-v7.3');
                
                %% TODO do source analysis
                %% TODO do freq analysis, baseline correct
                
            else
                
                load([tmp{1} '_visualdat_sens.mat']); %returns resting_clean and resting_spectrum
                
            end
            
            
            % continue from here
            % do sourve analysis separately for left and right hand
            
            
            load([tmp{1} '_individual_models.mat'], 'individual_hdm', 'individual_sourcemodel');
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
            %% TODO change spatial filter for motor cortex
            
            cfg              = [];
            cfg.method       = 'lcmv';
            cfg.headmodel    = individual_hdm; % here you actually need the headmodel. hmm
            cfg.sourcemodel  = individual_sourcemodel;
            cfg.sourcemodel.pos  = [-2,-80,34; 28,-96,-6; -28,-96,-6];
            %          cfg.sourcemodel.pos  = [-48, -8,50; 52, -4, 54]; %MNI coordinates of left and right motor cortex, according to http://www.ajnr.org/content/ajnr/suppl/2011/02/07/ajnr.A2330.DC1/2330_materials.pdf
            cfg.sourcemodel.inside  = true(1,3);
            cfg.unit    = 'mm'; % since i didn't use the  sourcemodel I just removed this
            cfg.lcmv.keepfilter = 'yes';
            cfg.keeptrials = 'yes'; % don't really need this
            % PR: you can have it easier
            cfg.lcmv.fixedori   = 'yes'; % using this you don't need to use the euclidian norm below
            source_idx       = ft_sourceanalysis(cfg, visual_clean);
            
            
%                     ft_plot_headmodel(individual_hdm)
%                     cfg =[]
%                     cfg.location = [0,-100,8]
%                      cfg.funparameter = 'pow';
%                     ft_sourceplot(cfg, source_idx)
%             
            
            %% try sourceplot to see where we end up with these coords?
            
            V1center = source_idx.avg.filter{1};
            V1left = source_idx.avg.filter{2};
            V1right = source_idx.avg.filter{3};
            chansel = ft_channelselection('MEG', visual_clean.label);
            chansel = match_str(visual_clean.label, chansel);
            
            vizsource = visual_clean;
            vizsource.label = {'V1center', 'V1left', 'V1right'};
            %         movsource.time = movlock.time;
            vizsource.trial = {};
            for t = 1:length(visual_clean.trial)
                vizsource.trial{t} = [V1center;V1left;V1right] * squeeze(visual_clean.trial{t}(chansel,:));
                
            end
            
            
            
            cfg = [];
            cfg.method = 'wavelet';
            cfg.output = 'pow';
            cfg.keeptrials = 'yes';
            cfg.pad = 'nextpow2';
            cfg.toi = -3:.05:3;
            cfg.foi = 2.^(log2(30):.125:log2(60));
            cfg.gwidth = 6;
            visual_spectrum_source = ft_freqanalysis(cfg, vizsource);
            visual_spectrum_sens = ft_freqanalysis(cfg, visual_clean);
            save([tmp{1} '_visual_spectra.mat'], 'visual_spectrum_source', 'visual_spectrum_sens')
            
            
            
        else
            load([tmp{1} '_visual_spectra.mat'])
            
            
        end
%             
%             
            visual_spectrum_sens.powspctrm = 10*log10(visual_spectrum_sens.powspctrm);
            visual_spectrum_source.powspctrm = 10*log10(visual_spectrum_source.powspctrm);

            cfg = [];
            cfg.baseline = [-1 0];
            cfg.baselinetype = 'absolute';
            visual_spectrum_sens = ft_freqbaseline(cfg, visual_spectrum_sens);
            visual_spectrum_source = ft_freqbaseline(cfg, visual_spectrum_source);
 
             
            trlwise_sens = mean(visual_spectrum_sens.powspctrm(:,:,:,nearest(visual_spectrum_sens.time,0):nearest(visual_spectrum_sens.time,1)), [2,3,4]);
             trlwise_source = mean(visual_spectrum_source.powspctrm(:,:,:,nearest(visual_spectrum_source.time,0):nearest(visual_spectrum_source.time,1)), [2,3,4]);
            [~,~,~,t_sens] = ttest(trlwise_sens);
             [~,~,~,t_source] = ttest(trlwise_source);
             
             
             stimulus = visual_spectrum_source.powspctrm(:,:,:,nearest(visual_spectrum_source.time,0):nearest(visual_spectrum_source.time,1));
             gammaresponse = mean(stimulus,[1,2,3,4]);
             

            sourcespectra(n).subj = subjs{s};
            sourcespectra(n).(current_cond) = squeeze(mean(visual_spectrum_source.powspctrm, [1,2,3]));
            sourcespectra(n).(['t_' current_cond]) = t_source.tstat;
            sourcespectra(n).(['gammaresponse_' current_cond]) = gammaresponse;

            sensspectra(n).subj = subjs{s};
            sensspectra(n).(current_cond) = squeeze(mean(visual_spectrum_sens.powspctrm, [1,2,3]));
            sensspectra(n).(['t_' current_cond]) = t_sens.tstat;

            
            
            
%             sourcespectra(n).([current_cond 'BL']) = squeeze(nanmean(nanmean(blspctr,1),3));

%             
%             
%             
%             
%             figure;hold on
%             plot(visual_spectrum_source.time, squeeze(mean(visual_spectrum_source.powspctrm,[1,2,3])))
%             plot(visual_spectrum_source.time, squeeze(mean(visual_spectrum_sens.powspctrm,[1,2,3])))
%             legend({'source', 'sensor'})
%             
%             
%             figure;hold on
%             plot(motor_spectrum_righthand_source.time, squeeze(nanmean(motor_spectrum_righthand_source.powspctrm(1,:,:),2)))
%             plot(motor_spectrum_righthand_source.time, squeeze(nanmean(motor_spectrum_righthand_source.powspctrm(2,:,:),2)))
%             plot(motor_spectrum_righthand_sens.time, squeeze(nanmean(nanmean(motor_spectrum_righthand_sens.powspctrm))))
%             legend({'left hemisphere source', 'right hemisphere source', 'sensor'})
%             
     end,end
 
 
 save('/mnt/data/Studies/tVNS_regrep/visualspectra.mat','sourcespectra', 'sensspectra')
% success = 1;    