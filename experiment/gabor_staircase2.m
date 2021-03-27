function gabor_staircase2(cfg)
cfg = scenario_settings_vis(cfg);
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 2);
screenid = max(Screen('Screens'));
% if cfg.debug == 1 % window mode
  % rect = CenterRect([0 0 1440 900],Screen(Screen_Number,'Rect'));
  rect = [0 0 800 400];
% else
%   rect = [];
% end
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

%% define a few gabor things
% Phase of underlying sine grating in degrees:
phase = 0;
% Spatial constant of the exponential "hull"
sc = 10.0;
% Frequency of sine grating:
freq = .15;
% Aspect ratio width vs. height:
aspectratio = 1.0;
% gabor width and height in pixels
gw = 50;
gh = 50;
% angle array
startang = 45;
startstep = 5;

% position if desired (prints rectangle)
gabPos = [centerX-200 centerY-200 centerX+200 centerY+200];

% Contrast of grating:
contrast = 40;

% circle definition
circlepos = gabPos;
circlecol = 80;

%% create gabor 
gabortex = CreateProceduralGabor(win, gw, gh, 0);


ang = startang;
step = startstep;
%% one trial: present two gabor patches rotated cw or ccw
sgns = [-1 1];
sgns = sgns(randperm(2));
trlangles = [ang, ang + sgns(1)*step];

for ang = trlangles
Screen('FillOval', win,circlecol, circlepos);
Screen('DrawTexture', win, gabortex, [],gabPos,ang, [], [], [], [], kPsychDontDoRotation, [phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
end





end