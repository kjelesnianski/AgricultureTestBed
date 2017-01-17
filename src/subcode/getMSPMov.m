%% getMSPMov

%% Description
% getMSPMov is responsible for determining the needed motion needed
% in order to get the AgBed Head to the newly input position, either
% manually or from an automatic run. Since the AgBed always knows
% position, it mathematically computes the number of motor steps
% needed to get to the next position to carry out actions at a given
% plant spot.
% The distance is computed in terms of motor steps, hence 7-digit
% precision to ensure the AgBed head can reach all space within the
% CNC bed from the current. 
% 
% asked Inputs: 
% Current Head Position ([X Y Z] matrix)
% The new Head Position that the AgBed needs to move to 
% ([X Y Z] matrix)
%
% Outputs:
% A formated data packet to be sent to the MSP432 to iniate motor
% action to get to the new position.
%
% Additional required files:
% none
% 
% Subfunctions:
% none
%
% Helpful Information:
% NOTE: newPos/currPos ARE 1x3 Matrices!!
% X = Position 1
% Y = Position 2
% Z = Position 3
% Data Packet Format (7 digit percision)
% X0000000 Y0000000 Z0000000 D(XDir)(YDir)(ZDir)
%
% Author: Christopher Jelesnianski
% Virginia Tech - ME 5735 
% 2016-11-30; Last revision: 2016-12-01

%% ------------- BEGIN CODE --------------

function mov = getMSPMov(currPos, newPos)

steps = abs(newPos - currPos); % Subtracts currPos matrix from newPos Matrix and gets absolute 
dir = newPos - currPos; % Gets direction for each direction
dir(dir >= 0) = 1; % If dir element is >= 0, denote it going in the positive direction
dir(dir < 0) = 0; % If dir element is < 0, denote it going in the negative direction

% Creates MSP432 data packet in 'mov' variable.
mov = ['X', num2str(steps(1), '%07i'), 'Y', num2str(steps(2), '%07i'), 'Z', num2str(steps(3), '%07i'), 'D', num2str(dir(1)) num2str(dir(2)) num2str(dir(3))]; 

end

%% -------------- END CODE --------------
