
function datall = ana_read_fif(fname)

datr = {};
cfgp         = [];
cfgp.dataset = fname;
cfgp.channel = 'MEG';
% cfgp.hpfilter   = 'yes';
% cfgp.hpfreq     = 0.7; 
% cfgp.hpfilttype = 'firws';
% cfgp.hpfiltdir  = 'onepass-zerophase';
% cfgp.hpfiltwintype = 'kaiser';
% cfgp.lpfilter   = 'yes';
% cfgp.lpfreq     =  150;
% cfgp.lpfiltdf   =  30;
% cfgp.lpfilttype = 'firws';
% cfgp.lpfiltdir  = 'onepass-zerophase';
% cfgp.lpfiltwintype = 'kaiser';
% cfgp.dftfilter = 'yes'; % line noise removal using discrete fourier transform (default = 'no')
% cfgp.dftfreq = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])


% 
hdr = ft_read_header(fname)
event = ft_read_event(fname)
datall = ft_preprocessing(cfgp)
% for i=1:hdr.nChans
%    datall.trial{1}(i,:) =  
%     
% end


% 
% 
% cfgf = [];
% cfgf.hpfilter   = 'yes';
% cfgf.hpfreq     = 0.7; 
% cfgf.hpfilttype = 'firws';
% cfgf.hpfiltdir  = 'onepass-zerophase';
% cfgf.hpfiltwintype = 'kaiser';
% cfgf.lpfilter   = 'yes';
% cfgf.lpfreq     =  150;
% cfgf.lpfiltdf   =  30;
% cfgf.lpfilttype = 'firws';
% cfgf.lpfiltdir  = 'onepass-zerophase';
% cfgf.lpfiltwintype = 'kaiser';
% cfgf.dftfilter = 'yes'; % line noise removal using discrete fourier transform (default = 'no')
% cfgf.dftfreq = [50 100 150]; % line noise frequencies in Hz for DFT filter (default = [50 100 150])
% datp = {};
% for i=1:hdr.nChans   
% cfgf.channel = i;
% datp{i} = ft_preprocessing(cfgf, datall)
% end% 
% cfgr            = [];
% cfgr.resamplefs = 300;
% datr{i}        = datp%ft_resampledata(cfgr, datp);
% 
% clear datp
% end
% 
% cfg = [];
% datall = ft_appenddata(cfg, datr{:}); % this expands all cells into input variables



% 
% sname = strsplit(fname, '.');
% sname =  [sname{1} '.mat']
% 
% save(sname, 'datall', 'event', 'hdr', '-v7.3')

