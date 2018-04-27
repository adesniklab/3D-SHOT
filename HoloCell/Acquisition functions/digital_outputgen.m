function [ digitalOutputs ] = digital_outputgen()

global ExpStruct

digitalOutputs(:,1)=ExpStruct.triggerSI5;
digitalOutputs(:,2)=ExpStruct.triggerPuffer;
digitalOutputs(:,3)=ExpStruct.nextholoTrigger;
digitalOutputs(:,4)=ExpStruct.nextsequenceTrigger;
digitalOutputs(:,5)=ExpStruct.StimLaserGate;
digitalOutputs(:,6)=ExpStruct.motorTrigger;


% ExpStruct.StimLaserGate=zeros(size(ExpStruct.LEDoutput1));
% ExpStruct.StimLaserEOM=zeros(size(ExpStruct.LEDoutput1));
% ExpStruct.triggerSI5=zeros(size(ExpStruct.LEDoutput1));
% ExpStruct.triggerPuffer=zeros(size(ExpStruct.LEDoutput1));
% ExpStruct.nextholoTrigger=zeros(size(ExpStruct.LEDoutput1));
% ExpStruct.nextsequenceTrigger=zeros(size(ExpStruct.LEDoutput1));
% ExpStruct.motorTrigger=zeros(size(ExpStruct.LEDoutput1));


end

