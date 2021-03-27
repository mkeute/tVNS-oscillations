%% boilerplate
clear all; restoredefaultpath;

% FT;SPM
addpath([userpath filesep 'fieldtrip'])
ft_defaults;
addpath([userpath filesep 'spm12'])
spm;close
% 
% Path organization, read data directory
projdir = '/mnt/data/Studies/tVNS_regrep'
exdir = '/mnt/sink/tVNS_regrep_data'; 
addpath(genpath(exdir))
addpath([projdir filesep 'code']);

cd(exdir)

subjs = dir;
subjs = {subjs(:).name};
subjs(strcmp(subjs, '.') | strcmp(subjs, '..')| strcmp(subjs, '.DS_Store')) = [] % .DS_Store is a mac thing

redo_resting = 1;
redo_models = 0;
redo_motor = 0;
redo_visual = 0;
%% get resting (sensor-level) spectra
if redo_resting, restingspectra = pipeline_resting(subjs, exdir), end

%% prepare source localization
if redo_models, headmodels_done = pipeline_headmodels(subjs, exdir), end

%% get sensor and source spectra for motor task
if redo_motor, [sensspectra_lefthand,sensspectra_righthand, sourcespectra_lefthand, sourcespectra_righthand] = pipeline_motor(subjs, exdir), end
%for motor task, we lose three subjects to technical recording problems

%% get sensor and source spectra for visual stimulation
if redo_visual
    [sourcespectra,sensspectra] = pipeline_visual(subjs, exdir);
end



%% load data for figures
cd(projdir)
load restingspectra.mat
load motorspectra.mat
load visualspectra.mat


exclude = {'sj95','mk48','lt69','oy60','oa12'};
ix = [];
for n = 1:length(sourcespectra)
    if ismember(sourcespectra(n).subj, exclude)
        ix(end+1) = n;
    end
end


sourcespectra(ix) = [];
sensspectra(ix) = [];


%five subjects excluded from visual analysis
%% make figure R1: show resting spectra at baseline, stim, and sham
f=[1,1.33333333333333,1.66666666666667,2,2.33333333333333,2.66666666666667,3,3.33333333333333,3.66666666666667,4,4.33333333333333,4.66666666666667,5.33333333333333,5.66666666666667,6.33333333333333,6.66666666666667,7.33333333333333,8,8.66666666666667,9.66666666666667,10.3333333333333,11.3333333333333,12.3333333333333,13.3333333333333,14.6666666666667,16,17.3333333333333,19,20.6666666666667,22.6666666666667,24.6666666666667,27,29.3333333333333,32,35,38,41.3333333333333,45.3333333333333,49.3333333333333,53.6666666666667,58.6666666666667,64];
reststimbl = [restingspectra(:).StimBL];
restshambl = [restingspectra(:).ShamBL];
reststim = [restingspectra(:).Stim];
restsham = [restingspectra(:).Sham];

figure; hold on;set(gcf,'Position',[0 0 600 600])
set(gca,'xscale','log','fontsize',12,'FontWeight','bold','XTick',[1 10 15 30 64], 'XTickLabel', {'1','10','15','30','64'},'XLim',[1 64])
ylabel('log-power [ln(T^2)]')
xlabel('Frequency [Hz]')
plot(f,mean(restshambl,2),'--r','LineWidth',2)
plot(f,mean(restsham,2),'-r','LineWidth',2)
plot(f,mean(reststimbl,2),'--b','LineWidth',2)
plot(f,mean(reststim,2),'-b','LineWidth',2)
legend({'pre-stim/sham','post-stim/sham','pre-stim/tVNS','post-stim/tVNS'})
saveas(gcf,[projdir filesep 'figures/resting_spectra.svg'])



%% lateralized spectra


reststimleft = [restingspectra(:).Stim_left];
reststimright = [restingspectra(:).Stim_right];

reststimlat = reststimright-reststimleft;
betastimlat = mean(reststimlat(nearest(f,15):nearest(f,30),:),1);

restshamleft = [restingspectra(:).Sham_left];
restshamright = [restingspectra(:).Sham_right];

restshamlat = restshamright-restshamleft;
betashamlat = mean(restshamlat(nearest(f,15):nearest(f,30),:),1);

%% make figure R1b: baseline-subtracted spectra with CI

figure; hold on;set(gcf,'Position',[0 0 600 600])
set(gca,'xscale','log','fontsize',12,'FontWeight','bold','XTick',[1 10 15 30 64], 'XTickLabel', {'1','10','15','30','64'},'XLim',[1 64])
ylabel('log-power [dB]')
xlabel('Frequency [Hz]')
plot(f,zeros(length(f)),'--k')

sham = restsham-restshambl;
stim=reststim-reststimbl;
sh=plot(f,mean(sham,2),'-r','LineWidth',2)
m = bootstrp(1000,@mean,sham')-repmat(mean(sham,2)',[1000 1]);
upper = mean(sham,2)'+quantile(m,.975);
lower = mean(sham,2)'+quantile(m,.025);
fill([f,fliplr(f)],[upper,fliplr(lower)], 'r','FaceAlpha',0.5, 'EdgeAlpha',0)
st=plot(f,mean(stim,2),'-b','LineWidth',2)
m = bootstrp(1000,@mean,stim')-repmat(mean(stim,2)',[1000 1]);
upper = mean(stim,2)'+quantile(m,.975);
lower = mean(stim,2)'+quantile(m,.025);
fill([f,fliplr(f)],[upper,fliplr(lower)], 'b','FaceAlpha',0.5, 'EdgeAlpha',0)
legend([st sh],{'pre-post/tVNS','pre-post/sham'})
saveas(gcf,[projdir filesep 'figures/resting_spectra_diff.svg'])

%% make figure R1c: extract mean beta power

figure;hold on;title('beta power')
    betasham = mean(sham(nearest(f,15):nearest(f,30),:),1);
    betastim = mean(stim(nearest(f,15):nearest(f,30),:),1);
    
    m = bootstrp(1000,@mean,betastim)-repmat(mean(betastim,2)',[1000 1]);
    plot(1.5,mean(betastim),'b.','MarkerSize',40)
    errorbar(1.5,mean(betastim),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    m = bootstrp(1000,@mean,betasham)-repmat(mean(betasham,2)',[1000 1]);
    plot(2.15,mean(betasham),'r.','MarkerSize',40)
    errorbar(2.15,mean(betasham),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    scatter(0.35+ones(length(betastim),1)+.3*rand(length(betastim),1),betastim,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(2*ones(length(betasham),1)+.3*rand(length(betasham),1),betasham,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    ylabel('beta power [dB]')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 300 600])
    saveas(gcf,[projdir filesep 'figures/meanrestingbeta.svg'])
   

csvwrite('betasham.csv', betasham)
csvwrite('betastim.csv', betastim)
    

%% make figure R1d: plot resting beta lateralization

figure;hold on;title('beta lateralization')
    
    m = bootstrp(1000,@mean,betastimlat)-repmat(mean(betastimlat,2)',[1000 1]);
    plot(1.5,mean(betastimlat),'b.','MarkerSize',40)
    errorbar(1.5,mean(betastimlat),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    m = bootstrp(1000,@mean,betashamlat)-repmat(mean(betashamlat,2)',[1000 1]);
    plot(2.15,mean(betashamlat),'r.','MarkerSize',40)
    errorbar(2.15,mean(betashamlat),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    scatter(0.35+ones(length(betastimlat),1)+.3*rand(length(betastimlat),1),betastimlat,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(2*ones(length(betashamlat),1)+.3*rand(length(betashamlat),1),betashamlat,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    ylabel('right beta - left beta [dB]')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 300 600])
    saveas(gcf,[projdir filesep 'figures/betalateralization.svg'])
   

csvwrite('betashamlat.csv', betashamlat)
csvwrite('betastimlat.csv', betastimlat)

%% todo export all values for statistics as csv

%% make figure M1: show beta power time course in sensor and source space
x = -2:.05:2; %time stamps
figure; hold on;set(gcf,'Position',[0 0 1600 800])

%left hand plots (left column of 2x2 plot)
sensleftsham=[sensspectra_lefthand(~strcmp({sensspectra_lefthand(:).subj},'ep96')).Sham];
sensleftstim=[sensspectra_lefthand(~strcmp({sensspectra_lefthand(:).subj},'ep96')).Stim];
srcleftsham=[sourcespectra_lefthand(~strcmp({sourcespectra_lefthand(:).subj},'ep96')).Sham];
srcleftstim=[sourcespectra_lefthand(~strcmp({sourcespectra_lefthand(:).subj},'ep96')).Stim];
sensrightsham=[sensspectra_righthand(~strcmp({sensspectra_righthand(:).subj},'ep96')).Sham];
sensrightstim=[sensspectra_righthand(~strcmp({sensspectra_righthand(:).subj},'ep96')).Stim];
srcrightsham=[sourcespectra_righthand(~strcmp({sourcespectra_righthand(:).subj},'ep96')).Sham];
srcrightstim=[sourcespectra_righthand(~strcmp({sourcespectra_righthand(:).subj},'ep96')).Stim];
subplot(1,2,1);hold on;title('left hand responses')
        ylim([-1.5,1])
        ylabel('beta power [dB]')
        xlabel('peri-movement time [s]')
        plot(x,mean(sensleftsham,2),'--r','LineWidth',2)
        plot(x,mean(srcleftsham,2),'-r','LineWidth',2)

        plot(x,mean(sensleftstim,2),'--b','LineWidth',2)
        plot(x,mean(srcleftstim,2),'-b','LineWidth',2)
        legend({'sensor/sham','source/sham','sensor/tVNS','source/tVNS'})
        set(gca,'fontsize',12,'FontWeight','bold')

subplot(1,2,2);hold on;title('right hand responses')
        ylim([-1.5,1])
%         ylabel('beta power [dB]')
        xlabel('peri-movement time [s]')
        plot(x,mean(sensrightsham,2),'--r','LineWidth',2)
        plot(x,mean(srcrightsham,2),'-r','LineWidth',2)
        plot(x,mean(sensrightstim,2),'--b','LineWidth',2)
        plot(x,mean(srcrightstim,2),'-b','LineWidth',2)
        legend({'sensor/sham','source/sham','sensor/tVNS','source/tVNS'})
        set(gca,'fontsize',12,'FontWeight','bold')

saveas(gcf,[projdir filesep 'figures/beta_timecourse.svg'])
    
%% make figure M1c: show sham-stim differences in source space        
figure; hold on;set(gcf,'Position',[0 0 1600 800])
set(gca,'fontsize',12,'FontWeight','bold')

plot(x,zeros(length(x)),'--k')
        ylim([-1.5,1])
        ylabel('beta power [dB]')
        xlabel('peri-movement time [s]')
        
        y=srcrightstim-srcrightsham;
        r=plot(x,mean(y,2),'k','LineWidth',2)
        m = bootstrp(1000,@mean,y')-repmat(mean(y,2)',[1000 1]);
        upper = mean(y,2)'+quantile(m,.975);
        lower = mean(y,2)'+quantile(m,.025);
        fill([x,fliplr(x)],[upper,fliplr(lower)], 'k','FaceAlpha',0.5, 'EdgeAlpha',0)

        y=srcleftstim-srcleftsham;
        l=plot(x,mean(y,2),'g','LineWidth',2)
        m = bootstrp(1000,@mean,y')-repmat(mean(y,2)',[1000 1]);
        upper = mean(y,2)'+quantile(m,.975);
        lower = mean(y,2)'+quantile(m,.025);
        fill([x,fliplr(x)],[upper,fliplr(lower)], 'g','FaceAlpha',0.5, 'EdgeAlpha',0)

        legend([l r], {'stim-sham diff./left hand', 'stim-sham diff./right hand'})
        saveas(gcf,[projdir filesep 'figures/movement_beta_difference.svg'])

%% make figure M1b & d & e & f : show PMBD and PMBR and lateralization
leftstimPMBD = [sourcespectra_lefthand(~strcmp({sourcespectra_lefthand(:).subj},'ep96')).PMBD_Stim];
leftshamPMBD = [sourcespectra_lefthand(~strcmp({sourcespectra_lefthand(:).subj},'ep96')).PMBD_Sham];
leftstimPMBR = [sourcespectra_lefthand(~strcmp({sourcespectra_lefthand(:).subj},'ep96')).PMBR_Stim];
leftshamPMBR = [sourcespectra_lefthand(~strcmp({sourcespectra_lefthand(:).subj},'ep96')).PMBR_Sham];
rightstimPMBD = [sourcespectra_righthand(~strcmp({sourcespectra_righthand(:).subj},'ep96')).PMBD_Stim];
rightshamPMBD = [sourcespectra_righthand(~strcmp({sourcespectra_righthand(:).subj},'ep96')).PMBD_Sham];
rightstimPMBR = [sourcespectra_righthand(~strcmp({sourcespectra_righthand(:).subj},'ep96')).PMBR_Stim];
rightshamPMBR = [sourcespectra_righthand(~strcmp({sourcespectra_righthand(:).subj},'ep96')).PMBR_Sham];


PMBD_lateralization_tvns = leftstimPMBD-rightstimPMBD; %positive value: stronger PMBD right
PMBD_lateralization_sham = leftshamPMBD-rightshamPMBD; %positive value: stronger PMBD right

PMBR_lateralization_tvns = leftstimPMBR-rightstimPMBR; %positive value: stronger PMBR right
PMBR_lateralization_sham = leftshamPMBR-rightshamPMBR; %positive value: stronger PMBR right


csvwrite('leftstimPMBD.csv', leftstimPMBD)
csvwrite('leftshamPMBD.csv', leftshamPMBD)

csvwrite('leftstimPMBR.csv', leftstimPMBR)
csvwrite('leftshamPMBR.csv', leftshamPMBR)

csvwrite('rightstimPMBD.csv', rightstimPMBD)
csvwrite('rightshamPMBD.csv', rightshamPMBD)

csvwrite('rightstimPMBR.csv', rightstimPMBR)
csvwrite('rightshamPMBR.csv', rightshamPMBR)

figure;hold on;title('PMBD')

    %make individual dots and lines
    scatter(xstim,leftstimPMBD,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(xsham,leftshamPMBD,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    
%     for x = 1:length(xstim)
%        plot([xstim(x), xsham(x)], [leftstimPMBD(x),leftshamPMBD(x)],'k') 
%     end
    
    %make mean dots and errorbars
    m = bootstrp(1000,@mean,leftstimPMBD)-repmat(mean(leftstimPMBD,2)',[1000 1]);
    plot(1.5,mean(leftstimPMBD),'b.','MarkerSize',40)
    errorbar(1.5,mean(leftstimPMBD),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    m = bootstrp(1000,@mean,leftshamPMBD)-repmat(mean(leftshamPMBD,2)',[1000 1]);
    plot(2.15,mean(leftshamPMBD),'r.','MarkerSize',40)
    errorbar(2.15,mean(leftshamPMBD),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    xstim = 0.35+ones(length(leftstimPMBD),1)+.3*rand(length(leftstimPMBD),1);
    xsham = 2*ones(length(leftshamPMBD),1)+.3*rand(length(leftshamPMBD),1)
    
    
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 200 400])
    saveas(gcf,[projdir filesep 'figures/pmbdleft.svg'])
   
figure;hold on;title('PMBD')
    m = bootstrp(1000,@mean,rightstimPMBD)-repmat(mean(rightstimPMBD,2)',[1000 1]);
    plot(1.5,mean(rightstimPMBD),'b.','MarkerSize',40)
    errorbar(1.5,mean(rightstimPMBD),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    m = bootstrp(1000,@mean,rightshamPMBD)-repmat(mean(rightshamPMBD,2)',[1000 1]);
    plot(2.15,mean(rightshamPMBD),'r.','MarkerSize',40)
    errorbar(2.15,mean(rightshamPMBD),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    scatter(0.35+ones(length(rightstimPMBD),1)+.3*rand(length(rightstimPMBD),1),rightstimPMBD,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(2*ones(length(rightshamPMBD),1)+.3*rand(length(rightshamPMBD),1),rightshamPMBD,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 200 400])
    saveas(gcf,[projdir filesep 'figures/pmbdright.svg'])
   
    
    

figure;hold on;title('PMBR')
    m = bootstrp(1000,@mean,leftstimPMBR)-repmat(mean(leftstimPMBR,2)',[1000 1]);
    plot(1.5,mean(leftstimPMBR),'b.','MarkerSize',40)
    errorbar(1.5,mean(leftstimPMBR),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    m = bootstrp(1000,@mean,leftshamPMBR)-repmat(mean(leftshamPMBR,2)',[1000 1]);
    plot(2.15,mean(leftshamPMBR),'r.','MarkerSize',40)
    errorbar(2.15,mean(leftshamPMBR),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    scatter(0.35+ones(length(leftstimPMBR),1)+.3*rand(length(leftstimPMBR),1),leftstimPMBR,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(2*ones(length(leftshamPMBR),1)+.3*rand(length(leftshamPMBR),1),leftshamPMBR,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 200 400])
    saveas(gcf,[projdir filesep 'figures/PMBRleft.svg'])
   
figure;hold on;title('PMBR')
    m = bootstrp(1000,@mean,rightstimPMBR)-repmat(mean(rightstimPMBR,2)',[1000 1]);
    plot(1.5,mean(rightstimPMBR),'b.','MarkerSize',40)
    errorbar(1.5,mean(rightstimPMBR),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    m = bootstrp(1000,@mean,rightshamPMBR)-repmat(mean(rightshamPMBR,2)',[1000 1]);
    plot(2.15,mean(rightshamPMBR),'r.','MarkerSize',40)
    errorbar(2.15,mean(rightshamPMBR),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    scatter(0.35+ones(length(rightstimPMBR),1)+.3*rand(length(rightstimPMBR),1),rightstimPMBR,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(2*ones(length(rightshamPMBR),1)+.3*rand(length(rightshamPMBR),1),rightshamPMBR,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 200 400])
    saveas(gcf,[projdir filesep 'figures/PMBRright.svg'])
   

figure;hold on;title('PMBD lateralization')

    %make individual dots and lines
    scatter(xstim,PMBD_lateralization_tvns,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(xsham,PMBD_lateralization_sham,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    
%     for x = 1:length(xstim)
%        plot([xstim(x), xsham(x)], [leftstimPMBD(x),leftshamPMBD(x)],'k') 
%     end
    
    %make mean dots and errorbars
    m = bootstrp(1000,@mean,PMBD_lateralization_tvns)-repmat(mean(PMBD_lateralization_tvns,2)',[1000 1]);
    plot(1.5,mean(PMBD_lateralization_tvns),'b.','MarkerSize',40)
    errorbar(1.5,mean(PMBD_lateralization_tvns),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    m = bootstrp(1000,@mean,PMBD_lateralization_sham)-repmat(mean(PMBD_lateralization_sham,2)',[1000 1]);
    plot(2.15,mean(PMBD_lateralization_sham),'r.','MarkerSize',40)
    errorbar(2.15,mean(PMBD_lateralization_sham),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    xstim = 0.35+ones(length(PMBD_lateralization_tvns),1)+.3*rand(length(PMBD_lateralization_tvns),1);
    xsham = 2*ones(length(PMBD_lateralization_sham),1)+.3*rand(length(PMBD_lateralization_sham),1)
    
    
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 200 400])
    saveas(gcf,[projdir filesep 'figures/pmbdlat.svg'])
    
    
figure;hold on;title('PMBR lateralization')

    %make individual dots and lines
    scatter(xstim,PMBR_lateralization_tvns,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(xsham,PMBR_lateralization_sham,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    
%     for x = 1:length(xstim)
%        plot([xstim(x), xsham(x)], [leftstimPMBR(x),leftshamPMBR(x)],'k') 
%     end
    
    %make mean dots and errorbars
    m = bootstrp(1000,@mean,PMBR_lateralization_tvns)-repmat(mean(PMBR_lateralization_tvns,2)',[1000 1]);
    plot(1.5,mean(PMBR_lateralization_tvns),'b.','MarkerSize',40)
    errorbar(1.5,mean(PMBR_lateralization_tvns),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    m = bootstrp(1000,@mean,PMBR_lateralization_sham)-repmat(mean(PMBR_lateralization_sham,2)',[1000 1]);
    plot(2.15,mean(PMBR_lateralization_sham),'r.','MarkerSize',40)
    errorbar(2.15,mean(PMBR_lateralization_sham),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    xstim = 0.35+ones(length(PMBR_lateralization_tvns),1)+.3*rand(length(PMBR_lateralization_tvns),1);
    xsham = 2*ones(length(PMBR_lateralization_sham),1)+.3*rand(length(PMBR_lateralization_sham),1)
    
    
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 200 400])
    saveas(gcf,[projdir filesep 'figures/PMBRlat.svg'])
   
%% make figure V1: show source and sensor level spectra for visual task
t = -3:.05:3;
f = 2.^(log2(30):.125:log2(60));

vizsourcesham = [sourcespectra(:).Sham];
vizsenssham = [sensspectra(:).Sham];
vizsourcestim = [sourcespectra(:).Stim];
vizsensstim = [sensspectra(:).Stim];

figure; hold on;set(gcf,'Position',[0 0 1000 600])
        set(gca,'fontsize',12,'FontWeight','bold')

        xlim([-1,2])
        ylabel('gamma power [dB]')
        xlabel('peri-stimulus time [s]')
        plot(t,mean(vizsenssham,2),'--r','LineWidth',2)
        plot(t,mean(vizsourcesham,2),'-r','LineWidth',2)
        plot(t,mean(vizsensstim,2),'--b','LineWidth',2)
        plot(t,mean(vizsourcestim,2),'-b','LineWidth',2)
        legend({'sensor/sham','source/sham','sensor/tVNS','source/tVNS'})
        
        saveas(gcf,[projdir filesep 'figures/visual_timecourse.svg'])
        
        
%% make figure V1b: show stim-sham difference + CI        
        
        
figure; hold on;set(gcf,'Position',[0 0 1000 600])
        set(gca,'fontsize',12,'FontWeight','bold')
        plot(t,zeros(length(t)),'--k')
        xlim([-1,2])
        ylabel('gamma power [dB]')
        xlabel('peri-stimulus time [s]')
        title('taVNS-sham difference')
        y=vizsourcestim-vizsourcesham;
        r=plot(t,mean(y,2),'k','LineWidth',2)
        m = bootstrp(1000,@mean,y')-repmat(mean(y,2)',[1000 1]);
        upper = mean(y,2)'+quantile(m,.975);
        lower = mean(y,2)'+quantile(m,.025);
        fill([t,fliplr(t)],[upper,fliplr(lower)], 'k','FaceAlpha',0.5, 'EdgeAlpha',0)

        saveas(gcf,[projdir filesep 'figures/visual_timecourse_difference.svg'])



%% make figure 1c: extract individual gamma values
shamgammavals = mean(vizsourcesham(nearest(t,0):nearest(t,1),:),1);
stimgammavals = mean(vizsourcestim(nearest(t,0):nearest(t,1),:),1);

figure;hold on;title('Gamma response')
    m = bootstrp(1000,@mean,stimgammavals)-repmat(mean(stimgammavals,2)',[1000 1]);
    plot(1.5,mean(stimgammavals),'b.','MarkerSize',40)
    errorbar(1.5,mean(stimgammavals),quantile(m,.025),quantile(m,.975), 'b','LineWidth',3)
    
    
    
    m = bootstrp(1000,@mean,stimgammavals)-repmat(mean(stimgammavals,2)',[1000 1]);
    plot(2.15,mean(stimgammavals),'r.','MarkerSize',40)
    errorbar(2.15,mean(stimgammavals),quantile(m,.025),quantile(m,.975), 'r','LineWidth',3)
    scatter(0.35+ones(length(stimgammavals),1)+.3*rand(length(stimgammavals),1),stimgammavals,100,'.b','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    scatter(2*ones(length(stimgammavals),1)+.3*rand(length(stimgammavals),1),stimgammavals,100,'.r','MarkerFaceAlpha',.3, 'MarkerEdgeAlpha',.3)
    xticks([1.5,2.15])
    set(gca,'XTickLabel',{'tVNS','sham'},'fontsize',12,'FontWeight','bold')
    xlim([1.25,2.4])
    set(gcf,'Position',[0 0 300 600])

saveas(gcf,[projdir filesep 'figures/individual_gammavals.svg'])


csvwrite('shamgammavals.csv', shamgammavals)
csvwrite('stimgammavals.csv', stimgammavals)
