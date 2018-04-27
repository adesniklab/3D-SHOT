%loads output patterns from the list available
function load_outputs(pattern_no)
global h Exp_Defaults ExpStruct Ramp

ExpStruct.checkStimpattern = 1;

ExpStruct.CCoutput1=ExpStruct.output_patterns{pattern_no}(:,1);
ExpStruct.CCoutput2=ExpStruct.output_patterns{pattern_no}(:,2);
ExpStruct.LEDoutput1=ExpStruct.output_patterns{pattern_no}(:,3);
ExpStruct.StimLaserGate = ExpStruct.output_patterns{pattern_no}(:,4);
ExpStruct.StimLaserEOM = ExpStruct.output_patterns{pattern_no}(:,5);
ExpStruct.triggerSI5 = ExpStruct.output_patterns{pattern_no}(:,6);
ExpStruct.triggerPuffer = ExpStruct.output_patterns{pattern_no}(:,7);
ExpStruct.nextholoTrigger = ExpStruct.output_patterns{pattern_no}(:,8);
ExpStruct.nextsequenceTrigger = ExpStruct.output_patterns{pattern_no}(:,9);
ExpStruct.motorTrigger = ExpStruct.output_patterns{pattern_no}(:,10);

%set current Ramp to match rampList, if doesn't exist gives 
try
    ExpStruct.CurrentRamp = ExpStruct.RampList{pattern_no};
catch
    disp('no Ramp List found. Possibly old config file. setting to default');
    ExpStruct.CurrentRamp=ExpStruct.RampList{1};
end

%ExpStruct.LEDoutput2=ExpStruct.output_patterns{pattern_no}(:,4);
%ExpStruct.Lumencor_output=ExpStruct.output_patterns{pattern_no}(:,5:10);
%ExpStruct.Lumencor_disp_output=ExpStruct.output_patterns{pattern_no}(:,11:16);

if length(ExpStruct.timebase) > length(ExpStruct.LEDoutput1);
    tempTimebase = zeros(length(ExpStruct.timebase),1);
    tempCCoutput1 = tempTimebase;
    tempCCoutput1(1:length(ExpStruct.CCoutput1)) = tempCCoutput1(1:length(ExpStruct.CCoutput1))+ ExpStruct.CCoutput1;
    ExpStruct.CCoutput1= tempCCoutput1;
    tempCCoutput2 = tempTimebase;
    tempCCoutput2(1:length(ExpStruct.CCoutput2)) = tempCCoutput2(1:length(ExpStruct.CCoutput2))+ ExpStruct.CCoutput2;
    ExpStruct.CCoutput2= tempCCoutput2;
    tempLEDoutput1 = tempTimebase;
    tempLEDoutput1(1:length(ExpStruct.LEDoutput1)) = tempLEDoutput1(1:length(ExpStruct.LEDoutput1))+ ExpStruct.LEDoutput1;
    ExpStruct.LEDoutput1= tempLEDoutput1;
    tempStimLaserGate = tempTimebase;
    tempStimLaserGate(1:length(ExpStruct.StimLaserGate)) = tempStimLaserGate(1:length(ExpStruct.StimLaserGate))+ ExpStruct.StimLaserGate;
    ExpStruct.StimLaserGate= tempStimLaserGate;
    
    tempStimLaserEOM = tempTimebase;
    tempStimLaserEOM(1:length(ExpStruct.StimLaserEOM)) = tempStimLaserEOM(1:length(ExpStruct.StimLaserEOM))+ ExpStruct.StimLaserEOM;
    ExpStruct.StimLaserEOM= tempStimLaserEOM;
    
    temptriggerSI5 = tempTimebase;
    temptriggerSI5(1:length(ExpStruct.triggerSI5)) = temptriggerSI5(1:length(ExpStruct.triggerSI5))+ ExpStruct.triggerSI5;
    ExpStruct.triggerSI5= temptriggerSI5;
    
    temptriggerPuffer = tempTimebase;
    temptriggerPuffer(1:length(ExpStruct.triggerPuffer)) = temptriggerPuffer(1:length(ExpStruct.triggerPuffer))+ ExpStruct.triggerPuffer;
    ExpStruct.triggerSI5= temptriggerPuffer;
    
    tempnextholoTrigger = tempTimebase;
    tempnextholoTrigger(1:length(ExpStruct.nextholoTrigger)) = tempnextholoTrigger(1:length(ExpStruct.nextholoTrigger))+ ExpStruct.nextholoTrigger;
    ExpStruct.nextholoTrigger= tempnextholoTrigger;
    
    tempnextsequenceTrigger = tempTimebase;
    tempnextsequenceTrigger(1:length(ExpStruct.nextsequenceTrigger)) = tempnextsequenceTrigger(1:length(ExpStruct.nextsequenceTrigger))+ ExpStruct.nextsequenceTrigger;
    ExpStruct.nextsequenceTrigger= tempnextsequenceTrigger;
    
    tempmotorTrigger = tempTimebase;
    tempmotorTrigger(1:length(ExpStruct.motorTrigger)) = tempmotorTrigger(1:length(ExpStruct.motorTrigger))+ ExpStruct.motorTrigger;
    ExpStruct.motorTrigger= tempmotorTrigger;

  
    
    
%     for i = 1:6
%     tempLCoutput = tempTimebase;
%     tempLCoutput(1:length(ExpStruct.Lumencor_output(:,i))) = tempLCoutput(1:length(ExpStruct.Lumencor_output(:,i)))+ ExpStruct.Lumencor_output(:,i);
%     ExpStruct.Lumencor_output(1:length(tempTimebase),i)= tempLCoutput;
%     tempLCdispoutput = tempTimebase;
%     tempLCdispoutput(1:length(ExpStruct.Lumencor_disp_output(:,i))) = tempLCdispoutput(1:length(ExpStruct.Lumencor_disp_output(:,i)))+ ExpStruct.Lumencor_disp_output(:,i);
%     ExpStruct.Lumencor_disp_output(1:length(tempTimebase),i)=tempLCdispoutput;
%     end
elseif length(ExpStruct.timebase) < length(ExpStruct.LEDoutput1);
    ExpStruct.CCoutput1=ExpStruct.CCoutput1(1:length(ExpStruct.timebase));
    ExpStruct.CCoutput2=ExpStruct.CCoutput2(1:length(ExpStruct.timebase));
    ExpStruct.LEDoutput1=ExpStruct.LEDoutput1(1:length(ExpStruct.timebase));
    ExpStruct.StimLaserGate=ExpStruct.StimLaserGate(1:length(ExpStruct.timebase));
    ExpStruct.StimLaserEOM=ExpStruct.StimLaserEOM(1:length(ExpStruct.timebase));
    ExpStruct.triggerSI5=ExpStruct.triggerSI5(1:length(ExpStruct.timebase));
    ExpStruct.triggerPuffer=ExpStruct.triggerPuffer(1:length(ExpStruct.timebase));
    ExpStruct.nextholoTrigger=ExpStruct.nextholoTrigger(1:length(ExpStruct.timebase));
    ExpStruct.nextsequenceTrigger=ExpStruct.nextsequenceTrigger(1:length(ExpStruct.timebase));
    ExpStruct.motorTrigger=ExpStruct.motorTrigger(1:length(ExpStruct.timebase));

    % ExpStruct.Lumencor_output=ExpStruct.Lumencor_output(1:length(ExpStruct.timebase),:);
   % ExpStruct.Lumencor_disp_output=ExpStruct.Lumencor_disp_output(1:length(ExpStruct.timebase),:);
end

updateAOaxes