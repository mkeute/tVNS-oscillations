function [hs] = clean_headshape(hs,cutoff,interactive)

if isempty(hs.pos)
  warning('No headshape detected for this dataset...');
  return
else
end

if ~isempty(cutoff)
  hs.pos=hs.pos(hs.pos(:,3)>cutoff,:); %REMOVE ALL POINTS BELOW z=0cm;
else
end

% remove bad headshape points manually
if interactive
  kk = 0;
else
  kk = 1;
end %if

disp('Use the data curser to flag bad points')
while kk==0
  fig = figure; dcm = datacursormode(fig);
  ft_plot_headshape(hs)
  
  while isvalid(fig) % stay in the loop as long as there are bad points
    c_info = [];
    
    while isempty(c_info) && isvalid(fig)
      pause(0.2);
      if ~isvalid(fig)
        break;
      end %if
      c_info = getCursorInfo(dcm);
      
    end %while
    
    if ~isvalid(fig)
      break;
    end %if
    
    if ~isempty(c_info)
      hs.pos(c_info.DataIndex,:)
      hs.pos(c_info.DataIndex,:)=[];
    end %if
    
    % this is a workaround to get rid of thrown away points
    % (ft_plot_headshape sets current figure on hold, thus thrown away points stay)
    
    % get current view angle
    cPos = get(gca, 'CameraPosition');
    
    % change hold
    hold off
    % redraw head shape
    close(fig);
    fig = figure;
    dcm = datacursormode(fig);
    ft_plot_headshape(hs)
    % set to view from before
    set(gca, 'CameraPosition', cPos)
  end
  
  tmp = input('Quit? (0=no, 1=yes)');
  
  if tmp==1
    kk = 1;
  end
end
end