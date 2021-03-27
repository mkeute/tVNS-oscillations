function clean = clean_timelock(timelock)
% 
% runs visual inspection, then ICA with component rejection, then
% second visual inspection




%first rejectvisual *before* ICA
cfg        = [];
cfg.showlabel='yes';
cfg.channel= {'MEG'};
cfg.method = 'summary';
cfg.gradscale   = 0.04;  %factor to bring Grad and Mag data onto same scale
cfg.layout = 'neuromag306mag.lay';
timelock = ft_rejectvisual(cfg, timelock);

%% ica
cfg_sel = [];
cfg_sel.channel = 'MEG';

cfg        = [];
cfg.method = 'fastica';
cfg.numcomponent = 60;
compICA = ft_componentanalysis(cfg, ft_selectdata(cfg_sel,timelock));


% plot the components for visual inspection
% magnetometer first
figure;
cfg = [];
cfg.component = 1:15;
cfg.layout    = 'neuromag306mag.lay';
ft_topoplotIC(cfg, compICA)


cfg.allowoverlap = 1;
cfg.continuous  = 'no';
ft_databrowser(cfg, compICA);


%
comp_rej = input('components to exclude?')
close all
%% remove the bad components and backproject the data
cfg = [];
cfg.component = [comp_rej]; % to be removed component(s)
timelock = ft_rejectcomponent(cfg, compICA, timelock);




%second rejectvisual *after* ICA
cfg        = [];
cfg.showlabel='yes';
cfg.channel= {'MEG'};
cfg.method = 'summary';
cfg.gradscale   = 0.04;  %factor to bring Grad and Mag data onto same scale
cfg.layout = 'neuromag306mag.lay';
clean = ft_rejectvisual(cfg, timelock);

