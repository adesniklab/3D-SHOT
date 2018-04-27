function [running_speed] = computeSpeed(MotorA,MotorB)

% default rotary encoder has 360 pulses per revolution
% default circumference is 2*pi*7.6 cm = 47.75cm/revolution or 18.84 inches/revolution

global Exp_Defaults

%speed is determined by MotorA right now
runTicks = [double(diff(MotorA)>0); 0];
% tickTimes = find(MotorA==0);

binWidth = 0.1; % in s

binInPnts = Exp_Defaults.Fs * binWidth ; %100ms bin

binnedTicks=[];
nBins = length(runTicks) /binInPnts;
for i=1:nBins
    binnedTicks(i)  = sum(runTicks((i-1)*binInPnts+1:i*binInPnts));
end


circumference = 47.75; %cm at edge of wheel
angularDistance = binnedTicks/360;
LinearDistance = angularDistance * circumference;

running_speed = LinearDistance / binWidth;