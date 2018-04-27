function acquire ()
%% this is the core function of acquisition. It is called by the timer
% function when triggering internally. It initiates data collection and
% analog output via the nidaq card
tic


%call globals
global cell1 cell2 LED Ramp ExpStruct Exp_Defaults h s sweeps countdown globalTimer dmd
%assign local names for varoius variables (for convenience)
% testpulse=ExpStruct.testpulse;




if ExpStruct.readyTorun
    try 
        % generate analog output vectors for each trial
        [AO0 AO1 AO2 AO3] = analogoutput_gen();
        digitalOutputs=digital_outputgen();
        s.queueOutputData([digitalOutputs AO0 AO1 AO2 AO3]);
        
    catch
        stop(globalTimer)
        ExpStruct.readyTorun=1;
        %'Error(1): ISI too short'
        errordlg('Error(1): ISI too short. <acquire>')
        pause(3)
    end
else
    errordlg('Error(2): ISI too short. <acquire>')
end

ExpStruct.readyTorun=0;

% tell NIDAQ when to stop acquisition
s.NotifyWhenDataAvailableExceeds=length(AO0);

% s.NotifyWhenDataAvailableExceeds=round(length(AO0)/100);
% ExpStruct.sweepfraction=0;
% sweeps{ExpStruct.sweep_counter}=[];
% cla(h.Whole_cell1_axes);
% ExpStruct.linehan = line(nan,nan,'Parent',h.Whole_cell1_axes);
%


set(h.running_text,'String','Acquiring!','ForegroundColor','g');
drawnow expose
%% store the analog and digital outputs, but downsample them
ExpStruct.stims{ExpStruct.sweep_counter}={downsample(ExpStruct.LEDoutput1,10), downsample(ExpStruct.CCoutput1,10),...
    downsample(ExpStruct.CCoutput2,10), downsample(ExpStruct.StimLaserEOM,10),downsample(ExpStruct.triggerSI5,10),downsample(ExpStruct.triggerPuffer,10),...
    downsample(ExpStruct.nextholoTrigger,10),downsample(ExpStruct.nextsequenceTrigger,10),downsample(ExpStruct.StimLaserGate,10)};
    
   
    
    
   % downsample(ExpStruct.Lumencor_output,10),...
   % downsample(ExpStruct.Lumencor_disp_output,10)};
%ExpStruct.LCstimint{ExpStruct.sweep_counter}=ExpStruct.LCintensity;

% tic
if ExpStruct.checkStimpattern
    ExpStruct.currentStimpattern=log_stim_pattern;
end
% toc


% Make sure DMD is ready to be triggered
if dmd.useDMD ==1
    calllib('DMD','DLP_Display_DisplayPatternManualForceFirstPattern');
    calllib('DMD','DLP_Display_DisplayPatternAutoStepForSinglePass');
    % calllib('DMD','DLP_Display_DisplayPatternAutoStepRepeatForMultiplePasses')
end

%% start analog scanning and collect the data from the DAQ buffer into data.
% this is the core of the DAQ process

s.prepare
   
s.startBackground

% use the line below to run collection in the foreground- this will prevent matlab
% from doing any other shit during the sweep but also makes it very hard to crash the timer
%data = s.startForeground();

set(countdown,'TaskstoExecute',ceil((Exp_Defaults.ISI-Exp_Defaults.sweepduration)));


% expcom will run the program selected in the program list if the 'run
% program' check box is ticked
expcom


end
