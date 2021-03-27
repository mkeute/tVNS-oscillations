clear all

c_path = cd;

% move to PTB folder, setup, and back
PTB_path = 'D:\Program Files\MATLAB\R2009b\toolbox\Psychtoolbox\Psychtoolbox';
% PTB_path = '/Applications/psychtoolbox';
cd(PTB_path)
SetupPsychtoolbox
cd(c_path)
