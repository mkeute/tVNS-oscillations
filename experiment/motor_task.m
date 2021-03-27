function [] = motor_task()
% settings_vis = scenario_settings_vis([]);
%%
ntrl = 48;

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

global settings_vis;
PsychDefaultSetup(2); 
% PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 2);
screenid = max(Screen('Screens')); % set screen 
Screen('Preference', 'VisualDebugLevel', 3);
[win, rect] = Screen('OpenWindow', screenid, [], []);%[0 0 640 480]);
white = WhiteIndex(screenid);
black = BlackIndex(screenid);
Screen('TextFont',win, 'Courier New');
Screen('TextStyle',win, 0);
Screen('TextSize',win, 17);
[width, height] = Screen('WindowSize', win);
centerX = width/2;
centerY = height/2;
Screen('FillRect', win, white )
Screen(win, 'DrawText','Zeigt der Pfeil nach links oder rechts?', centerX-300, centerY-70, black, white)
Screen(win, 'DrawText','Weiter mit Taste von aussen (LEERTASTE).', centerX-300, centerY+50,black, white)
Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])

Screen(win, 'Flip');
WaitSecs(2)
% admin_key('Space', 'Escape');

rs = Screen('Resolution', screenid);
head = [rs.width*0.5,rs.height*0.5];
width = round(rs.height/25);
rpoints = [  head-[0,width] 
            head+[0,width] 
            head+[width, 0] ];
rpoints2 = [ head+[0,width/2]
            head-[0,width/2]
            head+[-width, -width/2]
            head+[-width, width/2]
        ]
        
lpoints = [ head+[0,width] 
            head-[0,width] 
            head-[width, 0] ];
lpoints2 = [ head-[0,width/2]
            head+[0,width/2]
            head-[-width, -width/2]
            head-[-width, width/2]
        ]
        
% Screen(win, 'FillPoly', [0 0 0], rpoints)
% Screen(win, 'FillPoly', [0 0 0], rpoints2)
% Screen(win, 'Flip');
% 
% Screen(win, 'FillPoly', [0 0 0], lpoints)
% Screen(win, 'FillPoly', [0 0 0], lpoints2)
% Screen(win, 'Flip');

trls = repmat([ 0 1 ], [1 24]);
trls = trls(randperm(length(trls)));


% 
% Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% 
% % image presentation rectangles
% smImSq = [0 0 250 250];
% [smallIm, ~, ~] = CenterRect(smImSq, rect);
% 
% [img, ~, alpha] = imread('Necker_cube.png');
% size(img)
% 
% img(:, :, 4) = alpha;
% texture = Screen('MakeTexture', win, img);
% 
% Screen('DrawTexture', win, texture, [], smallIm);
% Screen('Flip', win);
% block_start_time = GetSecs;
% block_response_data = [];
% i_response = 1;


for n = 1:ntrl
if trls(n) == 1  
    
try
Datapixx('SetDoutvalues', 106);
Datapixx('RegWrRd');
WaitSecs(.005);
Datapixx('SetDoutvalues', 0);
Datapixx('RegWrRd');
end

    Screen(win, 'FillPoly', [0 0 0], rpoints)
    Screen(win, 'FillPoly', [0 0 0], rpoints2)
    Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])

else
    
try    
Datapixx('SetDoutvalues', 105);
Datapixx('RegWrRd');
WaitSecs(.005);
Datapixx('SetDoutvalues', 0);
Datapixx('RegWrRd');
end

    Screen(win, 'FillPoly', [0 0 0], lpoints)
    Screen(win, 'FillPoly', [0 0 0], lpoints2)
    Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])

end    

    Screen(win, 'Flip');
    WaitSecs(.2)
%% wait for response
% KbName('UnifyKeyNames');
% acceptedKeys = [KbName('LeftControl'), KbName('RightControl')];
%  stimulusOnset = GetSecs;
%  twait = 0.05;
%   trlduration = 3;
% %  if practice
% %      blckduration = 10;
% %  end
%  Resps = [];
%  i = 1;
%  for t = 1:(trlduration / twait)
%        [keyIsDown, secs, keyCode] = KbCheck; % poll keyboard buffer
%    if keyCode(27) %KeyCode 27 is Escape, skip scenario
%        sca; break;
%    end
% %     if sum(keyCode(acceptedKeys))
% %               display(KeyCode(acceptedKeys))
% %             Resps(2,i) =  KeyTime - stimulusOnset;
% %            strResponse = KeyCode;
% %             Resps(staircase,stcindx(staircase)) = KeyCode(tarkey);
% %              hit = KeyCode(tarkey)
% 
% %             responded = 1;
% %         end%     end
% %     if isempty(isgenuine) || isgenuine(end)>.3
%     if keyIsDown
%       block_response_data(i_response, 1)= secs - block_start_time;
%       block_response_data(i_response, 2)= (keyCode(162) == 1) + 2*(keyCode(163) == 1)
%       i_response = i_response + 1;
%     end
%       %       i_response = i_response + 1;
% %     end
% %   end
%         % time between iterations of KbCheck loop
%         WaitSecs(twait);
% %         if (GetSecs - stimulusOnset) > 2
% %            responded = 1;
% %            Resps(staircase,stcindx(staircase)) = NaN;
% %         end
%  end
Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])
Screen('Flip', win);
WaitSecs(2)
%  sca;
end
