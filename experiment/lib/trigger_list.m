function trigger = trigger_list(trigger_name)


% TRIGGER_LIST(tigger_name)
% contains all triggers for bistable design
%



switch trigger_name
  case 'gabor_start'
    trigger = 74;
  case 'gabor_stop'
    trigger = 75;
  case 'gabor'
    trigger = 100; % this is to add to the tiggers in script
  case 'rand_sound_start'
    trigger = 174;
  case 'rand_sound_stop'
    trigger = 175;
  case 'rand_sound'
  trigger = 200; % this is to add
  case 'visual_start'
    trigger = 64;
  case 'visual_stop'
    trigger = 65;
  case 'visual'
    trigger = 12;
  case 'auditory_start'
    trigger = 164;
  case 'auditory_stop'
    trigger = 165;
  case 'auditory'
    trigger = 22;
  case 'resting_start1'
    trigger = 1;
  case 'resting_stop1'
    trigger = 2;
  case 'resting_start2'
    trigger = 3;
  case 'resting_stop2'
    trigger = 4;
end

