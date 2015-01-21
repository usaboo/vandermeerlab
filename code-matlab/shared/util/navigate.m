function navigate(src,event)
% function navigate(src,event)
% 
% Use: Navigate is used by plotting functions such as MultiRaster by sending 
% data in via global variables, and calling on the function like so: 
% figure('KeyPressFcn',@navigate). See MultiRaster for an example.
% Purpose: Moves viewing window according to keyboard input.
%
% FIND EVENT
% a:       1 event left
% d:       1 event right
% Shift+a: 10 events left
% Shift+d: 10 events right
% Ctrl+a:  50 events left
% Ctrl+d:  50 events right
% f:       first event
% c:       center event
% l:       last event
%
% MOVE WINDOW
% leftarrow:   move a half-window left
% rightarrow:  move a half-window right
% Shift+left:  move 10 windows left
% Shift+right: move 10 windows right
% Ctrl+left:   move 50 windows left
% Ctrl+right:  move 50 windows right
% b:           move to the beginning of the recording
% m:           move to the midpoint of the recording
% e:           move to the end of the recording
%
% SHORTCOMINGS:
% **If you are inbetween events, navigate will skip the nearest left or
% right event; in this case, just hit 'd' or 'a' to get the one you missed.
% **Navigate will cause an error if you try to move beyond the first and 
% last events. You can just reverse directions using the opposite key 
% combination or the arrow keys.
%
% ACarey. Aug 2014. 
% youkitan edit, 2015-01-20 (can display candidate score).

%% ****Some notes on how this function works internally****

% Based on the current window limits and user keyboard input, this
% function generates new limits to change the view. Depending on the type 
% of movement asked for by the user, the function's if statements generate 
% different types of output:

% TYPE 1 if statement outputs are already limits and thus go directly into the
% "set(gca,'XLim',limits)" at the very end of the function. (Outputs cannot 
% enter the "permission" if statement.)

% TYPE 2 if statements must enter the "permission" if statement, which
% converts their outputs into new limits before sending the new output to set(gca,'XLim',limits)
% at the end of the function code. The function was organized
% internally in this way to reduce the amount of repetition in the code.

% There is likely a better way to do this, but I am a novice. - ACarey
%% Declare global variables

global evtTimes windowSize zoom time usrfield


%%
limits = get(gca,'XLim'); %get current limits; exists as limits(1) and limits(2), in array [1 2]
current_location = mean(limits); % finds center of current viewing window

modifier = get(gcf,'currentmodifier'); %checks for modifiers, such as Shift or Ctrl
%disp(modifier)
shiftPressed = ismember('shift',modifier);
ctrlPressed = ismember('control',modifier);
%altPressed = ismember('alt',modifier); % if alt is pressed while on a figure, the focus is moved elsewhere, so the figure has to be clicked on again

% Here's an alternative way to detect modifier keys:
%strcmp(event.Modifier{:},'control')

flank = 0.5*windowSize;
permission = 1; %this controls whether or not the outputs from the if statements can enter the  
% "permission" if statements, or whether they go directly towards changing
% the limits at the very end of the function




%% ZOOM

%could add a way to take user input for where they want to zoom to next, w/o
%having to rerun the plotting function


%% MOVE WINDOW
window = (limits(2)-limits(1));
       %type 1: output is a new set of limits
        if shiftPressed == 0 && ctrlPressed == 0 && strcmp(event.Key,'leftarrow')==1 %string comparison
                %shift figure axes left
                shift = window*0.5;
                limits = limits - shift;
                permission = 0;
                %disp('left')
         
        %type 1: output is a new set of limits        
        elseif shiftPressed == 0 && ctrlPressed == 0 && strcmp(event.Key,'rightarrow')==1 
                %shift figure axes right
                shift = window*0.5;
                limits = limits + shift;
                permission = 0;
                %disp('right')
         
        %type 1: output is a new set of limits        
        elseif shiftPressed == 1 && strcmp(event.Key,'leftarrow') == 1
            % shift 10 windows left
                shift = window*10;
                limits = limits - shift;
                permission = 0;
         
        %type 1: output is a new set of limits        
        elseif shiftPressed == 1 && strcmp(event.Key,'rightarrow') == 1
            % shift 10 windows right
                shift = window*10;
                limits = limits + shift;
                permission = 0;
        
        %type 1: output is a new set of limits
        elseif ctrlPressed == 1 && strcmp(event.Key,'leftarrow') == 1
            % shift 50 windows left
                shift = window*50;
                limits = limits - shift;
                permission = 0;
        
        %type 1: output is a new set of limits        
        elseif ctrlPressed == 1 && strcmp(event.Key,'rightarrow') == 1
            % shift 50 windows right
                shift = window*50;
                limits = limits + shift;
                permission = 0;
         
        %type 2: output is a next_location, which later is converted to new limits        
        elseif strcmp(event.Key,'m')==1  
                %shift figure axes to the midpoint of recording
                next_location = time(ceil(end/2));
          
        %type 2: output is a next_location, which later is converted to new limits        
        elseif strcmp(event.Key,'b')==1
            %shift figure axes to beginning of recording
                next_location = time(1)+flank;

        %type 2: output is a next_location, which later is converted to new limits        
        elseif strcmp(event.Key,'e') == 1
            %shift figure axes to end of recording
                next_location = time(end)-flank;
                  
        end
    
        
%% FIND EVENT
current_index = nearest_idx3(current_location,evtTimes); % find where we're located with respect to time. Take that index. 
next_idx = current_index;
evtTitle = 0; %this controls whether we display an event title, which 
% occurs only when we use the "find event" functionality of navigate;
% "move window" changes the current view regardless of the presence of an
% event, so we don't want to display an event title if an event is not the
% central focus of the viewing window! 

%all type 2: output is a next_location, which later is converted to new limits
        if shiftPressed == 0 && ctrlPressed == 0 && strcmp(event.Key,'a')==1 %string comparison
                %shift figure axes one event left
                next_idx = current_index - 1;
                next_location = evtTimes(next_idx);
                evtTitle = 1;
            
        elseif shiftPressed == 0 && ctrlPressed == 0 && strcmp(event.Key,'d')==1 %string comparison
                %shift figure axes one event right
                next_idx = current_index + 1;
                next_location = evtTimes(next_idx);
                evtTitle = 1;

        elseif shiftPressed == 1 && strcmp(event.Key,'a') == 1
                %shift figure axes ten events left
                next_idx = current_index - 10; 
                next_location = evtTimes(next_idx);
                evtTitle = 1;

        elseif shiftPressed == 1 && strcmp(event.Key,'d') == 1 
            %shift figure axes ten events right
                next_idx = current_index + 10;
                next_location = evtTimes(next_idx);
                evtTitle = 1;
                
        elseif ctrlPressed == 1 && strcmp(event.Key,'a') == 1
            %shift figure axes 50 events left
                next_idx = current_index - 50;
                next_location = evtTimes(next_idx);
                evtTitle = 1;
            
        elseif ctrlPressed == 1 && strcmp(event.Key,'d') == 1 
            %shift figure axes 50 events right
                next_idx = current_index + 50;
                next_location = evtTimes(next_idx);
                evtTitle = 1;
                
        elseif strcmp(event.Key,'leftarrow')==0 && strcmp(event.Key,'f') == 1
            %shift figure axes to first event
                next_idx = 1; 
                next_location = evtTimes(next_idx);
                evtTitle = 1;
            
        elseif strcmp(event.Key,'leftarrow')==0 && strcmp(event.Key,'l') == 1 
            %shift figure axes to last event
                next_idx = length(evtTimes); 
                next_location = evtTimes(next_idx);
                evtTitle = 1;
                
        elseif strcmp(event.Key,'c') == 1
            % shift figure axes to the center event
                next_idx = ceil(length(evtTimes)/2);
                next_location = evtTimes(next_idx);
                evtTitle = 1;
                
        else
            permission = 0; % can't enter the "permission" if statement if the wrong key is pressed
            evtTitle = 1; % ** if you press an unassigned key while viewing an event, the title will 
                          % diappear unless evtTitle is something other than 0
        end
  
% Do not show a title if the user is navigating based on the time axis
% (i.e. "move window" key commands) rather than based on event locations
% (i.e. "find event" key commands).
    
    if evtTitle == 0 % evtTitle will be blank if you are using the move window keys rather than the find event keys
        title(sprintf('')); 
    end

%% LIMITS ASSIGNMENT
    % "permission" if statement: allows only type 2 to enter -- converts
    % next_location into a new set of limits, and also prints the event
    % title if we're using the "find event" keys
    if permission == 1
        leftLim = next_location - flank;
        rightLim = next_location + flank;
        limits = [leftLim rightLim];
        
        if ~isempty(usrfield)
            str_title = sprintf('event %d/%d',next_idx,length(evtTimes));

            for iU = 1:length(usrfield)  
                str_font = '\fontsize{8}';
                str_usr{iU} = [str_font,sprintf('%s: %.3f',usrfield(iU).label,usrfield(iU).data(next_idx))];
            end
            
            str = [{str_title},str_usr];
            title(str)
           
        % no usr field input for events
        elseif evtTitle == 1
            title(sprintf('event %d/%d',next_idx,length(evtTimes)));
            
        end
    end
            
    % this is where the new limits are assigned to the viewing window
       set(gca,'XLim',limits)

    