% Version updated for Frankenscope duty 12/16/17 ARM
clear all; close all; clc;
[Setup ] = function_loadparameters(0);
try
load([Setup.Datapath '\07_XYZ_Calibration.mat']);
catch
    disp('Missing Spatial calibration file')
end


%Add power
% HD MEAdowlark SLM
%SLMCoordinatesCenter =   [0.5 0.5 -0.01];
%SLMCoordinatesRange =    [0.15 0.15 0.025];

% Hamamtsu
%SLMCoordinatesCenter =   [0.5 0.5 -0.0];
%SLMCoordinatesRange =    [0.3 0.3 0.04];

% LDMeadowlark
SLMCoordinatesCenter =   [0.5 0.5 -0.01];
SLMCoordinatesRange =    [0.4 0.4 0.04];




MaxNPts = 200;
MaxTrials = 10;
u = zeros(MaxTrials,MaxNPts);

for Npoints = 1:MaxNPts
    disp(Npoints)
for trials = 1:MaxTrials
SLMCoordinates = 2*(rand(3,Npoints)-0.5);
for i = 1:Npoints
SLMCoordinates(:,i) =SLMCoordinates(:,i).*SLMCoordinatesRange';
SLMCoordinates(:,i) =SLMCoordinates(:,i)+SLMCoordinatesCenter';
end
AttenuationCoeffs = function_Power_Adjust( SLMCoordinates', COC );
myattenuation = AttenuationCoeffs;
energy = 1./myattenuation; energy = energy/sum(energy);
u(trials, Npoints) = sum(energy.*myattenuation);
end
end


f = figure(1)
plot(100*mean(u))
xlabel('Number of targets')
ylabel('Typical DE (Percent)')
saveas(f,'LD_Meadowlark_SLM_DE_Data.fig')

Data.NumberOfTargets = 1:MaxNPts;
Data.Diffraction_Efficiency = 100*mean(u); 

save('LD_Meadowlark_SLM_DE_Data.mat', 'Data');


       
