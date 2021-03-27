function admin_key(which_key, exit_key)

% ADMIN_KEY(which_key, exit_key)
% waits for a specified key press 'which_key'
% if 'exit_key' is defined it can be used to get out of PTB


% ignore if not given
if nargin < 2
  exit_key = [];
end


%
iskeydown = 0;
while ~iskeydown
   WaitSecs(.001);
    [iskeydown, ~, key] = KbCheck;
    % first check whether exit key has been pressed
    if ~isempty(exit_key) 
      if find(key) == KbName(exit_key)
        sca
        break
      end
    end
    % now check 'which_key'
    if find(key) ~= KbName(which_key)     
        iskeydown = 0; % ignore all keys but the relevant one
    end
end

