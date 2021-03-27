function resting_state()
try
Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');
    
    % Configure digital input system for monitoring button box
    Datapixx('EnableDinDebounce');                          % Debounce button presses
    Datapixx('SetDinLog');                                  % Log button presses to default address
    Datapixx('StartDinLog');                                % Turn on logging
    Datapixx('RegWrRd');
end
cfg = scenario_settings_vis();

if cfg.debug == 1 % window mode
  % rect = CenterRect([0 0 1440 900],Screen(Screen_Number,'Rect'));
  rect = [0 0 800 400];
else
  rect = [];
end

PsychDefaultSetup(2);
% PsychDebugWindowConfiguration
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
% HideCursor;

Screen('FillRect', win, (black+white)/2 )
Screen(win,'TextSize', textsize);
Screen(win,'TextFont','Arial');
Screen(win,'TextStyle',1);

% %% initialize port
% port = cfg.port;
% iOObj = sendTrigger(port);
rs = Screen('Resolution', screenid);


%% hello and instruction
Screen(win, 'DrawText','Nun werden 3 min Ruhe-MEG gemessen', centerX-200,centerY-120, white, black)
Screen(win, 'DrawText','Bitte schauen Sie immer auf die Mitte des Bildschirms (roter Punkt)', centerX-200,centerY-90, white, black)
Screen(win, 'DrawText','und denken Sie an nichts bestimmtes', centerX-200, centerY-60, white, black)
Screen(win, 'DrawText','Weiter mit Taste von aussen (LEERTASTE).', centerX-200, centerY+50,white, black)
Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])
Screen('FillRect',win, black, cfg.diodeloc);
Screen('Flip', win);

% wait for admin key
admin_key('Space', 'Escape');
 
% % start trigger
% sendTrigger(port,iOObj, trigger_list(['resting_start' num2str(restn)]));
% WaitSecs(.020);% trigger time
% sendTrigger(port,iOObj,0);
%% Datapixx stuff



%% fixation screen
% Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 3);
% Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 3);

Screen('FillRect',win, black, cfg.diodeloc);
% Screen(win,'TextSize', 1000);
% Screen(win,'TextFont','ComicSansMS');
Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])
try
Datapixx('SetDoutvalues', 101);
Datapixx('RegWrRd');
WaitSecs(.005);
Datapixx('SetDoutvalues', 0);
Datapixx('RegWrRd');
end
Screen('Flip', win);


% wait for 3 min
WaitSecs(180);
try
Datapixx('SetDoutvalues', 102);
Datapixx('RegWrRd');
WaitSecs(.005);
Datapixx('SetDoutvalues', 0);
Datapixx('RegWrRd');
end
% %% block end trigger
% sendTrigger(port,iOObj, trigger_list(['resting_stop' num2str(restn)]));
% WaitSecs(.010);% trigger time
% sendTrigger(port,iOObj,0);
% 
% WaitSecs(2);
%% Datapixx stuff


%% blockende
% DrawFormattedText(win, 'Blockende', 'center' , 'center', white);
% Screen('Flip', win);
% WaitSecs(5);


