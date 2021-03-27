function [] = visual_task()
global settings_vis;
cfg = scenario_settings_vis([]);
ntrls = 48;
KbName('UnifyKeyNames');
acceptedKeys = [KbName('LeftControl'), KbName('RightControl')];

% if cfg.debug == 1 % window mode
%   rect = CenterRect([0 0 1440 900], Screen(Screen_Number,'Rect'));
%   rect = [0 0 800 400];
% else
  rect = [];
% end
% global logfile;
PsychDefaultSetup(2);
% Determine the values of black and white
% PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 2);
screenid =max(Screen('Screens'));
% Screen('OpenWindow', screenid, [], [0 0 640 480]);
black = BlackIndex(screenid);
white = WhiteIndex(screenid);
% background color
backgrd = (black+white)/2;
[win] = PsychImaging('OpenWindow', screenid, backgrd, rect, 32, 2);
Screen('TextFont',win, 'Courier New');
Screen('TextStyle',win, 0);
Screen('TextSize',win, 17);


[width, height] = Screen('WindowSize', win);
centerX = width/2;
centerY = height/2;

% HideCursor;
% 
% Screen('FillRect', win, backgrd )



%% threshold estimation parameters
% st.chance_level = .5;
% gabor_threshold = (0.5 * (1 - st.chance_level)) + st.chance_level; %will be .75, since .5 is chance probability

% if practice == 1
%     st.n_threshold_trials = 6
% else
%     st.n_threshold_trials = 2%settings_vis.n_gabor_trls; % n trls for both staircases
% end
%     
% startangdiff = 5; % start value, arbitrary
% gabor_tGuess_difference = log10(startangdiff); % do the logarithm
% gabor_tGuess(1) = gabor_tGuess_difference * 0.2; % and split into two staircases
% gabor_tGuess(2) = gabor_tGuess_difference * 1.3; 
% 
% gabor_quest_1 = QuestCreate(gabor_tGuess(1), 1.25, gabor_threshold, 3.5, 0.01, st.chance_level); %create Weibull PDF
% gabor_quest_1.normalizePdf=1;
% 
% gabor_quest_2 = QuestCreate(gabor_tGuess(2), 1.25, gabor_threshold, 3.5, 0.01, st.chance_level); %create Weibull PDF
% gabor_quest_2.normalizePdf = 1;
% 
% half_n_threshold_trials = round(st.n_threshold_trials / 2);
% 
% gabor_trlorder = [ones(1, half_n_threshold_trials) 2*ones(1, half_n_threshold_trials)];
% gabor_trlorder = gabor_trlorder(randperm(st.n_threshold_trials));



rs = Screen('Resolution', screenid);

%% hello and instruction
Screen(win, 'DrawText','Aufgabe 1:', centerX-300, centerY-100, white, black)
Screen(win, 'DrawText','Schauen Sie auf den Fixationspunkt', centerX-300, centerY-70, white, black)
Screen(win, 'DrawText','Weiter mit Taste von aussen (LEERTASTE).', centerX-300, centerY+50,white, black)
Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])
      Screen('Flip', win);

 % wait for admin key
WaitSecs(2);
% admin_key('Space', 'Escape');
                 
% Screen(win, 'DrawText','Starten mit beliebiger Taste.', centerX-200, centerY,white, black)
Screen('FillRect',win, black, cfg.diodeloc);
Screen('Flip', win);
WaitSecs(.2)
% KbWait

% %% define grating
% % Dimension of the region where will draw the Gabor in pixels
% gaborDimPix = windowRect(4) / 2;
% 
% % Sigma of Gaussian
% sigma = 0;
% 
% % Obvious Parameters
% orientation = 0;
% contrast = 1;
% aspectRatio = 1.0;
% phase = 0;
% 
% % Spatial Frequency (Cycles Per Pixel)
% % One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
% numCycles = 5;
% freq = numCycles / gaborDimPix;
% 
% % Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% % we set a grey background offset, disable normalisation, and set a
% % pre-contrast multiplier of 0.5.
% % For full details see:
% % https://groups.yahoo.com/neo/groups/psychtoolbox/conversations/topics/9174
% backgroundOffset = [0.5 0.5 0.5 0.0];
% disableNorm = 1;
% preContrastMultiplier = 0.5;
% gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
%     backgroundOffset, disableNorm, preContrastMultiplier);

%% define a few gabor things
% Phase of underlying sine grating in degrees:
phase = 0;
% Spatial constant of the exponential "hull"
sc = 10.0;
% gabor width and height in pixels
gw = round(2/25 * rs.height);
gh = round(2/25 * rs.height);
% Frequency of sine grating:
numCycles = 24;
freq = numCycles / gw;% Aspect ratio width vs. height:
aspectratio = 1.0;

% angle array
ang1 = 0;

% position if desired (prints rectangle).
gabPos = [centerX-300 centerY-300 centerX+300 centerY+300];

% Contrast of grating:
contrast = 1000;

% circle definition
circlepos = gabPos;
circlecol = 40;

%% create gabor 
gabortex = CreateProceduralGabor(win, gw, gh, 0);


%% iterate over trls
for i = 1:ntrls
%     i_mod = mod(i, st.n_threshold_trials) + 1;
    
% 	if(gabor_trlorder(i) == 1)
% 		gabor_att_dB = QuestQuantile(gabor_quest_1); %get a recommendation
%     else
% 		gabor_att_dB = QuestQuantile(gabor_quest_2); %get a recommendation
% 	end;
%     
%       ang1 = randi([35, 55]);
%       
%       sgn = -1 + 2* (rand > .5); % randomly either -1 or 1, leading to clockwise or counterclockwise rotation
%       ang2 = ang1 + sgn * (10 ^ gabor_att_dB);
%       
%       if abs(ang2 - ang1) > 15
%           ang2 = ang1 + sgn * 15;
%       end
%       
%       if sgn < 1
%           tarkey = KbName('RightControl');
%       else
%           tarkey = KbName('LeftControl');
%       end

      %% 1.fixation screen
      % build new screen with fixation cross
        Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])
      % photo diode square
      Screen('FillRect',win, black, cfg.diodeloc);
      Screen('Flip', win);
%       WaitSecs(1);
%       % flip to fixation cross
%       Screen('Flip', win);



      %% First grating
      Screen('FillRect', win, black )

%       Screen('FillOval', win,circlecol, circlepos);
      Screen('DrawTexture', win, gabortex, [],gabPos,ang1, [], [], [], [], kPsychDontDoRotation, [phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
            Screen('FillOval',win,[.9 .05 .05],[(rs.width/2-6) (rs.height/2-6) (rs.width/2+6) (rs.height/2+6)])

      %   Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 2);
    %   Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 2);
    %   % photo diode square
    %   Screen('FillRect',win, white, cfg.diodeloc);
    try
    Datapixx('SetDoutvalues', 103);
    Datapixx('RegWrRd');
    WaitSecs(.005);
    Datapixx('SetDoutvalues', 0);
    Datapixx('RegWrRd');
    end
       Screen('Flip', win);
      % wait for 0.35-0.55 sec (slight jitter to avoid alpha entrainment)
      WaitSecs(1);

%       Screen('FillRect', win, black )
try
      Datapixx('SetDoutvalues', 104);
        Datapixx('RegWrRd');
        WaitSecs(.005);
        Datapixx('SetDoutvalues', 0);
        Datapixx('RegWrRd');
end     
      Screen('Flip', win);
    %   Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 3);
    %   Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 3);
    %   Screen('Flip', win);
      WaitSecs(2+rand*0.5); %ISI is jittered between 2000 and 2500 ms
  
  
%       %% second grating
%    Screen('FillRect', win, black )
%       Screen('FillOval', win,circlecol, circlepos);
% 
%     Screen('DrawTexture', win, gabortex, [],gabPos,ang2, [], [], [], [], kPsychDontDoRotation, [phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
%      Screen('Flip', win);
% 
%     WaitSecs(0.35);
%   % show gabor
% 
%   Screen('FillRect', win, black )
%   Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 3);
%   Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 3);
% 
%    Screen('Flip', win);
% 
% %% wait for response
%   %   Screen('Flip', win);
%   stimulusOnset = GetSecs;
%   responded = 0;
%     while responded == 0
%       
%         [tmp,KeyTime,KeyCode] = KbCheck;
%         if KeyCode(27) %KeyCode 27 is Escape, skip scenario
%             sca; break;
%         end
%         if sum(KeyCode(acceptedKeys))
%               display(KeyCode(acceptedKeys))
% %             Resps(2,i) =  KeyTime - stimulusOnset;
% %            strResponse = KeyCode;
% %             Resps(staircase,stcindx(staircase)) = KeyCode(tarkey);
%              hit = KeyCode(tarkey)
% 
%             responded = 1;
%         end
%         % time between iterations of KbCheck loop
%         WaitSecs(0.001);
%         
%        if GetSecs - stimulusOnset > 2
%            hit = 0;
%            Screen(win, 'DrawText','SCHNELLER!', centerX-30, centerY, white, black)
%            Screen('Flip', win);
%            WaitSecs(.5);
%            break;
%        end
% %         if (GetSecs - stimulusOnset) > 2
% %            responded = 1;
% %            Resps(staircase,stcindx(staircase)) = NaN;
% %         end
%     end
%   
%   if practice == 1
%       if hit == 1
%       Screen(win, 'DrawText','RICHTIG!', centerX, centerY, white, black)
%       Screen('Flip', win);
%       WaitSecs(0.6);
% 
%       elseif hit == 0
%       Screen(win, 'DrawText','FALSCH!', centerX, centerY, white, black)
%       Screen('Flip', win);
%       WaitSecs(0.6);
% 
%       end
%   end
% %     while (signal_detection(2) < 0) %repaet trial immediately if no response occur
% %         [hit, signal_detection, trial_interval_times] = run_trial(window, signal, standard, ['pt_' num2str(i) '_' num2str(gabor_wq_trials(i_mod)) '_' num2str(gabor_att_dB)]);
% %         disp(['(' num2str(i) ') quest: ' num2str(gabor_wq_trials(i_mod)) '; hit: ' num2str(hit) '; dB: ' num2str(gabor_att_dB)]);
% %     end;
% %     
%         if(gabor_trlorder(i) == 1)
%             gabor_quest_1 = QuestUpdate(gabor_quest_1, gabor_att_dB, hit);
%         else
%             gabor_quest_2 = QuestUpdate(gabor_quest_2, gabor_att_dB, hit);
%         end;
% %     
% %     ext_subject_pt_threshold_data = [ext_subject_pt_threshold_data; gabor_wq_trials(i) gabor_att_dB hit signal_detection trial_interval_times];
% %     
% %     if(i == st.n_threshold_trials)
% %         my_scenario_text.left_text(my_scenario_text.pause_short, st.s_pause);
% %         my_scenario_text.confirm_text(my_scenario_text.continue_text);
% %         my_scenario_text.attentional_countdown();
% %         gabor_wq_trials = create_shuffle_quest_trials_array();
% %         Screen('TextSize', window, st.text_size_big);
% %     end;
%       WaitSecs(1 + rand*0.600);

end
% 
% gabor_log.threshold_quest_1 = gabor_quest_1;
% gabor_log.threshold_quest_2 = gabor_quest_2;
% global thresh
% thresh(1) = QuestMean(gabor_quest_1);
% thresh(2) = QuestMean(gabor_quest_2);
% 
% gabor_log.gabor_threshold_quest_1 = thresh(1);
% gabor_log.gabor_threshold_quest_2 = thresh(2);
% gabor_log.stc1 = QuestTrials(gabor_quest_1);
% gabor_log.stc2 = QuestTrials(gabor_quest_2);
% 
% gabor_log.checktrls = [];
% for m = 1:20
% %     i_mod = mod(i, st.n_threshold_trials) + 1;
%         
%       ang1 = randi([35, 55]);
%       
%       sgn = -1 + 2* (rand > .5); % randomly either -1 or 1, leading to clockwise or counterclockwise rotation
%       ang2 = ang1 + sgn * (10 ^ mean(thresh));
%       gabor_log.checktrls(1,m) = sgn;
% 
%       
%       if sgn < 1
%           tarkey = KbName('RightControl');
%       else
%           tarkey = KbName('LeftControl');
%       end
% 
%       %% 1.fixation screen
%       % build new screen
%       Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 3);
%       Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 3);
%       % photo diode square
%       Screen('FillRect',win, black, cfg.diodeloc);
%       Screen('Flip', win);
%       WaitSecs(1);
%       % flip to fixation cross
%       Screen('Flip', win);
% 
% 
% 
%       %% First grating
%       Screen('FillRect', win, black )
% 
%       Screen('FillOval', win,circlecol, circlepos);
%       Screen('DrawTexture', win, gabortex, [],gabPos,ang1, [], [], [], [], kPsychDontDoRotation, [phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
%     %   Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 2);
%     %   Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 2);
%     %   % photo diode square
%     %   Screen('FillRect',win, white, cfg.diodeloc);
%        Screen('Flip', win);
%       % wait for 0.35-0.55 sec (slight jitter to avoid alpha entrainment)
%       WaitSecs(0.35);
% 
%       Screen('FillRect', win, black )
%       Screen('Flip', win);
%     %   Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 3);
%     %   Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 3);
%     %   Screen('Flip', win);
%       WaitSecs(0.6+rand*0.2); %ISI is jittered between 600 and 800 ms
%   
%   
%       %% second grating
%    Screen('FillRect', win, black )
%       Screen('FillOval', win,circlecol, circlepos);
% 
%     Screen('DrawTexture', win, gabortex, [],gabPos,ang2, [], [], [], [], kPsychDontDoRotation, [phase, freq, sc, contrast, aspectratio, 0, 0, 0]);
%      Screen('Flip', win);
% 
%     WaitSecs(0.35);
%   % show gabor
% 
%   Screen('FillRect', win, black )
%   Screen('DrawLine', win, [0.8 0.05 0.05], centerX-10 , centerY, centerX+10, centerY, 3);
%   Screen('DrawLine', win, [0.8 0.05 0.05], centerX , centerY-10, centerX, centerY+10, 3);
% 
%    Screen('Flip', win);
% 
% %% wait for response
%   %   Screen('Flip', win);
%   stimulusOnset = GetSecs;
%   responded = 0;
%     while responded == 0
%       
%         [tmp,KeyTime,KeyCode] = KbCheck;
%         if KeyCode(27) %KeyCode 27 is Escape, skip scenario
%             sca; break;
%         end
%         if sum(KeyCode(acceptedKeys))
%               display(KeyCode(acceptedKeys))
% %             Resps(2,i) =  KeyTime - stimulusOnset;
% %            strResponse = KeyCode;
% %             Resps(staircase,stcindx(staircase)) = KeyCode(tarkey);
%              hit = KeyCode(tarkey)
%              gabor_log.checktrls(2,m) = hit;
%             responded = 1;
%         end
%         % time between iterations of KbCheck loop
%         WaitSecs(0.001);
% %         if (GetSecs - stimulusOnset) > 2
% %            responded = 1;
% %            Resps(staircase,stcindx(staircase)) = NaN;
% %         end
%     end
%   
%   
% %     while (signal_detection(2) < 0) %repaet trial immediately if no response occur
% %         [hit, signal_detection, trial_interval_times] = run_trial(window, signal, standard, ['pt_' num2str(i) '_' num2str(gabor_wq_trials(i_mod)) '_' num2str(gabor_att_dB)]);
% %         disp(['(' num2str(i) ') quest: ' num2str(gabor_wq_trials(i_mod)) '; hit: ' num2str(hit) '; dB: ' num2str(gabor_att_dB)]);
% %     end;
% %     
%  
% %     
% %     ext_subject_pt_threshold_data = [ext_subject_pt_threshold_data; gabor_wq_trials(i) gabor_att_dB hit signal_detection trial_interval_times];
% %     
% %     if(i == st.n_threshold_trials)
% %         my_scenario_text.left_text(my_scenario_text.pause_short, st.s_pause);
% %         my_scenario_text.confirm_text(my_scenario_text.continue_text);
% %         my_scenario_text.attentional_countdown();
% %         gabor_wq_trials = create_shuffle_quest_trials_array();
% %         Screen('TextSize', window, st.text_size_big);
% %     end;
%       WaitSecs(1 + rand*0.600);
% 
% end
% 
% 
% % %% block end trigger
% % WaitSecs(1);
% % sendTrigger(port,iOObj,trigger_list('gabor_stop'));
% % WaitSecs(.010);% trigger time
% % sendTrigger(port,iOObj,0);
% 
% clear thresh;
% sca;
end






