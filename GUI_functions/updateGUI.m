function updateGUI(src,event)
%% function updateGUI is called by save2sweeps at the end of each sweep to update the display

%set globals
global cell1 cell2 LED Ramp ExpStruct Exp_Defaults h s sweeps countdown   


%% high pass sweeps if checked
value4 = get(h.Highpass_check, 'Value');

if (value4 == 1)
    ExpStruct.cell1sweep=highpass_filter(ExpStruct.cell1sweep);
    ExpStruct.cell2sweep=highpass_filter(ExpStruct.cell2sweep);
    %after data collection compute spikes per second
    %     [height, spiketimes ] = get_spike_times(sweeps{ExpStruct.sweep_counter});
    % a = size(spiketimes);
    % cell1.spikerate1(ExpStruct.sweep_counter) = a(2);
    
end

%after data collection analzye inputs for series_r and other properties
analyze_series_r()

%record if last sweep was VC or CC
cell1.rectype(ExpStruct.sweep_counter)=get(h.Cell1_type_popup,'Value');
cell2.rectype(ExpStruct.sweep_counter)=get(h.Cell2_type_popup,'Value');


%% update stimulus tag if using a saved output pattern
%this doesn't work right now for some reason
% for i =1:length(ExpStruct.output_patterns)
%     if length(ExpStruct.output_patterns{i})==length(ExpStruct.CCoutput1)
%         if ExpStruct.output_patterns{i}==[ExpStruct.CCoutput1,ExpStruct.CCoutput2,ExpStruct.LEDoutput1,ExpStruct.LEDoutput2];
%             ExpStruct.stim_tag(ExpStruct.sweep_counter) = i;
%             set(h.trial_stim,'String',ExpStruct.output_names{i});
%         end
%     end
% end
ExpStruct.stim_tag(ExpStruct.sweep_counter)=ExpStruct.currentStimpattern;


%%HOLO CONTROL
updateHoloRequest; % looks for a new holoRequest file in HoloRequest-DAQ folder and saves it
getCurrentHolo; %grabs current holo
ExpStruct.Holo.Sweeps_holoRequestNumber(ExpStruct.sweep_counter)=ExpStruct.Holo.holoRequestNumber;
ExpStruct.Holo.Sweeps_CurrentHolo{ExpStruct.sweep_counter}=ExpStruct.Holo.currentHolo; 
ExpStruct.Holo.Sweeps_CurrentROIsON{ExpStruct.sweep_counter}=ExpStruct.Holo.currentROIsON; 

if ExpStruct.dynamicPowerCorrection;
    
dynamicPowerAdjustment
end



%% increment sweep counter
%this is a very important step that is placed in a rather stupid spot
%anything logging a variable for an in progress sweep should call before
%this
%anything logging or settng a variable for the upcoming sweep should call
%after

set(h.current_sweep_number,'String',num2str(ExpStruct.sweep_counter));
ExpStruct.sweep_counter=ExpStruct.sweep_counter+1;

%%

% test if should plot data from channel2
value3 = get(h.record_cell2_check, 'Value');



%% plot the data on the corresponding axes in the GUI figure
plot(h.Whole_cell1_axes,ExpStruct.timebase,ExpStruct.cell1sweep);
plot(h.Whole_cell1_axes_Ih, ExpStruct.trialtime, cell1.holding_i,'o');

val = get(h.Highpass_check, 'Value'); % check for highpass filtering
if (val == 1)
    %    plot(h.Whole_cell1_axes_Rs, ExpStruct.trialtime, cell1.spikerate1,'o');
    %in hillels code this will plot spike rate if you are highpass filtering
    %your sweeps but it will get fucked up if your sweeps are too short
else
    plot(h.Whole_cell1_axes_Rs, ExpStruct.trialtime, cell1.series_r,'o');
end

plot(h.Whole_cell1_axes_Ir, ExpStruct.trialtime, cell1.input_r,'o')


% plot series resistance, input resistance, and holding current
if (value3 == 1) % if recording two cells
    plot(h.Whole_cell2_axes,ExpStruct.timebase,ExpStruct.cell2sweep);
    plot(h.Whole_cell2_axes_Ih,ExpStruct.trialtime,cell2.holding_i,'o');
    plot(h.Whole_cell2_axes_Rs,ExpStruct.trialtime,cell2.series_r,'o');
    plot(h.Whole_cell2_axes_Ir,ExpStruct.trialtime,cell2.input_r,'o');
end


labelaxes()

%% check if default saving checkbox is checked, otherwise don't save; when
% using external triggering avoid saving after each trial because saving
% can cause acquisition to miss triggers

saveval =  get(h.default_save_check, 'Value');
if (saveval==1)
    save(ExpStruct.SaveName);
end

%% draw elapsed experiment time in whole cell1 axes
ymax = get(h.Whole_cell1_axes, 'YLim'); ymax = ymax(2);
xmax = get(h.Whole_cell1_axes, 'XLim'); xmax = xmax(2);
% text(0.9*xmax,0.9*ymax,current_sweep_time,'Parent',h.Whole_cell1_axes);

%% old hillel stuff
% do post trial analysis for cell1
% 
% % % if (get(h.addcursors_radio,'Value')==1)
% if isfield(ExpStruct,'analysis_limits')
%     output1=analyze_wholecell(1);
%     ExpStruct.runningplot1(ExpStruct.sweep_counter-1)=output1; % -1 b/c analsyis comes after incrementing the sweep counter
%     plot(h.analysis1_axes, ExpStruct.trialtime, ExpStruct.runningplot1, 'o');
% end
% if (get(h.addcursors_radio2,'Value')==1)
%     output2=analyze_wholecell(2);
%     ExpStruct.runningplot2(ExpStruct.sweep_counter-1)=output2; % -1 b/c analsyis comes after incrementing the sweep counter
%     plot(h.analysis1_axes, ExpStruct.trialtime, ExpStruct.runningplot2, 'o');
% end
%
 

% keep cursor lines on if checked % comment out to prevent cursur update
% Don't know what this does
% if (get(h.addcursors_radio,'Value')==1)
%     dualcursor([ExpStruct.analysis_limits.cell1(1) ExpStruct.analysis_limits.cell1(3)],[],[],[],h.Whole_cell1_axes);
% end
% if (get(h.addcursors_radio2,'Value')==1)
%      dualcursor([ExpStruct.analysis_limits.cell2(1) ExpStruct.analysis_limits.cell2(3)],[],[],[],h.Whole_cell1_axes);
% end




%% postSweepexpCom will evaluate any string saved in 'ExpStruct.postSweepprogramChoice'
% use this to call functions in between sweeps, be careful of fucking up
% the timer if they take too long
postSweepexpCom


%%
%set(h.running_text,'String','');

ExpStruct.readyTorun=1;
if Exp_Defaults.ISI-Exp_Defaults.sweepduration>1
    start(countdown);
end

end