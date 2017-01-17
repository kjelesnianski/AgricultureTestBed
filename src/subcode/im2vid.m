function vid = im2vid(Im, f, filename)

%% Description
% The im2vid builds and saves a video object consisting of the inputed 
% images, to show a time series of these. This function was created for the
% AGBOT Project at IALR and Virginia Tech for ME 5735.
% 
% Syntax:
% vid = im2vid(Im, f, filename)
% 
% Inputs: 
% Im = Image (cell of images)
% f = Framte Rate of the Video (int)
% filename = Path for Video Location (path)
%
% Outputs:
% vid = Video Object
%
% Example:
% Im{1} = imread('image1.jpg');
% Im{2} = imread('image2.jpg');
% Im{3} = imread('image3.jpg');
% f     = 2; % s images per second
% filename = [pwd 'vid.avi']
% vid = im2vid(Im, f, filename)
%
% Additional required files:
% none
% 
% Subfunctions:
% none
%
% Helpful Information:
% create Image cell: Im{1} = imread('Im1.jpg'); Im{2} = imread('Im2.jpg');
% load image: Im = imread('image.jpg');
% create path: filename = [pwd '/vid.avi'];
%
% Author: Christopher Kappes
% Virginia Tech - ME 5735
% 2016-11-19; Last revision: 2016-11-19

%% ------------- BEGIN CODE --------------

vid = VideoWriter(filename);    % create and save video object
vid.FrameRate = f;              % set frame rate

open(vid);                      % open video object

for ii = 1:length(Im)           % loop through all images
    frame = im2frame(Im{ii});   % image to frame
    writeVideo(vid, frame);     % write video
end                             % end for loop

close(vid);                     % close video object

%% ------------- END OF CODE --------------