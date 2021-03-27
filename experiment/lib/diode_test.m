function diode_test(cfg)

%% Open Screen

cfg = scenario_settings_vis(cfg);

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

[win] = PsychImaging('OpenWindow', screenid, black, rect, 32, 2);

[width, height] = Screen('WindowSize', win);
centerX = width/2;
centerY = height/2;
white = WhiteIndex(win);
black = BlackIndex(win);
textsize = 20;
HideCursor;

Screen('FillRect', win, black )
Screen(win,'TextSize', textsize);
Screen(win,'TextFont','Arial');
Screen(win,'TextStyle',1);

%% hello and instruction
Screen(win, 'DrawText','Dies ist nur ein Test der Stimulation', centerX-200, centerY-100, white, black)
Screen(win, 'DrawText','Weiter mit Taste von aussen (LEERTASTE).', centerX-200, centerY+50,white, black)
Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 3);
Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 3);
Screen('Flip', win);

% wait for admin key
admin_key('Space', 'Escape');

%% set trigger line to zero to be sure
% initialize port
port = cfg.port;
iOObj = sendTrigger(port);
sendTrigger(port,iOObj,0);

%% display 1 screen to check diode location
%% 1.fixation screen
% build new screen
Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 3);
Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 3);
Screen(win, 'DrawText','Weiter mit Taste von aussen (LEERTASTE).', centerX-200, centerY+50,white, black)
% photo diode square
Screen('FillRect',win, white, cfg.diodeloc);
Screen('Flip', win);

WaitSecs(2);
% wait for admin key
admin_key('Space', 'Escape');

%% blockende
sca






