clearvars;
close all;

%% paths
% cd(uigetdir);

addpath(genpath(cd));
 addpath(genpath('X:\Eigene Dateien\MATLAB\Psychtoolbox'))
 addpath('X:\Eigene Dateien\MATLAB\Psychtoolbox\Psychtoolbox\PsychBasic\MatlabWindowsFilesR2007a')
% addpath(pathdef) % to add PTB
% addpath(genpath('stim_audit/'))
% addpath('stim_vis/')
% addpath('lib')
% % get input output stuff
% addpath('D:\Program Files\inpout\64bit')

%% flush ptb
sca;
%% get sub specific stuff
answer = {};

while isempty(answer) || strcmp(answer{1}, '') == 1
  prompt = {'Laufende Probandennummer'};
  dlg_title = 'Probandencode generieren';
  num_lines = 1;
  defaultans = {''};
  
  answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
end

% if length(answer{1}) ~= 3 | isempty(str2num(answer{1})) | ~ismember(answer{2}, {'t', 's'})
%     error('check your answers and start again')
% end
%% determine order of tasks
rng(str2num(answer{1}))
r = rand;

% %% just make sure that the first input follows the format (01, 02, etc) and adjust blocknr if given
% answer{1} = num2str(str2double(answer{1}), '%02d');
% if ~isempty(answer{3})
%   answer{3} = num2str(str2double(answer{3})+1);
% end
%% subject info, mostly for sfm scenario
% subject_info = cell(7, 2);
% subject_info{1, 1} = 'subject_number';
% subject_info{1, 2} = answer{1};
% subject_info{2, 1} = 'date';
% subject_info{2, 2} = datestr(date());
% subject_info{5, 1} = 'subject_code';
% subject_info{5, 2} = upper([subject_info{1, 2} '_' subject_info{2, 2} '_bsp']);
% subject_info{6, 1} = 'stim';
% subject_info{6, 2} = answer{2};
% subject_info{7, 1} = 'pre/post';
% subject_info{7, 2} = answer{3};
% 
% subjcode = upper([subject_info{1, 2} '_' subject_info{2, 2} '_' subject_info{6, 2} '_bsp']);

% results = struct;
% results.subjinfo = subject_info;
% results.gabor = [];
% results.sfm = [];
% results.necker = [];
%% get stuff we might need
global settings_vis;
settings_vis = scenario_settings_vis([]);
% % settings_vis.num_blocks = 3;
% settings_vis.s_block_duration = 180;
% settings_vis.n_gabor_trls = 80
% create a base random seed
% number created from date, subject number, and sex
% rng_seed = sum([datenum(subject_info{2, 2}) str2double(subject_info{1, 2}) double(subject_info{6, 2})]);


%% get start block

% %% check the diode location
% if min(blockArray) == 1
%    diode_test(settings_vis);
% end


%% now start
cycleduration = 5
       resting_state
         run_tVNS(cycleduration, 1, 15)
      
       resting_state
       run_tVNS(cycleduration, 0, 1)
       resting_state
       run_tVNS(cycleduration, 0, 1)

   if r >= .5
       visual_task
       run_tVNS(cycleduration, 0, 1)
       visual_task
       run_tVNS(cycleduration, 0, 1)
       motor_task
       run_tVNS(cycleduration, 0, 1)
       motor_task
   else  
       motor_task       
       run_tVNS(cycleduration, 0, 1)
       motor_task
       run_tVNS(cycleduration, 0, 1)
       visual_task
       run_tVNS(cycleduration, 0, 1)
       visual_task
   end    
      

sca;