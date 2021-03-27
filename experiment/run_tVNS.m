function [] = run_tVNS(cycle, onoff, ncycles)

cfg = scenario_settings_vis();

if cfg.debug == 1 % window mode
  % rect = CenterRect([0 0 1440 900],Screen(Screen_Number,'Rect'));
  rect = [0 0 800 400];
else
  rect = [];
end

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 2);
screenid = max(Screen('Screens'));

black = BlackIndex(screenid);
white = WhiteIndex(screenid);

[win] = PsychImaging('OpenWindow', screenid, (black+white)/2, rect, 32, 2);

[width, height] = Screen('WindowSize', win);
centerX = width/2;
centerY = height/2;
white = WhiteIndex(win);
black = BlackIndex(win);
textsize = 20;
HideCursor;


Screen('FillRect', win, (black+white)/2 )
Screen(win,'TextSize', textsize);
Screen(win,'TextFont','Arial');
Screen(win,'TextStyle',1);
Screen(win, 'DrawText','Stimulation läuft', centerX-200,centerY-120, white, black)
Screen('Flip', win);



Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');
    
    % Configure digital input system for monitoring button box
    Datapixx('EnableDinDebounce');                          % Debounce button presses
    Datapixx('SetDinLog');                                  % Log button presses to default address
    Datapixx('StartDinLog');                                % Turn on logging
    Datapixx('RegWrRd');

Priority(2);
for nc = 1:ncycles
for npulse = 1:(cycle*25)
Datapixx('SetDoutvalues', 128);
Datapixx('RegWrRd');
WaitSecs(.005);
Datapixx('SetDoutvalues', 0);
Datapixx('RegWrRd');
WaitSecs(.032);
end

if onoff == 1
WaitSecs(10)
end
end
% Priority(0)
sca
end