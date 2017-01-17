function imLable = imLable(Im, exper, plantNum, imNum)

%% Description
% The imLable function adds a lable to the inputed image. Lable settings
% can be changed inside the function. This function was created for the
% AGBOT Project at IALR and Virginia Tech for ME 5735.
% 
% Syntax:
% imLable = imLable(Im, exp, plantNum, imNum)
% 
% Inputs: 
% Im = Image (image object)
% exper = Name of experiment (str)
% plantNum = Number of plant (int)
% imNum = Number of image (int)
%
% Outputs:
% imLable = Inputed image with lable (image object)
%
% Example:
% imLable = imLable(Im, 'Test Trial', 4, 1032)        
%
% Additional required files:
% none
% 
% Subfunctions:
% none
%
% Helpful Information:
% load image: Im = imread('image.jpg');
% save image: imwrite(Im, 'image.bmp', 'bmp')
% show image: imshow(Im)
%
% Author: Christopher Kappes
% Virginia Tech - ME 5735
% 2016-11-19; Last revision: 2016-11-19

%% ------------- BEGIN CODE --------------

text     = ['AGBED@IALR-VT', '|', ...
           'Exper.: ', exper, '|', ...
           '#Plant: ', num2str(plantNum,'%03i'),'|', ...
           '#Im.: ', num2str(imNum,'%06i'), ...
           datestr(datetime, '|yyyy-mm-dd|HH:MM:SS')];
imLable  = insertText(Im, [0 0], text, ...
           'FontSize', 18, 'BoxColor', 'white', ...
           'BoxOpacity', 0.5, 'TextColor', 'black');

%% ------------- END OF CODE --------------