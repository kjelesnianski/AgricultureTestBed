function varargout = AgBotGUI(varargin)
%
% Description
% This GUI was created for the Agriculture Automated Tesbed System for the
% IALR at Danville, by students of Virginia Tech for ME 5735 Advanced
% Mechatronics Fall 2016.
%
% Authors: Christopher Jelesnianski, Christopher Kappes, Jackson Klein,
% Peter Racioppo.
% 
% Virginia Tech - ME 5735 
% 2016-11-21; Last revision: 2016-12-09
%
% AGBOTGUI MATLAB code for AgBotGUI.fig
%      AGBOTGUI, by itself, creates a new AGBOTGUI or raises the existing
%      singleton*.
%
%      H = AGBOTGUI returns the handle to a new AGBOTGUI or the handle to
%      the existing singleton*.
%
%      AGBOTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AGBOTGUI.M with the given input arguments.
%
%      AGBOTGUI('Property','Value',...) creates a new AGBOTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AgBotGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AgBotGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 09-Dec-2016 10:21:07

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AgBotGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AgBotGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before AgBotGUI is made visible.
function AgBotGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AgBotGUI (see VARARGIN)

% initlization paths
addpath([pwd(), '/subcode']);                           % add folder with subfunctions to workspace
availablePaths_Callback(hObject, eventdata, handles);   % load all available paths for list

% initializying variable for new Path generation
handles.newPath = [];           % matrix with new path data
handles.newPlant = 1;           % start new Path with this Plant number
handles.newPathFilePath = '';   % file path for new created path

% initialize Position
handles.currPos = csvread('last_position.csv');         % initialize position
guidata(hObject, handles);                              % update guidata

% initializing previous Data variables
handles.xGotoPrev = handles.currPos(1);             % previous x Goto value
handles.yGotoPrev = handles.currPos(2);             % previous y Goto value
handles.zGotoPrev = handles.currPos(3);             % previous z Goto value
handles.iterationsPrev            = num2str(1);     % previous iterations
handles.timeBetweenIterationsPrev = num2str(1);     % previous time between interations

% initialize GUI parameters
handles.xRightVal    = 0;    % initialize button move to right in x direction
handles.xLeftVal     = 0;    % initialize button move to left in x direction
handles.yForwardVal  = 0;    % initialize button move forward in y direction
handles.yBackwardVal = 0;    % initialize button move backward in y direction
handles.zUpVal       = 0;    % initialize button move up in z direction
handles.zDownVal     = 0;    % initialize button move down in z direction
handles.messageII    = 1;    % initialize count variable for messageList
handles.pathVisable  = 0;    % make path visable
handles.cameraVisable= 0;    % make camera visable
handles.snapmode     = 0;    % set snap mode to off

% initialize boundaries
handles.xMax          = 99.5e3; % maximum steps in x direction @IALR
handles.yMax          = 195e3;  % maximum steps in y direction @IALR
handles.zMax          = 62.5e3; % maximum steps in z direction @IALR
handles.iterationsMax = 100;    % maximum iterations
handles.timeBetweenIterationsMax = 36000; % maximum time between iterations

% show VT logo on Camera plot window
set(handles.AgBotGUI,'CurrentAxes',handles.cameraAxes) % Set display window to cameraAxes
imshow([pwd() '/subcode/vt.png']),

% connect to Point Grey Camera and add settings
handles.video = videoinput('pointgrey', 1, 'F7_RGB_1384x1032_Mode7');   % create video objet and set mode
set(handles.video,'TimerPeriod', 0.05, 'TimerFcn', ...                  % set camera handles
    ['if(~isempty(gco)),', 'handles=guidata(gcf);',  'image(getsnapshot(handles.video));'...
     'set(handles.cameraAxes,''ytick'',[],''xtick'',[]),', 'else,', 'delete(imaqfind);', 'end']);    
triggerconfig(handles.video,'manual');      % set trigger to manual
handles.video.FramesPerTrigger = Inf;       % Capture frames until we manually stop it
src = getselectedsource(handles.video);     % get camera settings objetct
src.ExposureMode = 'Manual';                % set exposure mode to manual
src.Exposure     = 1.18;                    % set and change exposure @IALR
src.ShutterMode  = 'Manual';                % set shutter mode to manual
src.Shutter      = 94;                      % set and change shutter @IALR

% build connection to MSP432 board
% !!!use this if ou have the Matlab Instrument Control Box!!!
% handles.portNumber   = 7;                                             % change this parameter depentend on USB port @IALR
% port                 = instrhwinfo('serial');                         % get all available ports
% handles.s            = serial(port.SerialPorts{handles.portNumber});  % set port for MSP432
% !!! use this if you don't have the Matlab Instrument Control Box!!!
handles.s = serial('COM5');         % change this parameter depentend on USB port @IALR - see device manager for port
fopen(handles.s);                   % open connection to MSP432
set(handles.s,'Timeout', 1200);     % maxium movement time for fscanf

% Choose default command line output for AgBotGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
handles = updatePosition(hObject, eventdata, handles);

% UIWAIT makes AgBotGUI wait for user response (see UIRESUME)
uiwait(handles.AgBotGUI);

% --- Outputs from this function are returned to the command line.
function varargout = AgBotGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output  = hObject;
varargout{1}    = handles.output;


% --- Executes when user attempts to close AgBotGUI.
function AgBotGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to AgBotGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fclose(handles.s);      % close connection to MSP432
delete(hObject);        % delete all hObject
delete(imaqfind);       % cut camera connection


% --- Executes on button press in xRight.
function xRight_Callback(hObject, eventdata, handles)
% hObject    handle to xRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if mod(handles.xRightVal, 2) == 0               % if there is no movement in x
    fwrite(handles.s, 'x');                     % move in x
    set(handles.xLeft,     'Enable', 'off');    % disable button
    set(handles.yForward,  'Enable', 'off');    % disable button
    set(handles.yBackward, 'Enable', 'off');    % disable button
    set(handles.zUp,       'Enable', 'off');    % disable button
    set(handles.zDown,     'Enable', 'off');    % disable button
    set(handles.goto,      'Enable', 'off');    % disable button
else                                            % if there is movement in x
    handles = stopMotion(hObject, eventdata, handles);  % stop to move
end                                             % end if else
handles.xRightVal = handles.xRightVal + 1;      % increase count variable
guidata(hObject, handles);                      % update guidata


% --- Executes on button press in xLeft.
function xLeft_Callback(hObject, eventdata, handles)
% hObject    handle to xLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if mod(handles.xLeftVal, 2) == 0                % if there is no movement in x
    fwrite(handles.s, 'A');                     % move in x
    set(handles.xRight,    'Enable', 'off');    % disable button
    set(handles.yForward,  'Enable', 'off');    % disable button
    set(handles.yBackward, 'Enable', 'off');    % disable button
    set(handles.zUp,       'Enable', 'off');    % disable button
    set(handles.zDown,     'Enable', 'off');    % disable button
    set(handles.goto,      'Enable', 'off');    % disable button
else                                            % if there is movement in x
    handles = stopMotion(hObject, eventdata, handles);  % stop to move
end                                             % end if else
handles.xLeftVal = handles.xLeftVal + 1;        % increase count variable
guidata(hObject, handles);                      % update guidata


% --- Executes on button press in yForward.
function yForward_Callback(hObject, eventdata, handles)
% hObject    handle to yForward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if mod(handles.yForwardVal, 2) == 0             % if there is no movement in y
    fwrite(handles.s, 'y');                     % move in y
    set(handles.xRight,    'Enable', 'off');    % disable button
    set(handles.xLeft,     'Enable', 'off');    % disable button
    set(handles.yBackward, 'Enable', 'off');    % disable button
    set(handles.zUp,       'Enable', 'off');    % disable button
    set(handles.zDown,     'Enable', 'off');    % disable button
    set(handles.goto,      'Enable', 'off');    % disable button
else                                            % if there is movement in y
    handles = stopMotion(hObject, eventdata, handles);  % stop to move
end                                             % end if else
handles.yForwardVal = handles.yForwardVal + 1;  % increase count variable
guidata(hObject, handles);                      % update guidata


% --- Executes on button press in yBackward.
function yBackward_Callback(hObject, eventdata, handles)
% hObject    handle to yBackward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if mod(handles.yBackwardVal, 2) == 0            % if there is no movement in y
    fwrite(handles.s, 'B');                     % move in y
    set(handles.xRight,    'Enable', 'off');    % disable button
    set(handles.xLeft,     'Enable', 'off');    % disable button
    set(handles.yForward,  'Enable', 'off');    % disable button
    set(handles.zUp,       'Enable', 'off');    % disable button
    set(handles.zDown,     'Enable', 'off');    % disable button
    set(handles.goto,      'Enable', 'off');    % disable button
else                                            % if there is movement in y
    handles = stopMotion(hObject, eventdata, handles);  % stop to move
end                                             % end if else
handles.yBackwardVal = handles.yBackwardVal + 1;% increase count variable
guidata(hObject, handles);                      % update guidata


% --- Executes on button press in zUp.
function zUp_Callback(hObject, eventdata, handles)
% hObject    handle to zUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if mod(handles.zUpVal, 2) == 0                  % if there is no movement in z
    fwrite(handles.s, 'z');                     % move in z
    set(handles.xRight,    'Enable', 'off');    % disable button
    set(handles.xLeft,     'Enable', 'off');    % disable button
    set(handles.yForward,  'Enable', 'off');    % disable button
    set(handles.yBackward, 'Enable', 'off');    % disable button
    set(handles.zDown,     'Enable', 'off');    % disable button
    set(handles.goto,      'Enable', 'off');    % disable button
else                                            % if there is movement in z
    handles = stopMotion(hObject, eventdata, handles);  % stop to move
end                                             % end if else
handles.zUpVal = handles.zUpVal + 1;            % increase count variable
guidata(hObject, handles);                      % update guidata


% --- Executes on button press in zDown.
function zDown_Callback(hObject, eventdata, handles)
% hObject    handle to zDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if mod(handles.zDownVal, 2) == 0                % if there is no movement in z
    fwrite(handles.s, 'C');                     % move in z
    set(handles.xRight,    'Enable', 'off');    % disable button
    set(handles.xLeft,     'Enable', 'off');    % disable button
    set(handles.yForward,  'Enable', 'off');    % disable button
    set(handles.yBackward, 'Enable', 'off');    % disable button
    set(handles.zUp,       'Enable', 'off');    % disable button 
    set(handles.goto,      'Enable', 'off');    % disable button
else                                            % if there is movement in z
    handles = stopMotion(hObject, eventdata, handles);  % stop to move
end                                             % end if else
handles.zDownVal = handles.zDownVal + 1;        % increase count variable
guidata(hObject, handles);                      % update guidata


function handles = updatePosition(hObject, eventdata, handles)
set(handles.currentPosition, 'String', ['X: ' num2str(handles.currPos(1)) ...   % updated text with current position data x direction
                                        ' - Y: ' num2str(handles.currPos(2)) ...% y direction
                                        ' - Z: ' num2str(handles.currPos(3))]); % z direction
set(handles.xGoto, 'String', num2str(handles.currPos(1)));                      % set xGoto text field to current position
set(handles.yGoto, 'String', num2str(handles.currPos(2)));                      % set yGoto text field to current position
set(handles.zGoto, 'String', num2str(handles.currPos(3)));                      % set zGoto text field to current position
csvwrite([pwd() '/subcode/last_position.csv'], handles.currPos);                % write current Position in last_position file
handles.xGotoPrev = handles.currPos(1);                         % update xGoto Preview Data
handles.yGotoPrev = handles.currPos(2);                         % update yGoto Preview Data
handles.zGotoPrev = handles.currPos(3);                         % update zGoto Preview Data
if handles.snapmode == 1                                        % if snapmode is on
    Im = getsnapshot(handles.video);                            % get snapshot
    set(handles.AgBotGUI,'CurrentAxes',handles.cameraAxes)      % Set display window to cameraAxes
    imshow(Im);                                                 % show snapshot
end                                                             % end if statement
guidata(hObject, handles);                                      % update guidata
handles           = preview(hObject, eventdata, handles);       % updated preview plot


function handles = preview(hObject, eventdata, handles)
plot(handles.previewPlot, handles.currPos(1), handles.currPos(2), 'X', 'markers', 10, 'linewidth', 1.5); % plot current position
hold(handles.previewPlot, 'on');                                        % hold plot on
plot(handles.previewPlot, handles.xGotoPrev, handles.yGotoPrev, 'o', 'markers', 10, 'linewidth', 1.5);   % plot preview position
xlim(handles.previewPlot, [0 handles.xMax]);                            % set x axis limits
ylim(handles.previewPlot, [0 handles.yMax]);                            % set y axis limits
grid(handles.previewPlot, 'on');                                        % turn grid on
xlabel(handles.previewPlot, 'X Position (Steps)', 'FontSize', 10);      % change x lable fontsize
ylabel(handles.previewPlot, 'Y Position (Steps)', 'FontSize', 10);      % change y lable fontsize
legend(handles.previewPlot, {'current Position', 'GoTO Position'}, 'FontSize', 10);  % add legend
hold(handles.previewPlot, 'off');                                       % hold plot off
if handles.pathVisable == 1                                             % if path should be visable during startPath
   for ii = 1:size(handles.path, 1)                                     % loop through all plants for startPath
      text(handles.previewPlot, handles.path(ii, 1), handles.path(ii, 2), num2str(ii), 'FontSize', 16); % show plant number
   end                                                                  % end loop
elseif handles.pathVisable == 2                                         % if new path is visable during newPath
   for ii = 1:size(handles.newPath, 1)                                  % loop through all plants
      text(handles.previewPlot, handles.newPath(ii, 1), handles.newPath(ii, 2), num2str(ii), 'FontSize', 16);   % show plant number
   end                                                                  % end loop 
end                                                                     % end if statement


function handles = stopMotion(hObject, eventdata, handles)
fwrite(handles.s, 's');                                     % commend stop moving
movDis  = fscanf(handles.s);                                % get moved distance
handles.currPos = newPos(handles.currPos, movDis);          % get new postition
handles = updatePosition(hObject, eventdata, handles);      % update new position
set(handles.xRight,    'Enable', 'on');                     % enable button
set(handles.xLeft,     'Enable', 'on');                     % enable button
set(handles.yForward,  'Enable', 'on');                     % enable button
set(handles.yBackward, 'Enable', 'on');                     % enable button
set(handles.zUp,       'Enable', 'on');                     % enable button
set(handles.zDown,     'Enable', 'on');                     % enable button
set(handles.goto,      'Enable', 'on');                     % enable button


function xGoto_Callback(hObject, eventdata, handles)
% hObject    handle to xGoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xGoto as text
%        str2double(get(hObject,'String')) returns contents of xGoto as a double
if isempty(str2num(get(handles.xGoto, 'string'))) == 1          % if input is not a number
    msgbox('Value must be a number!');                          % show error message
    set(handles.xGoto, 'String', num2str(handles.xGotoPrev));   % set text back to old value
elseif str2num(get(handles.xGoto, 'string')) < 0 || str2num(get(handles.xGoto, 'string')) > handles.xMax % if input is a number out of range
    msgbox(['Value must be in the range of 0 and ' num2str(handles.xMax)]);% show error message
    set(handles.xGoto, 'String', num2str(handles.xGotoPrev));   % set text back to old value
end                                                             % end if else case
handles.xGotoPrev = str2num(get(handles.xGoto, 'String'));      % update previous xGoto value
handles           = preview(hObject, eventdata, handles);       % show preview
guidata(hObject, handles);                                      % update guidata


% --- Executes during object creation, after setting all properties.
function xGoto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xGoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function yGoto_Callback(hObject, eventdata, handles)
% hObject    handle to yGoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yGoto as text
%        str2double(get(hObject,'String')) returns contents of yGoto as a double
if isempty(str2num(get(handles.yGoto, 'string'))) == 1          % if input is not a number
    msgbox('Value must be a number!');                          % show error message
    set(handles.yGoto, 'String', num2str(handles.yGotoPrev));   % set text back to old value
elseif str2num(get(handles.yGoto, 'string')) < 0 || str2num(get(handles.yGoto, 'string')) > handles.yMax % if input is a number out of range
    msgbox(['Value must be in the range of 0 and ' num2str(handles.yMax)]);% show error message
    set(handles.yGoto, 'String', num2str(handles.yGotoPrev));   % set text back to old value
end                                                             % end if else case
handles.yGotoPrev = str2num(get(handles.yGoto, 'String'));      % update previous xGoto value
handles           = preview(hObject, eventdata, handles);       % show preview
guidata(hObject, handles);                                      % update guidata


% --- Executes during object creation, after setting all properties.
function yGoto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yGoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function zGoto_Callback(hObject, eventdata, handles)
% hObject    handle to zGoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zGoto as text
%        str2double(get(hObject,'String')) returns contents of zGoto as a double
if isempty(str2num(get(handles.zGoto, 'string'))) == 1          % if input is not a number
    msgbox('Value must be a number!');                          % show error message
    set(handles.zGoto, 'String', num2str(handles.zGotoPrev));   % set text back to old value
elseif str2num(get(handles.zGoto, 'string')) < 0 || str2num(get(handles.zGoto, 'string')) > handles.zMax % if input is a number out of range
    msgbox(['Value must be in the range of 0 and ' num2str(handles.zMax)]);% show error message
    set(handles.zGoto, 'String', num2str(handles.zGotoPrev));   % set text back to old value
end                                                             % end if else case
handles.zGotoPrev = str2num(get(handles.zGoto, 'String'));      % update previous xGoto value
handles           = preview(hObject, eventdata, handles);       % show preview
guidata(hObject, handles);                                      % update guidata


% --- Executes during object creation, after setting all properties.
function zGoto_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zGoto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in goto.
function goto_Callback(hObject, eventdata, handles)
% hObject    handle to goto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.xRight,    'Enable', 'off');    % disable button
set(handles.xLeft,     'Enable', 'off');    % disable button
set(handles.yForward,  'Enable', 'off');    % disable button
set(handles.yBackward, 'Enable', 'off');    % disable button
set(handles.zUp,       'Enable', 'off');    % disable button
set(handles.zDown,     'Enable', 'off');    % disable button
set(handles.goto,      'Enable', 'off');    % disable button
pause(0.01);                                % pause for disabling

xGoto_Callback(hObject, eventdata, handles);  % check input again
yGoto_Callback(hObject, eventdata, handles);  % check input again
zGoto_Callback(hObject, eventdata, handles);  % check input again

gotoPos = [str2num(get(handles.xGoto,'String')), ...    % goto x value
           str2num(get(handles.yGoto,'String')), ...    % goto y value
           str2num(get(handles.zGoto,'String'))];       % goto z value
movCom  = getMSPMov(handles.currPos, gotoPos);          % calculate MSP42 code

fwrite(handles.s, movCom);                              % send move command to MSP432
movDis          = fscanf(handles.s);                    % get moved distance
handles.currPos = newPos(handles.currPos, movDis);      % get new postition
handles         = updatePosition(hObject, eventdata, handles);% update position

set(handles.xRight,    'Enable', 'on');     % enable butoon
set(handles.xLeft,     'Enable', 'on');     % enable butoon
set(handles.yForward,  'Enable', 'on');     % enable butoon
set(handles.yBackward, 'Enable', 'on');     % enable butoon
set(handles.zUp,       'Enable', 'on');     % enable butoon
set(handles.zDown,     'Enable', 'on');     % enable butoon
set(handles.goto,      'Enable', 'on');     % enable butoon
guidata(hObject, handles);                  % update guidatas


% --- Executes on button press in startCal.
function startCal_Callback(hObject, eventdata, handles)
% hObject    handle to startCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cameraVisable   = 1;                        % turn camera preview off - with two lines below
guidata(hObject, handles);                          % update guidata 
turnCameraOnOff_Callback(hObject, eventdata, handles); % turn camera preview off

set(handles.setOrigin, 'Enable', 'on');         % enable button
set(handles.cancelCal, 'Enable', 'on');         % enable button
set(handles.startCal, 'Enable', 'off');         % disable button
msgbox('Move machine manually to origion (0, 0, 0). Use "Manual Positioning" button. Hit "Set Origin" afterwards. Use caution!!!'); % show message
handles.cameraVisable   = 0;                        % turn camera preview off - with two lines below
guidata(hObject, handles);                          % update guidata 
turnCameraOnOff_Callback(hObject, eventdata, handles); % turn camera preview off

handles.cameraVisable   = 0;                        % turn camera preview off - with two lines below
guidata(hObject, handles);                          % update guidata 
turnCameraOnOff_Callback(hObject, eventdata, handles); % turn camera preview off

% --- Executes on button press in cancelCal.
function cancelCal_Callback(hObject, eventdata, handles)
% hObject    handle to cancelCal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.setOrigin, 'Enable', 'off');    % diable button
set(handles.cancelCal, 'Enable', 'off');    % diable button
set(handles.startCal, 'Enable', 'on');      % enable button


% --- Executes on button press in setOrigin.
function setOrigin_Callback(hObject, eventdata, handles)
% hObject    handle to setOrigin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cameraVisable   = 1;                        % turn camera preview off - with two lines below
guidata(hObject, handles);                          % update guidata 
turnCameraOnOff_Callback(hObject, eventdata, handles); % turn camera preview off

set(handles.setOrigin, 'Enable', 'off');    % disable button
set(handles.cancelCal, 'Enable', 'off');    % disable button
set(handles.startCal,  'Enable', 'on');     % enable button
handles.currPos = [0, 0, 0];                % set new position
handles         = updatePosition(hObject, eventdata, handles); % update position
msgbox('You are at (0, 0, 0)!!!');          % show message
guidata(hObject, handles);                  % update guidata

handles.cameraVisable   = 0;                        % turn camera preview on - with two lines below
guidata(hObject, handles);                          % update guidata
turnCameraOnOff_Callback(hObject, eventdata, handles); % turn camera preview off

% --- Executes on selection change in availablePaths.
function availablePaths_Callback(hObject, eventdata, handles)
% hObject    handle to availablePaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% load available Paths

strucAllAvailablePath   = struct2cell(dir([pwd() '/paths/*.csv']));             % get path of all available csv-files
allAvailablePath        = strucAllAvailablePath(1, :);                          % make cell array
index                   = find(strcmp(allAvailablePath, 'last_position.csv'));  % get index last_postion files
availablePath           = allAvailablePath;                                     % all files available jet

if isempty(index) == 0                                  % if last_position file were catched
    if index == 1                                       % if last_position file has index 1
        availablePath = allAvailablePath(2:end);        % make last_position file unavailable
    elseif index == length(allAvailablePath)            % if last_position file has highest index
        availablePath = allAvailablePath(1:(end -1));   % make last_position file unavailable
    else                                                % if last_position file has index in between 1 and highest
       availablePath = allAvailablePath(1:(index - 1)); % make last_position file unavailable
       availablePath = [availablePath allAvailablePath((index + 1):end)];       % make last_position file unavailable
    end                                                 % end if-else-case
end                                                     % end if-else-case
set(handles.availablePaths, 'String', availablePath);   % set list with available pahts

% Hints: contents = cellstr(get(hObject,'String')) returns availablePaths contents as cell array
%        contents{get(hObject,'Value')} returns selected item from availablePaths


% --- Executes during object creation, after setting all properties.
function availablePaths_CreateFcn(hObject, eventdata, handles)
% hObject    handle to availablePaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function iterations_Callback(hObject, eventdata, handles)
% hObject    handle to iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iterations as text
%        str2double(get(hObject,'String')) returns contents of iterations as a double
if isempty(str2num(get(handles.iterations, 'string'))) == 1             % if input is not a number
    msgbox('Value must be a number!');                                  % show error message
    set(handles.iterations, 'String', num2str(handles.iterationsPrev)); % set text back to old value
elseif str2num(get(handles.iterations, 'string')) < 0 || str2num(get(handles.iterations, 'string')) > handles.iterationsMax % check if input is out of range
    msgbox(['Value must be in the range of 0 and ' num2str(handles.iterationsMax)]);% show error message
    set(handles.iterations, 'String', num2str(handles.iterationsPrev)); % set text back to old value
end                                                                     % end if else case
handles.iterationsPrev = str2num(get(handles.iterations, 'String'));    % update previous iteration value
guidata(hObject, handles);                                              % update guidata


% --- Executes during object creation, after setting all properties.
function iterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeBetweenIterations_Callback(hObject, eventdata, handles)
% hObject    handle to timeBetweenIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeBetweenIterations as text
%        str2double(get(hObject,'String')) returns contents of timeBetweenIterations as a double
if isempty(str2num(get(handles.timeBetweenIterations, 'string'))) == 1                          % if input is not a number
    msgbox('Value must be a number!');                                                          % show error message
    set(handles.timeBetweenIterations, 'String', num2str(handles.timeBetweenIterationsPrev));   % set text back to old value
elseif str2num(get(handles.timeBetweenIterations, 'string')) < 0 || str2num(get(handles.timeBetweenIterations, 'string')) > handles.timeBetweenIterationsMax % check if input is out of range
    msgbox(['Value must be in the range of 0 and ' num2str(handles.timeBetweenIterationsMax)]); % show error message
    set(handles.timeBetweenIterations, 'String', num2str(handles.timeBetweenIterationsPrev));   % set text back to old value
end                                                                                             % end if else case
handles.timeBetweenIterationsPrev = str2num(get(handles.timeBetweenIterations, 'String'));      % update previous between iterations time value
guidata(hObject, handles);                                                                      % update guidata


% --- Executes during object creation, after setting all properties.
function timeBetweenIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeBetweenIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startPath.
function startPath_Callback(hObject, eventdata, handles)
% hObject    handle to startPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

iterations_Callback(hObject, eventdata, handles);               % check iteration input agian
timeBetweenIterations_Callback(hObject, eventdata, handles);    % check time between iterations input again
handles.pathVisable = 1;                                        % make path visable

handles.snapmode      = 1;                              % turn snapmode on
handles.cameraVisable = 1;                              % set cameraVisable off with second line underneath
guidata(hObject, handles);                              % update guidata 
turnCameraOnOff_Callback(hObject, eventdata, handles);  % set cameraVisable off

value        = get(handles.availablePaths, 'value');        % get list of values
filePaths    = get(handles.availablePaths, 'String');       % get list of pahts
filePath     = filePaths(value);                            % get file path
handles.path = csvread([pwd() '/paths/' filePath{1}]);      % read path data set
handles.iter = str2num(get(handles.iterations, 'String'));  % read number of iterations
handles.tBI  = str2num(get(handles.timeBetweenIterations, 'String'));% read number of time between iterations
handles.message{handles.messageII} = 'Start path';          % initializing messages
handles.messageII = handles.messageII + 1;                  % increase count variable messageList
set(handles.messageList, 'String', flip(handles.message));  % show messages in list
pause(0.0001);                                              % pause
folderName = [filePath{1}(1:end-4), datestr(datetime, '_yyyy-mm-dd_HH-MM-SS')];  % new folder name
mkdir([pwd(), '/images'], folderName);                      % create new folder

for ii = 1:handles.iter                                         % loop through all iterations
    for jj = 1:size(handles.path, 1)                            % loop through all plants
        gotoPos = handles.path(jj, :);                          % goto position
        movCom  = getMSPMov(handles.currPos, gotoPos);          % calculate MSP42 input
        fwrite(handles.s, movCom);                              % send move command to MSP432
        movDis  = fscanf(handles.s);                            % get moved distance
        handles.currPos = newPos(handles.currPos, movDis);      % get new postition
        handles = updatePosition(hObject, eventdata, handles);  % update position
        if jj == 1                                              % if this is plant number 1
            if ii ~= 1                                          % if this is not the first iteratoin
                tNow = datetime;                                % current time
                if seconds(tNow - tStart) < handles.tBI         % if time between iterations is not over jet
                    pause(handles.tBI - seconds(tNow - tStart));% pause until time between iterations is over
                end                                             % end if statement
            end                                                 % end if statement
            tStart = datetime;                                  % set start time
        end                                                     % end if statement
        handles.message{handles.messageII} = ...  % message
            ['P.: ' num2str(jj) '/' num2str(size(handles.path, 1)) '; I.: ' num2str(ii) '/' num2str(handles.iter) '; ' datestr(datetime, 'HH:MM:SS yyyy-mm-dd')];
        handles.messageII = handles.messageII + 1;
        set(handles.messageList, 'String', flip(handles.message));  % show messages in list
        if handles.cameraVisable == 1                               % if video preview is switched on
            set(handles.AgBotGUI,'CurrentAxes',handles.cameraAxes); % Set display window to cameraAxes
            stop(handles.video);                                    % stop video
            pause(0.5);                                             % pause
            Im = getsnapshot(handles.video);                        % get image
            start(handles.video);                                   % start video
        else                                                        % if video preview is not switched on
            pause(0.5);                                             % pause
            Im = getsnapshot(handles.video);                        % get image
        end                                                         % end if statement
        % use this if you have the Vision System Toolbox
%         Im  = imLable(Im, filePath{1}(1:end-4), jj, ii);                        % lable image
        fileName = ['AGBED_IALR-VT_', filePath{1}(1:end-4) '_P', num2str(jj,'%03i'), '_I' num2str(ii,'%03i'), datestr(datetime, 'yyyy-mm-dd_HH-MM-SS') '.bmp'];% filename
        imwrite(Im, [pwd(), '/images/', folderName, '/', fileName], 'bmp');    % save image        
        guidata(hObject, handles);                                             % update guidata
        pause(0.00001);                                                        % pause
    end                                                         % end for loops plants
end                                                             % ent for loops iterations
handles.message{handles.messageII} = 'Done with path';          % done messages
handles.messageII   = handles.messageII + 1;                    % increase count variable messageList
handles.message{handles.messageII} = 'Ready';                   % ready messages
handles.messageII   = handles.messageII + 1;                    % increase count variable messageList
handles.pathVisable = 0;                                        % make path invisable
set(handles.messageList, 'String', flip(handles.message));      % show messages in list
handles.snapmode    = 0;                                        % set snapshot mode off
guidata(hObject, handles);                                      % update guidata 


% --- Executes on button press in stopAfterNextPlant.
function stopAfterNextPlant_Callback(hObject, eventdata, handles)
% hObject    handle to stopAfterNextPlant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stopAfterNextPlant


% --- Executes on button press in startCreatingPath.
function startCreatingPath_Callback(hObject, eventdata, handles)
% hObject    handle to startCreatingPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.snapmode        = 1;                        % turn snapshot mode on
handles.cameraVisable   = 1;                        % turn camera preview off - with two lines below
guidata(hObject, handles);                          % update guidata 
turnCameraOnOff_Callback(hObject, eventdata, handles); % turn camera preview off
prompt                  = {'Enter new Path Name'};  % ask for new path name
dlg_title               = 'Path Name';              % window title
num_lines               = 1;                        % number of lines input window
defaultans              = {'newPath'};              % default value
newPathFilePath         = inputdlg(prompt, dlg_title, num_lines, defaultans); % get new path name
handles.newPathFilePath = newPathFilePath{1};       % new path name
set(handles.startCreatingPath, 'Enable', 'off');    % disable button
set(handles.setPlant, 'Enable', 'on');              % enable button
set(handles.setPlant, 'String', ['set Plant #' num2str(handles.newPlant)]); % update button name
set(handles.finishCreatingPath, 'Enable', 'on');    % enable button
handles.pathVisable = 2;                            % make new path visable
guidata(hObject, handles);                          % update guidata 

        
% --- Executes on button press in setPlant.
function setPlant_Callback(hObject, eventdata, handles)
% hObject    handle to setPlant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.newPath     = [handles.newPath; handles.currPos];   % add current position to new path
handles.newPlant    = handles.newPlant + 1;                 % increase number of paths
set(handles.setPlant, 'String', ['set Plant #' num2str(handles.newPlant)]); % update button name
guidata(hObject, handles);                                  % update guidata 

% --- Executes on button press in finishCreatingPath.
function finishCreatingPath_Callback(hObject, eventdata, handles)
% hObject    handle to finishCreatingPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
csvwrite([pwd() '/paths/' handles.newPathFilePath '.csv'], handles.newPath); % save new paths
set(handles.startCreatingPath, 'Enable', 'on');         % enable button
set(handles.setPlant, 'Enable', 'off');                 % disable button
set(handles.setPlant, 'String', 'set Plant');           % update button name
set(handles.finishCreatingPath, 'Enable', 'off');       % disable button
handles.newPlant        = 1;                            % reset path count variable
handles.newPath = [];                                   % reset path name variable
handles.newPathFilePath = '';                           % reset path name variable
handles.pathVisable     = 0;                            % make new path invisable
handles.snapmode        = 0;                            % turn snapshot mode off
guidata(hObject, handles);                              % update guidata 
availablePaths_Callback(hObject, eventdata, handles);   % update available paths


% --- Executes on button press in takePicture.
function takePicture_Callback(hObject, eventdata, handles)
% hObject    handle to takePicture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.cameraVisable == 1                               % if video preview is switched on
    set(handles.AgBotGUI,'CurrentAxes',handles.cameraAxes)  % Set display window to cameraAxes
    stop(handles.video);                                    % stop video
    Im = getsnapshot(handles.video);                        % get image
    start(handles.video);                                   % start video
else                                                        % if video preview is switeched off
    Im = getsnapshot(handles.video);                        % start video
end                                                         % end if statement
% use this if you have the Vision System Toolbox
% Im  = imLable(Im, filePath{1}(1:end-4), jj, ii);          % lable image
fileName = ['AGBED_IALR-VT_Snapshot_', datestr(datetime, 'yyyy-mm-dd_HH-MM-SS') '.bmp'];% filename
imwrite(Im, fileName, 'bmp');                               % save image


% --- Executes on button press in createTimeLapseVideo.
function createTimeLapseVideo_Callback(hObject, eventdata, handles)
% hObject    handle to createTimeLapseVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
createTimeseriesVideo;      % create time laps video

% --- Executes on button press in turnCameraOnOff.
function turnCameraOnOff_Callback(hObject, eventdata, handles)
% hObject    handle to turnCameraOnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.cameraVisable == 0                               % make camera visable
        set(handles.AgBotGUI,'CurrentAxes',handles.cameraAxes); % Set display window to cameraAxes
        start(handles.video);                                   % start video preview
        handles.cameraVisable = 1;                              % switch mode
    else                                                        % make camera invisable
        set(handles.AgBotGUI,'CurrentAxes',handles.cameraAxes)  % Set display window to cameraAxes
        stop(handles.video);                                    % stop video preview
        imshow([pwd() '/subcode/vt.png'])                       % show image
        handles.cameraVisable = 0;                              % switch mode
    end                                                         % end if statemtent
    guidata(hObject, handles);                                  % update guidata 
    

% --- Executes on selection change in messageList.
function messageList_Callback(hObject, eventdata, handles)
% hObject    handle to messageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns messageList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from messageList


% --- Executes during object creation, after setting all properties.
function messageList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to messageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on AgBotGUI and none of its controls.
function AgBotGUI_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to AgBotGUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key release with focus on AgBotGUI and none of its controls.
function AgBotGUI_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to AgBotGUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function previewPlot_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to previewPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
