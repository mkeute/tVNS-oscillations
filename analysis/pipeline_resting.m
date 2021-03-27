function restingspectra = pipeline_resting(subjs, exdir)
subjinfo = readtable('/mnt/data/Studies/tVNS_regrep/StimPlan.xlsx');

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


    

    %%process resting
    for f = 1:length(datasets)
        

        fname        =  datasets{f};
        tmp = strsplit(datasets{f}, '.');
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
        
        if ~exist([tmp{1} '_restingdat.mat'])

            hdr = ft_read_header(fname)
            event = ft_read_event(fname)
            event = event(strcmp({event(:).type}, 'Trigger') & [event(:).value]~=128);
            restdat = ana_read_resting(event, fname)
            if ~isstruct(restdat)
                continue
            end
             restdat = ft_rejectvisual([],restdat);


            %         if ~exist([tmp{1} '_resting_ica_unmixing.mat'])
            if true%~exist([tmp{1} '_resting_ica_unmixing.mat'])
                cfg        = [];
                cfg.method = 'runica'; % this is the default and uses the implementation from EEGLAB
                cfg.numcomponent = 50;
                comp = ft_componentanalysis(cfg, restdat);
            elseif ~exist([tmp{1} '_restingdat.mat'])

                comp = load('/mnt/data/Studies/tVNS_regrep/ica_template.mat');
                comp = comp.comp1;
                unmixing = load([tmp{1} '_resting_ica_unmixing.mat']);
                comp.unmixing = unmixing.unmixing;
                comp.topo = pinv(unmixing.unmixing);
                comp.time = restdat.time;
                comp.trial = {};
                for t = 1:length(restdat.trial)
                    c = unmixing.unmixing*restdat.trial{:,t};
                    c = c-mean(c,2);
                    comp.trial{t} = c;
                end
            end


            cfg = [];
            cfg.component = 1:20;       % specify the component(s) that should be plotted
            cfg.layout    = 'neuromag306mag.lay'; % specify the layout file that should be used for plotting
            cfg.comment   = 'no';

%                 ft_topoplotIC(cfg, comp)
            ft_databrowser(cfg, comp)
            rejcfg = [];
            rejcfg.component = str2num(input('tbrej?','s')); % to be removed component(s)
            resting_clean = ft_rejectcomponent(rejcfg, comp, restdat);
            close all;

            comp.trial = {};
            save([tmp{1} '_resting_ica_unmixing.mat'], 'comp', 'rejcfg');

            
            resting_clean = ft_rejectvisual([],resting_clean);
            
            
            
            cfg = [];
            cfg.method = 'wavelet';
            cfg.output = 'pow';
            cfg.keeptrials = 'yes';
            cfg.toi = 1:.05:resting_clean.time{1}(end);
            cfg.foi = 2.^(log2(1):.125:log2(64));
            cfg.gwidth = 6;
            resting_spectrum = ft_freqanalysis(cfg, resting_clean);
            save([tmp{1} '_restingdat.mat'], 'resting_clean', 'resting_spectrum');
        else

            load([tmp{1} '_restingdat.mat']); %returns resting_clean and resting_spectrum


        end


        cfg = [];
        cfg.method = 'wavelet';
        cfg.output = 'pow';
        cfg.keeptrials = 'yes';
        cfg.toi = 1:.05:resting_clean.time{1}(end);
        cfg.foi = resting_spectrum.freq(1:11);
        cfg.width = 3;
        cfg.pad = 'nextpow2';
        resting_spectrum_LF = ft_freqanalysis(cfg, resting_clean);
        
        resting_spectrum.powspctrm(:,:,1:11,:) = resting_spectrum_LF.powspctrm;
        subjspctr = 10*log10(resting_spectrum.powspctrm);
        blspctr = squeeze(nanmean(subjspctr(resting_spectrum.trialinfo(:,1) == 1,:,:,:)));
        stimspctr =  squeeze(nanmean(subjspctr(resting_spectrum.trialinfo(:,1) > 1,:,:,:)));

        
        restingspectra(n).subj = subjs{s};
        restingspectra(n).(current_cond) = squeeze(nanmean(nanmean(stimspctr,1),3))';
        restingspectra(n).([current_cond 'BL']) = squeeze(nanmean(nanmean(blspctr,1),3))';


        chantab = readtable('neuromag306all.lay','FileType','text');
        left_chans = {};
        right_chans = {};
        for c = 1:306
           if chantab.Var2(c) < 0
               left_chans(end+1) = chantab.Var6(c);
           elseif chantab.Var2(c) > 0
              right_chans(end+1) = chantab.Var6(c);
           end
        end
        
        lcfg = [];
        lcfg.channel = left_chans;
        lspc = ft_selectdata(lcfg,resting_spectrum);
        
        subjspctr = 10*log10(lspc.powspctrm);
        blspctr = squeeze(nanmean(subjspctr(lspc.trialinfo(:,1) == 1,:,:,:)));
        stimspctr =  squeeze(nanmean(subjspctr(lspc.trialinfo(:,1) > 1,:,:,:)));

        
        restingspectra(n).([current_cond '_left']) = squeeze(nanmean(nanmean(stimspctr,1),3))';
        restingspectra(n).([current_cond '_leftBL']) = squeeze(nanmean(nanmean(blspctr,1),3))';

        
        rcfg=[];
        rcfg.channel = right_chans;
        rspc = ft_selectdata(rcfg,resting_spectrum);

        
        subjspctr = 10*log10(rspc.powspctrm);
        blspctr = squeeze(nanmean(subjspctr(rspc.trialinfo(:,1) == 1,:,:,:)));
        stimspctr =  squeeze(nanmean(subjspctr(rspc.trialinfo(:,1) > 1,:,:,:)));

        
        restingspectra(n).([current_cond '_right']) = squeeze(nanmean(nanmean(stimspctr,1),3))';
        restingspectra(n).([current_cond '_rightBL']) = squeeze(nanmean(nanmean(blspctr,1),3))';

        
%         tcfg=[]
%         tcfg.layout = 'neuromag306cmb.lay'
%         tcfg.marker = 'labels'
%         ft_topoplotTFR([],resting_spectrum)
%         
%         figure;hold on;title(fname)
%         plot(resting_spectrum.freq, squeeze(nanmean(nanmean(blspctr,1),3)))
%         plot(resting_spectrum.freq, squeeze(nanmean(nanmean(stimspctr,1),3)))
%         plot(resting_spectrum.freq, squeeze(nanmean(nanmean(stimspctr-blspctr,1),3)))


    end
   
 
            n=n+1;    
        
end

save('/mnt/data/Studies/tVNS_regrep/restingspectra.mat', 'restingspectra')

success = 1;    