function save2sweeps(src,event)
    
%% save2sweeps is a listener that stores data from the nidaq at the end of each sweep
%

global s sweeps ExpStruct Exp_Defaults cell1 cell2 countdown 

%store channels 1 and 2 in thissweep for further processing
thissweep=event.Data(:,1:2);
thisstarttime=datevec(event.TriggerTime);

% if not first trial store elapsed time to current trial
elapsed_time = etime(thisstarttime, ExpStruct.exp_start_time);
elapsed_time_in_minutes = elapsed_time/60; % convert to minutes
ExpStruct.trialtime(ExpStruct.sweep_counter) = elapsed_time_in_minutes;

% draw current experiment time in whole cell1 axes, stolen from Hillel 
mins = floor(elapsed_time_in_minutes); % get minutes
secs = elapsed_time_in_minutes - mins;
secs = round(secs*60); % convert back to seconds
mins = num2str(mins);
if (secs>9)
    secs = num2str(secs);
else
    secs = num2str(secs);
    secs = strcat('0',secs);
end
current_sweep_time = strcat(mins,':', secs);

% scale from nA to pA or Volts to mV
thissweep=thissweep*1000;

% scale by user gain for each channel
thissweep(:,1)=thissweep(:,1)/cell1.user_gain;
thissweep(:,2)=thissweep(:,2)/cell2.user_gain;

%% Save  Digital
thisDigitalSweep = event.Data(:,5:end);
ExpStruct.digitalSweeps{ExpStruct.sweep_counter} = thisDigitalSweep;
ExpStruct.thisdigitalSweep = thisDigitalSweep;


% store the data in cell array 'sweeps'
sweeps{ExpStruct.sweep_counter}=thissweep;
ExpStruct.cell1sweep=thissweep(:,1);
ExpStruct.cell2sweep=thissweep(:,2);

%call updateGUI to update the GUI
updateGUI;


end