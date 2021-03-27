function motordat = ana_read_motor(fname)
                try 
                    load([fname '_event.mat'], 'event')
                catch
                    event = ft_read_event(fname)
                    save([fname '_event.mat'], 'event')
                end
                try
                    leftarrow = find(ismember([event(:).value], [105,41]) & strcmp({event(:).type},'Trigger'));
                    rightarrow = find(ismember([event(:).value], [106, 42]) & strcmp({event(:).type},'Trigger'));
                    
                    leftresps = nan*ones(length(leftarrow),6); %make empty array. First three cols will be trial definition, fourth col will be trial index, fifth will be RT, sixth will be response value.
                    for l = 1:length(leftarrow)
                       ix = leftarrow(l)+1;

                       while ix < length(event) & ~ismember(event(ix).value, [105,41,106,42]) & ~strcmp(event(ix).type, 'STI102')
                           ix = ix+1;
                       end

                       leftresps(l,4) = l;
                       leftresps(l,6) = event(ix).value;
                       if strcmp(event(ix).type, 'STI102')                      
                           leftresps(l,1) = event(ix).sample-3000;
                           leftresps(l,2) = event(ix).sample+3000;
                           leftresps(l,3) = -3000;

                           leftresps(l,5) = event(ix).sample - event(leftarrow(l)).sample;
                       end
                       
                    end
                    
                   
                    
                    rightresps = nan*ones(length(rightarrow),6); %make empty array. First col will be trial index, second col will be response timestamp, third will be RT, fourth will be response value.
                    for l = 1:length(rightarrow)
                       ix = rightarrow(l)+1;
                       while ix < length(event) & ~ismember(event(ix).value, [105,41,106,42]) & ~strcmp(event(ix).type, 'STI102')
                           ix = ix+1;
                       end

                       rightresps(l,4) = l;
                       rightresps(l,6) = event(ix).value;
                       if strcmp(event(ix).type, 'STI102')                      
                           rightresps(l,1) = event(ix).sample-3000;
                           rightresps(l,2) = event(ix).sample+3000;
                           rightresps(l,3) = -3000;

                           rightresps(l,5) = event(ix).sample - event(rightarrow(l)).sample;
                       end
                       
                    end
                    
                %%    
                    
                    %TODO: check for wrong responses
                    %TODO: visual inspection, ICA
                    %TODO: check for beta modulation
                    %TODO: source projection
                    %TODO: cut segments, return segmented data
                    
                    

                catch
                    fclose(fopen([tmp{1} '_motor_triggerwarning.txt'], 'w'));
                    motordat = NaN;
                    return
                end
%                 if any(dur < 170000) | any(dur > 200000)
%                     fclose(fopen([tmp{1} '_motor_durationwarning.txt'], 'w'));
%                     motordat = NaN;
%                     return
%                 end

                hdr = ft_read_header(fname)

                motortrl = [leftresps; rightresps];
                motortrl(isnan(motortrl(:,1)) | motortrl(:,2) > hdr.nSamples,:) = [];
                if isempty(motortrl)
                    motordat = NaN;
                    return
                end
                cfgp         = [];
                cfgp.trl   = motortrl;
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
                motordat = ft_preprocessing(cfgp);
