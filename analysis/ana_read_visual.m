function visualdat = ana_read_visual(fname)

                try 
                    load([fname '_event.mat'], 'event')
                catch
                    event = ft_read_event(fname)
                    save([fname '_event.mat'], 'event')
                end
                try
                    gratings = find(ismember([event(:).value], [103, 39]) & strcmp({event(:).type},'Trigger'));
                    
                    trls = nan*ones(length(gratings),5); %make empty array. First three cols will be trial definition, fourth col will be trial index, fifth will be RT, sixth will be response value.
                    for l = 1:length(gratings)
                        ix = gratings(l);
                       trls(l,1) = event(ix).sample-5000;
                       trls(l,2) = event(ix).sample+5000;
                       trls(l,3) = -5000;
                       trls(l,4) = l;
                       trls(l,5) = event(ix).value;

                    end
                    
                   
                    

                    
                %%    
                    
                    %TODO: visual inspection, ICA
                    %TODO: check for beta modulation
                    %TODO: source projection
                    %TODO: cut segments, return segmented data
                    
                    

                catch
                    fclose(fopen([tmp{1} '_visual_triggerwarning.txt'], 'w'));
                    motordat = NaN;
                    return
                end
%                 if any(dur < 170000) | any(dur > 200000)
%                     fclose(fopen([tmp{1} '_motor_durationwarning.txt'], 'w'));
%                     motordat = NaN;
%                     return
%                 end

                hdr = ft_read_header(fname)
                trls(trls(:,2) > hdr.nSamples,:) = [];
                cfgp         = [];
                cfgp.trl   = trls;
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
                visualdat = ft_preprocessing(cfgp);
