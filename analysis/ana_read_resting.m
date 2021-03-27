function restdat = ana_read_resting(event, fname)

                try
                    resting0 = [event(ismember([event(:).value], [101,37])).sample];
                    resting1 = [event(ismember([event(:).value], [102, 38])).sample];
                    if isempty(resting0)
                        restdat = NaN;
                        return
                    end
                catch
                    fclose(fopen([tmp{1} '_triggerwarning.txt'], 'w'));
                    restdat = NaN;
                    return
                end
                dur = resting1-resting0;
                if any(dur < 170000) | any(dur > 200000)
                    fclose(fopen([tmp{1} '_resting_durationwarning.txt'], 'w'));
                    restdat = NaN;
                    return
                end

                restingtrl = [];
                nseg = 60;
                i = 0;
                seglen = 180000/nseg;
                for r = 1:length(resting0)
                    for seg = 1:nseg
                        i = i+1;
                        restingtrl(i,1) = resting0(r)+(seg-1)*seglen;
                        restingtrl(i,2) = restingtrl(i,1)+seglen;
                        restingtrl(i,3) = 0;
                        restingtrl(i,4) = r;
                        restingtrl(i,5) = i;

                    end
                end
            
                restingtrl(:,2) = restingtrl(:,2)-1;

                cfgp         = [];
                cfgp.trl   = restingtrl;
                cfgp.dataset = fname;
                cfgp.channel = 'MEG';
                cfgp.gradscale   = 0.04;
                cfgp.hpfilter   = 'yes';
                cfgp.hpfreq     = 0.7;
                cfgp.hpfilttype = 'firws';
                cfgp.hpfiltdir  = 'onepass-zerophase';
                cfgp.hpfiltwintype = 'kaiser';
                cfgp.lpfilter   = 'yes';
                cfgp.lpfreq     =  150;
                cfgp.lpfiltdf   =  30;
                cfgp.lpfilttype = 'firws';
                cfgp.lpfiltdir  = 'onepass-zerophase';
                cfgp.lpfiltwintype = 'kaiser';
                cfgp.dftfilter = 'yes'; % line noise removal using discrete fourier transform (default = 'no')
                cfgp.dftfreq = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])

                restdat = ft_preprocessing(cfgp);
