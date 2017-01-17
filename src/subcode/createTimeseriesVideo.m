%% createTimeseriesVideo

%% Description
% The createTimeseriesVideo create a Timeseries video consistent of images.
% Therefor the script asks to select images, a video frame rate and a 
% location to store the video. This script was created for the AGBOT
% Project at IALR and Virginia Tech for ME 5735.
% 
% asked Inputs: 
% image paths
% video frame rate
% path for storing the video
%
% Outputs:
% Video Object *.avi
%
% Additional required files:
% none
% 
% Subfunctions:
% im2vid(Im, f, filename)
%
% Helpful Information:
% load image: Im = imread('image.jpg');
% save image: imwrite(Im, 'image.bmp', 'bmp')
% show image: imshow(Im)
% create Image cell: Im{1} = imread('Im1.jpg'); Im{2} = imread('Im2.jpg');
% create path: filename = [pwd '/vid.avi'];
%
% Author: Christopher Kappes
% Virginia Tech - ME 5735 
% 2016-11-20; Last revision: 2016-11-20

%% ------------- BEGIN CODE --------------

paths = imgetfile('MultiSelect', 'on');         % get image's paths

if isempty(paths) ~= 1                          % if no path was chosen
    for ii = 1:length(paths)                    % loop through all paths
        Im{ii} = imread(paths{ii});             % create cell with images
    end                                         % end loop

    dlg_title  = 'Frame Rate f';                % name dialog box
    prompt     = {'Enter Framte Rate of the Video - images per second'};
    defaultans = {'1'};                         % default value
    answer     = inputdlg(prompt, dlg_title, [1], defaultans);
    f          = str2num(answer{1});            % frame rate

    [FileName, PathName] = uiputfile({'*.avi'}, 'Save Video', 'video.avi');
    vid        = im2vid(Im, f, [PathName, FileName]);   % create video
end                                             % end if statement

%% ------------- END OF CODE --------------