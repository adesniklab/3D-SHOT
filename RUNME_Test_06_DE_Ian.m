% Version updated for Frankenscope duty 12/16/17 ARM
clear all; close all; clc;
[Setup ] = function_loadparameters(0);
try
load([Setup.Datapath '\07_XYZ_Calibration.mat']);
catch
    disp('Missing Spatial calibration file')
end


% LDMeadowlark
SICoordinates =   [250 250 25]';

calibID = 2;
SLMCoordinates(1,:) = polyvaln(COC.SI_SLM_X{calibID} ,SICoordinates');
SLMCoordinates(2,:) = polyvaln(COC.SI_SLM_Y{calibID} ,SICoordinates');
SLMCoordinates(3,:) = polyvaln(COC.SI_SLM_Z{calibID} ,SICoordinates');

AttenuationCoeffs = function_Power_Adjust( SLMCoordinates', COC );
myattenuation = AttenuationCoeffs;
energy = 1./myattenuation; energy = energy/sum(energy);
DE = sum(energy.*myattenuation)
