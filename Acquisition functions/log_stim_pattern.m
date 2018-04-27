function stimident=log_stim_pattern()

global ExpStruct 
try
currentstim=[ExpStruct.CCoutput1 ExpStruct.CCoutput2 ExpStruct.LEDoutput1...
    ExpStruct.StimLaserGate ExpStruct.StimLaserEOM ExpStruct.triggerSI5...
    ExpStruct.triggerPuffer ExpStruct.nextholoTrigger ExpStruct.nextsequenceTrigger...
    ExpStruct.motorTrigger];
catch
currentstim=[ExpStruct.CCoutput1 ExpStruct.CCoutput2 ExpStruct.LEDoutput1...
    ExpStruct.StimLaserGate' ExpStruct.StimLaserEOM ExpStruct.triggerSI5...
    ExpStruct.triggerPuffer ExpStruct.nextholoTrigger ExpStruct.nextsequenceTrigger...
    ExpStruct.motorTrigger];
end

%errordlg('called');



stimident=0;

    for i = 1:length(ExpStruct.stimlog)
        if isequal(currentstim,cell2mat(ExpStruct.stimlog{i}))
            stimident=i;
        end
    end

    if stimident>0
        ExpStruct.currentStimpattern=stimident;
    else
        ExpStruct.stimlog{i+1}={currentstim};
        stimident=i+1;
    end
    
    ExpStruct.checkStimpattern=0