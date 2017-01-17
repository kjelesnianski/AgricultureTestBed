%% newPos

%% Description
% newPos decodes the currently received data packet from the MSP432
% (mov variable) and adds the completed movement values to the
% AgBed's Head current position (oldPos). From this the AgBed's
% Head's new position is calculated and upated in the main program. 
% 
% asked Inputs: 
% The AgBed Head Current Position Matrix ([X Y Z] matrix)
% The received MSP432 data packet
%
% Outputs:
% A matrix containing the AgBed Head's new position
%
% Additional required files:
% none
% 
% Subfunctions:
% none
%
% Helpful Information:
% NOTE: oldPos/newPos ARE 1x3 Matrices!!
% mov is a MSP432 Data Packet
% X = Position 1
% Y = Position 2
% Z = Position 3
% % Data Packet Format (7 digit percision)
% X0000000 Y0000000 Z0000000 D(XDir)(YDir)(ZDir)
%
% Author: Christopher Jelesnianski
% Virginia Tech - ME 5735 
% 2016-11-30; Last revision: 2016-12-01

%% ------------- BEGIN CODE --------------

function newPos = newPos(oldPos, mov)

movX = str2num(mov((strfind(mov, 'X')+1):(strfind(mov, 'Y')-1))); % Parse for Stepper movement in X axis
movY = str2num(mov((strfind(mov, 'Y')+1):(strfind(mov, 'Z')-1))); % Parse for Stepper movement in Y axis
movZ = str2num(mov((strfind(mov, 'Z')+1):(strfind(mov, 'D')-1))); % Parse for Stepper movement in Z axis
d    = mov((strfind(mov, 'D')+1):end); % Parse for Stepper movement direction (1==+, 0==-)

dir  = [str2num(d(1)), str2num(d(2)), str2num(d(3))]; % Convert to number
dir(dir==0) = -1; % Convert all 0 direction axis to be negative such that the value is subtracted

mov = [movX, movY, movZ]; % Put parsed values into matrix

newPos = oldPos+dir.*mov; % Calculate new Head Position

end

%% ------------- END OF CODE --------------
