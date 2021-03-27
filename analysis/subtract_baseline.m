function outfreq = subtract_baseline(infreq, window)

ix1 = nearest(infreq.time, window(1));
ix2 = nearest(infreq.time, window(2));

bl = nanmean(infreq.powspctrm(:,:,:,ix1:ix2),4); 
%         %% check bl duration!
blmat = repmat(bl, [1 1 1 size(infreq.powspctrm,4)]);

outfreq = infreq;
outfreq.powspctrm = outfreq.powspctrm-blmat;
        