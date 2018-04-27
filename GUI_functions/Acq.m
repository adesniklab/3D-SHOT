function varargout = Acq(varargin)

% ACQ MATLAB code for Acq.fig
%      ACQ, by itself, creates a new ACQ or raises the existing
%      singleton*.
%
%      H = ACQ returns the handle to a new ACQ or the handle to
%      the existing singleton*.
%
%      ACQ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACQ.M with the given input arguments.
%
%      ACQ('Property','Value',...) creates a new ACQ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Acq_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Acq_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Acq

% Last Modified by G UIDE v2.5 13-Feb-2013 14:39:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Acq_OpeningFcn, ...
    'gui_OutputFcn',  @Acq_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Acq is made visible.
function Acq_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Acq (see VARARGIN)

% Choose default command line output for Acq
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes Acq wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Acq_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
global globalTimer Exp_Defaults s h countdown

set(h.StartButton,'BackgroundColor',[0.8 0.8 0.8])
set(h.StopButton,'BackgroundColor','r')

stop(globalTimer)
stop(countdown)
set(countdown,'TaskstoExecute',1);
set(h.running_text,'String','')

function Whole_cell1_axes_CreateFcn(hObject, eventdata, handles)

% Hint: place code in OpeningFcn to populate Whole_cell1_axes

% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
global globalTimer h ExpStruct Exp_Defaults listener

if isempty(ExpStruct.SaveName)
    k = errordlg('Set expermient name')
end

listener.Enabled = true;
set(h.StartButton,'BackgroundColor','g')
set(h.StopButton,'BackgroundColor',[0.8 0.8 0.8])

% if using internal triggering
if (Exp_Defaults.ExternalTrigger==0)
    start(globalTimer)
    
    % if using external triggering don't use timer fcn
else
    
    acquire()
end

function set_ISI_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of set_ISI as text
%        str2double(get(hObject,'String')) returns contents of set_ISI as a double
global Exp_Defaults globalTimer h
Exp_Defaults.ISI=str2double(get(hObject,'String'));

if Exp_Defaults.ISI <= Exp_Defaults.sweepduration
    Exp_Defaults.ISI=Exp_Defaults.sweepduration+0.5;
    errordlg('ISI must be longer than a sweep');
    set(h.set_ISI,'string',num2str(Exp_Defaults.ISI));
end

if (Exp_Defaults.ExternalTrigger==0)
    stop(globalTimer);
    globalTimer=timer('TimerFcn', 'waitfornidaq', 'TaskstoExecute', Exp_Defaults.total_sweeps, 'Period',Exp_Defaults.ISI, 'ExecutionMode','fixedRate');
end

% --- Executes during object creation, after setting all properties.
function set_ISI_CreateFcn(hObject, eventdata, handles)

global h Exp_Defaults
set(hObject,'String',num2str(Exp_Defaults.ISI));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ext_cmd_1_check.
function ext_cmd_1_check_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of ext_cmd_1_check


function set_length_Callback(hObject, eventdata, handles)
% For changing the duration of sweeps
global Exp_Defaults ExpStruct LED cell1 cell2 motor Ramp h

Exp_Defaults.sweepduration=str2double(get(hObject,'String'));

if Exp_Defaults.ISI <= Exp_Defaults.sweepduration
    Exp_Defaults.ISI=Exp_Defaults.sweepduration+0.5;
    errordlg('ISI must be longer than a sweep');
    set(h.set_ISI,'string',num2str(Exp_Defaults.ISI));
end


ExpStruct.timebase=linspace(0,Exp_Defaults.sweepduration,(Exp_Defaults.Fs*Exp_Defaults.sweepduration));
%truncate or 0 pad the analog outputs
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
    ExpStruct.triggerPuffer= temptriggerPuffer;
    
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

ExpStruct.checkStimpattern = 1;

updateAOaxes



% --- Executes during object creation, after setting all properties.
function set_length_CreateFcn(hObject, eventdata, handles)

global Exp_Defaults
set(hObject,'String',num2str(Exp_Defaults.sweepduration));

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end

% --- Executes during object creation, after setting all properties.
function Whole_cell1_axes_Rs_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ext_cmd_1_check_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in ext_cmd_2_check.
function ext_cmd_2_check_Callback(hObject, eventdata, handles)

% --- Executes on button press in VC_toggle_WC1.
function VC_toggle_WC1_Callback(hObject, eventdata, handles)

% --- Executes on button press in VC_toggle_WC2.
function VC_toggle_WC2_Callback(hObject, eventdata, handles)


function rampstart_voltage_Callback(hObject, eventdata, handles)
global Ramp
value = get(handles.rampnotpulse, 'Value');

Ramp.rampstart_voltage=str2double(get(hObject,'String'));
if ~value
    Ramp.rampend_voltage=str2double(get(hObject,'String'));
    set(handles.rampend_voltage,'string',num2str(Ramp.rampstart_voltage));
end;
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function rampstart_voltage_CreateFcn(hObject, eventdata, handles)

global Ramp
set(hObject,'String',num2str(Ramp.rampstart_voltage));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rampend_voltage_Callback(hObject, eventdata, handles)
global Ramp
value = get(handles.rampnotpulse, 'Value');
if value
    Ramp.rampend_voltage=str2double(get(hObject,'String'));
end;

% --- Executes during object creation, after setting all properties.
function rampend_voltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rampend_voltage (see GCBO)
global Ramp
set(hObject,'String',num2str(Ramp.rampend_voltage));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rampstart_time_Callback(hObject, eventdata, handles)
global Ramp
Ramp.rampstart_time=str2double(get(hObject,'String'));



% --- Executes during object creation, after setting all properties.
function rampstart_time_CreateFcn(hObject, eventdata, handles)
global Ramp
set(hObject,'String',num2str(Ramp.rampstart_time));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ramp_frequency_Callback(hObject, eventdata, handles)
global Ramp
Ramp.ramp_frequency=str2double(get(hObject,'String'));



% --- Executes during object creation, after setting all properties.
function ramp_frequency_CreateFcn(hObject, eventdata, handles)
global Ramp
set(hObject,'String',num2str(Ramp.ramp_frequency));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in analsyis_popup.
function analsyis_popup_Callback(hObject, eventdata, handles)

val = get(hObject,'Value');
switch val
    case 1
        avg_traces
    case 2
        plot_amps
    case 3
        plot_charge
end

% --- Executes during object creation, after setting all properties.
function analsyis_popup_CreateFcn(hObject, ~, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in VC_cell1_radio.
function VC_cell1_radio_Callback(hObject, eventdata, handles)

global h cell1 cell2 ExpStruct
if get(hObject,'Value')~=1
    ylabel(h.Whole_cell1_axes,'mV')
    
    if get(h.LFP_check, 'Value')~=1
        cell1.user_gain=20; % set gain to 20 for whole cell current clamp
    else
        cell1.user_gain=500; % set gain to 500 for LFP recording
    end
    
else
    
    cell1.user_gain=1;
    ylabel(h.Whole_cell1_axes,'pA')
    
end
ExpStruct.CCoutput1=makepulseoutputs(cell1.pulse_starttime,cell1.pulsenumber, cell1.pulseduration, cell1.pulseamp, cell1.pulsefrequency, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.CCoutput1=ExpStruct.CCoutput1/cell1.externalcommandsensitivity;
ExpStruct.CCoutput2=makepulseoutputs(cell2.pulse_starttime,cell2.pulsenumber, cell2.pulseduration, cell2.pulseamp, cell2.pulsefrequency, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.CCoutput2=ExpStruct.CCoutput2/cell1.externalcommandsensitivity;
% Hint: get(hObject,'Value') returns toggle state of VC_cell1_radio


% --- Executes on button press in VC_cell2_radio.
function VC_cell2_radio_Callback(hObject, eventdata, handles)

global h cell2
if get(hObject,'Value')~=1
    ylabel(h.Whole_cell2_axes,'mV')
    cell2.user_gain=20;
else
    ylabel(h.Whole_cell2_axes,'pA')
    cell2.user_gain=1;
end
% Hint: get(hObject,'Value') returns toggle state of VC_cell2_radio

function changesweep
% Changes the sweep displayed in the bottom left window
global h ExpStruct Exp_Defaults sweeps

SetSweepNumber=ExpStruct.SetSweepNumber;
value3 = get(h.record_cell2_check, 'Value'); % check if dual whole cell
if value3
    dispCell1 = get(h.dispCell1,'Value');
    dispCell2 = get(h.dispCell2,'Value');
else
    set(h.dispCell1,'Value',1);
    set(h.dispCell1,'enable','off');
    set(h.dispCell2,'Value',0);
    set(h.dispCell2,'enable','off');
    
    dispCell1 = 1;
    dispCell2 = 0;
end

set(h.SetSweepNumber,'String',num2str(SetSweepNumber));
sweeppoints=size(sweeps{ExpStruct.SetSweepNumber});
tim=linspace(0,sweeppoints(:,1)/Exp_Defaults.Fs,sweeppoints(:,1));

val4 = get(h.axes_hold_check, 'Value'); %
% if checked get current axes limits
if (val4 == 1)
    xlimits = get(h.sweep_display_axes,'xlim');
    ylimits = get(h.sweep_display_axes, 'ylim');
end

val = get(h.Highpass_check, 'Value'); % check for highpass filtering

if dispCell1 && dispCell2
    
    thissweep=sweeps{ExpStruct.SetSweepNumber};
    
    if (val ==1)
        thissweep1=highpass_filter(thissweep(:,1));
        thissweep2=highpass_filter(thissweep(:,2));
    else
        thissweep1=thissweep(:,1);
        %     thissweep1= smart_zero(thissweep1);
        thissweep2=thissweep(:,2);
        %     thissweep2 = smart_zero(thissweep2);
    end
    
    plot(h.sweep_display_axes,tim, thissweep1, 'color', 'b');
    hold(h.sweep_display_axes, 'on');
    plot(h.sweep_display_axes,tim, thissweep2,'color','r');
    hold(h.sweep_display_axes, 'off');
else
    thissweep=sweeps{ExpStruct.SetSweepNumber};
    if size(sweeps{ExpStruct.SetSweepNumber},2)==1
        thissweep=thissweep(:);
    elseif dispCell1
        thissweep=thissweep(:,1);
    elseif dispCell2
        thissweep=thissweep(:,2);
    else
        thissweep=zeros(size(thissweep));
    end
    %     thissweep=smart_zero(thissweep);
    if (val == 1)
        thissweep=highpass_filter(thissweep); % if checked highpass filter
    end
    
    if dispCell2
        plot(h.sweep_display_axes,tim, thissweep,'color','r');
    else
        plot(h.sweep_display_axes,tim, thissweep,'color','b'); % if just single cell just plot cell1
    end
    
end

if val4 == 1 % if holding axes limits
    xlim(h.sweep_display_axes, [xlimits(1) xlimits(2)]);
    ylim(h.sweep_display_axes, [ylimits(1) ylimits(2)]);
end

xlabel(h.sweep_display_axes, 'seconds')
ylabel(h.sweep_display_axes, 'pA')
set(h.tag,'String',num2str(ExpStruct.stim_tag(ExpStruct.SetSweepNumber)));
if ExpStruct.stim_tag(ExpStruct.SetSweepNumber)>0
    set(h.trial_stim,'String',ExpStruct.stimName{ExpStruct.stim_tag(ExpStruct.SetSweepNumber)});
end



% --- Executes on button press in previoussweep_button.
function previoussweep_button_Callback(hObject, eventdata, handles)
global h ExpStruct Exp_Defaults sweeps

SetSweepNumber=ExpStruct.SetSweepNumber;
thissweep=ExpStruct.thissweep;

if (SetSweepNumber < 1) % if trying to view traces that don't exist yet get error
    k = errordlg('No earlier sweeps');
else
    
    SetSweepNumber=SetSweepNumber-1;
    ExpStruct.SetSweepNumber=SetSweepNumber;
    changesweep
end

% --- Executes on button press in nextsweep_button.
function nextsweep_button_Callback(hObject, eventdata, handles)

global h ExpStruct Exp_Defaults sweeps

SetSweepNumber=ExpStruct.SetSweepNumber;
thissweep=ExpStruct.thissweep;
sweep_counter=ExpStruct.sweep_counter;
sweepcount=size(sweeps);
if (SetSweepNumber >= sweepcount(2)) % if trying to view traces that don't exist yet get error
    k = errordlg('No more sweeps');
else
    
    val = get(h.Highpass_check, 'Value');
    ExpStruct.SetSweepNumber=ExpStruct.SetSweepNumber+1;
    changesweep
end

function SetSweepNumber_Callback(hObject, eventdata, handles)
%if you enter a sweep number manually
global h ExpStruct Exp_Defaults sweeps
ExpStruct.SetSweepNumber=str2double(get(hObject,'String'));
changesweep


% --- Executes during object creation, after setting all properties.
function SetSweepNumber_CreateFcn(hObject, eventdata, handles)

global ExpStruct
SetSweepNumber=ExpStruct.SetSweepNumber;
SetSweepNumber=1;
set(hObject,'String',num2str(SetSweepNumber));

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SavePath_Callback(hObject, eventdata, handles)
global ExpStruct
ExpStruct.SavePath=(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function SavePath_CreateFcn(hObject, eventdata, handles)

global ExpStruct
set(hObject,'String',ExpStruct.SavePath);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExperimentName_Callback(hObject, eventdata, handles)
global ExpStruct
ExpStruct.ExperimentName=(get(hObject,'String'));
ExpStruct.SaveName=strcat(ExpStruct.SavePath,ExpStruct.ExperimentName);

function ExperimentName_CreateFcn(hObject, eventdata, handles)

global ExpStruct % ExperimentName
set(hObject,'String',ExpStruct.ExperimentName);

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function current_sweep_number_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.

function current_sweep_number_CreateFcn(hObject, eventdata, handles)

global ExpStruct
set(hObject,'String',num2str(ExpStruct.sweep_counter));

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in hold_sweep_display_axes.
function hold_sweep_display_axes_Callback(hObject, eventdata, handles)

global h
hold(h.sweep_display_axes);
% Hint: get(hObject,'Value') returns toggle state of hold_sweep_display_axes

% --- Executes on button press in record_cell2_check.
function record_cell2_check_Callback(hObject, eventdata, handles)
global h
dualRecord=get(hObject,'Value');
if dualRecord
    set(h.dispCell1,'enable','on');
    set(h.dispCell2,'enable','on');
else
    set(h.dispCell1,'enable','off');
    set(h.dispCell2,'enable','off');
end

% Hint: get(hObject,'Value') returns toggle state of record_cell2_check

% --- Executes on button press in Highpass_check.
function Highpass_check_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of Highpass_check

function highpass_freq1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of highpass_freq1 as text
%        str2double(get(hObject,'String')) returns contents of highpass_freq1 as a double

% --- Executes during object creation, after setting all properties.
function highpass_freq1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Whole_cell2_axes_CreateFcn(hObject, eventdata, handles)

% Hint: place code in OpeningFcn to populate Whole_cell2_axes

% --- Executes on button press in ExtTrigger_Button.
function ExtTrigger_Button_Callback(hObject, eventdata, handles)
% External Trigger button deleted by Alex
% global Exp_Defaults s
% % Hint: get(hObject,'Value') returns toggle state of ExtTrigger_toggle
% Trig_value = get(hObject, 'Value');
% if (Trig_value == 1)
%     Exp_Defaults.ExternalTrigger = 1;
%     if (isempty(s.Connections)) % check if external trigger connection doesn't exists
%         s.addTriggerConnection('External','dev1/PFI1','StartTrigger');
%         s.TriggerCondition = 'RisingEdge';
%     end
% else
%     Exp_Defaults.ExternalTrigger = 0;
%     s.removeConnection(1);
% end


% --- Executes on selection change in Cell1_type_popup.
function Cell1_type_popup_Callback(hObject, eventdata, handles)

global h cell1
val = get(hObject,'Value');
switch val
    case 1
        cell1.user_gain=1;
        ylabel(h.Whole_cell1_axes,'pA')
        cell1.externalcommandsensitivity=20;
    case 2
        cell1.user_gain=20;
        ylabel(h.Whole_cell1_axes,'mV')
        cell1.externalcommandsensitivity=400;
    case 3
        cell1.user_gain=500;
        ylabel(h.Whole_cell1_axes,'mV')
end
% Hints: contents = cellstr(get(hObject,'String')) returns Cell1_type_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Cell1_type_popup


% --- Executes during object creation, after setting all properties.
function Cell1_type_popup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cell2_type_popup.
function Cell2_type_popup_Callback(hObject, eventdata, handles)

global h cell2
val = get(hObject,'Value');
switch val
    case 1
        cell2.user_gain=1;
        ylabel(h.Whole_cell2_axes,'pA')
        cell2.externalcommandsensitivity=20;
    case 2
        cell2.user_gain=20;
        ylabel(h.Whole_cell2_axes,'mV')
        cell2.externalcommandsensitivity=400;
    case 3
        cell2.user_gain=500;
        ylabel(h.Whole_cell2_axes,'mV')
    case 4
        cell2.user_gain=1; % should be 1 but set to 1/1000 to correct for multiplication in acquire function
        ylabel(h.Whole_cell2_axes, 'Volts')
end
% Hints: contents = cellstr(get(hObject,'String')) returns Cell2_type_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Cell2_type_popup


% --- Executes during object creation, after setting all properties.
function Cell2_type_popup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in online_analysis_popup.
function online_analysis_popup_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns online_analysis_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from online_analysis_popup
contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};


% --- Executes during object creation, after setting all properties.
function online_analysis_popup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addcursors_radio.
function addcursors_radio_Callback(hObject, eventdata, handles)
% hObject    handle to addcursors_radio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h ExpStruct
% Hint: get(hObject,'Value') returns toggle state of addcursors_radio
if get(hObject, 'Value') == 1
    if isfield(ExpStruct,'analysis_limits')
        dualcursor([ExpStruct.analysis_limits.cell1(1) ExpStruct.analysis_limits.cell1(3)],[],[],[],h.Whole_cell1_axes);
    else ExpStruct.analysis_limits.cell1
        dualcursor('on',[],[],[],h.Whole_cell1_axes);
    end
else
    dualcursor('off',[],[],[],h.Whole_cell1_axes);
end



% --- Executes on button press in addcursors_radio2.
function addcursors_radio2_Callback(hObject, eventdata, handles)

global h ExpStruct
% Hint: get(hObject,'Value') returns toggle state of addcursors_radio
if get(hObject, 'Value') == 1
    if isfield(ExpStruct,'analysis_limits')
        dualcursor([ExpStruct.analysis_limits.cell2(1) ExpStruct.analysis_limits.cell2(3)],[],[],[],h.Whole_cell2_axes);
    else
        dualcursor('on',[],[],[],h.Whole_cell2_axes);
    end
else
    dualcursor('off',[],[],[],h.Whole_cell2_axes);
end


% --- Executes on button press in get_limits_button.
function get_limits_button_Callback(hObject, eventdata, handles)
global ExpStruct h
if (get(h.addcursors_radio,'Value')==1)
    ExpStruct.analysis_limits.cell1 = dualcursor(h.Whole_cell1_axes);
end
if (get(h.addcursors_radio2,'Value')==1)
    ExpStruct.analysis_limits.cell2 = dualcursor(h.Whole_cell2_axes);
end


% --- Executes on button press in default_save_check.
function default_save_check_Callback(hObject, eventdata, handles)
% hObject    handle to default_save_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of default_save_check


% --- Executes on button press in new_exp_button.
function new_exp_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_exp_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cell1 cell2 LED Ramp ExpStruct Exp_Defaults h sweeps

if ExpStruct.TuningPlot_on == 1
    close(TuningPlot)
end
close(Acq)


% --- Executes on selection change in update_param_popup.
function update_param_popup_Callback(hObject, eventdata, handles)
% hObject    handle to update_param_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns update_param_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from update_param_popup


% --- Executes during object creation, after setting all properties.
function update_param_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to update_param_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tag_Callback(hObject, eventdata, handles)
% hObject    handle to tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct cell1 cell2 LED Ramp Exp_Defaults h sweeps
ExpStruct.tag(ExpStruct.SetSweepNumber)=str2num(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of tag as text
%        str2double(get(hObject,'String')) returns contents of tag as a double


% --- Executes during object creation, after setting all properties.
function tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pause_button.
function pause_button_Callback(hObject, eventdata, handles)
% hObject    handle to pause_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Exp_Defaults h
Trig_value = get(hObject, 'Value');
ExtTrig_value = get(h.ExtTrigger_Button, 'Value');
if (Trig_value == 1)
    Exp_Defaults.ExternalTrigger = 0;
else
    if ExtTrig_value == 1
        Exp_Defaults.ExternalTrigger = 1;
        acquire()
    end
end


% --- Executes on button press in seal_test_open_button.
function seal_test_open_button_Callback(hObject, eventdata, handles)
% hObject    handle to seal_test_open_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


close(seal_test)
setup_seal

% Hint: get(hObject,'Value') returns toggle state of seal_test_open_button

% --- Executes on button press in DIO_on_check.
function DIO_on_check_Callback(hObject, eventdata, handles)
% hObject    handle to DIO_on_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Exp_Defaults h
val = get(h.DIO_on_check, 'Value');
if val == 1
    Exp_Defaults.DIO_on = 1;
else
    Exp_Defaults.DIO_on = 0;
end

function ramp_endtime_Callback(hObject, eventdata, handles)
% hObject    handle to rampend_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Ramp
Ramp.rampend_time=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of rampend_time as text
%        str2double(get(hObject,'String')) returns contents of rampend_time as a double


% --- Executes during object creation, after setting all properties.
function rampend_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rampend_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ramp_number_Callback(hObject, eventdata, handles)
% hObject    handle to ramp_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Ramp
Ramp.ramp_number=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of ramp_number as text
%        str2double(get(hObject,'String')) returns contents of ramp_number as a double


% --- Executes during object creation, after setting all properties.
function ramp_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ramp_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Ramp
set(hObject,'String',num2str(Ramp.ramp_number));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ramp_endtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ramp_endtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Ramp
Ramp.rampend_time=str2double(get(hObject,'String'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ramp_duration_Callback(hObject, eventdata, handles)
% hObject    handle to ramp_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Ramp
Ramp.ramp_duration=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of ramp_duration as text
%        str2double(get(hObject,'String')) returns contents of ramp_duration as a double


% --- Executes during object creation, after setting all properties.
function ramp_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ramp_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global Ramp
set(hObject,'String',num2str(Ramp.ramp_duration));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in axes_hold_check.
function axes_hold_check_Callback(hObject, eventdata, handles)
% hObject    handle to axes_hold_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axes_hold_check


% --- Executes on selection change in LED1.
function LED1_Callback(hObject, eventdata, handles)
% hObject    handle to LED1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns LED1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from LED1
global ExpStruct
ExpStruct.LEDnum = get(handles.LED1,'Value');

% --- Executes during object creation, after setting all properties.
function LED1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadpreviousvalues.
function loadpreviousvalues_Callback(hObject, eventdata, handles)
% hObject    handle to loadpreviousvalues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadpreviousvalues

function genotype_Callback(hObject, eventdata, handles)
% hObject    handle to genotype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Expt_Params.genotype=(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of genotype as text
%        str2double(get(hObject,'String')) returns contents of genotype as a double


% --- Executes during object creation, after setting all properties.
function genotype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genotype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% global ExpStruct
% set(hObject,'String',num2str(ExpStruct.Expt_Params.genotype));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function age_Callback(hObject, eventdata, handles)
% hObject    handle to age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structureglobal ExpStruct
global ExpStruct
ExpStruct.Expt_Params.age=(get(hObject,'String'));

% Hints: get(hObject,'String') returns contents of age as text
%        str2double(get(hObject,'String')) returns contents of age as a double


% --- Executes during object creation, after setting all properties.
function age_CreateFcn(hObject, eventdata, handles)
% hObject    handle to age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function virus_Callback(hObject, eventdata, handles)
% hObject    handle to virus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Expt_Params.virus=(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of virus as text
%        str2double(get(hObject,'String')) returns contents of virus as a double


% --- Executes during object creation, after setting all properties.
function virus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to virus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function slice_Callback(hObject, eventdata, handles)
% hObject    handle to slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Expt_Params.slice=(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of slice as text
%        str2double(get(hObject,'String')) returns contents of slice as a double


% --- Executes during object creation, after setting all properties.
function slice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function internal_Callback(hObject, eventdata, handles)
% hObject    handle to internal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Expt_Params.internal=(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of internal as text
%        str2double(get(hObject,'String')) returns contents of internal as a double


% --- Executes during object creation, after setting all properties.
function internal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to internal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function brainregion_Callback(hObject, eventdata, handles)
% hObject    handle to brainregion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Expt_Params.brainregion=(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of brainregion as text
%        str2double(get(hObject,'String')) returns contents of brainregion as a double


% --- Executes during object creation, after setting all properties.
function brainregion_CreateFcn(hObject, eventdata, handles)
% hObject    handle to brainregion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function exp_type_static_string_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_type_static_string (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end



function notes_Callback(hObject, eventdata, handles)
% hObject    handle to notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Expt_Params.notes=(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of notes as text
%        str2double(get(hObject,'String')) returns contents of notes as a double


% --- Executes during object creation, after setting all properties.
function notes_CreateFcn(hObject, eventdata, handles)
global ExpStruct
% hObject    handle to notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
ExpStruct.Expt_Params.notes=(get(hObject,'String'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ExpTypeEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to ExpTypeEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExpTypeEditBox as text
%        str2double(get(hObject,'String')) returns contents of ExpTypeEditBox as a double
global ExpStruct
ExpStruct.Expt_Params.ExpType=(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function ExpTypeEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExpTypeEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end




% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function save_experiment_Callback(hObject, eventdata, handles)
% hObject    handle to save_experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct  cell1 cell2 LED Ramp Exp_Defaults h s sweeps
button=questdlg('Are you sure?');

if strcmp(button, 'Yes')
    saveAndindexAcq
end

% --------------------------------------------------------------------
function load_experiment_Callback(hObject, eventdata, handles)
% hObject    handle to load_experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct h

[ExpStruct.ExperimentName,ExpStruct.SavePath,nnn] = uigetfile;
ExpStruct.SaveName=strcat(ExpStruct.SavePath,ExpStruct.ExperimentName);
loadname=ExpStruct.SaveName;

load(loadname, 'sweeps', 'Exp_Defaults', 'ExpStruct', 'LED', 'Ramp', 'cell1', 'cell2'); %, 'motor');
% plot
plot(h.Whole_cell1_axes,ExpStruct.timebase,ExpStruct.cell1sweep);
plot(h.Whole_cell1_axes_Ih,cell1.holding_i,'o');
plot(h.Whole_cell1_axes_Rs,cell1.series_r,'o');
plot(h.Whole_cell1_axes_Ir,cell1.input_r,'o');
plot(h.LEDoutput_axes,ExpStruct.timebase, ExpStruct.LEDoutput1);
plot(h.CCoutput_axes,ExpStruct.timebase, ExpStruct.CCoutput1, ExpStruct.timebase, ExpStruct.CCoutput2);

value3 = get(h.record_cell2_check, 'Value');
if (value3 == 1) % if recording two cells
    plot(h.Whole_cell2_axes,ExpStruct.timebase,ExpStruct.cell2sweep);
    plot(h.Whole_cell2_axes_Ih,cell2.holding_i,'o');
    plot(h.Whole_cell2_axes_Rs,cell2.series_r,'o');
    plot(h.Whole_cell2_axes_Ir,cell2.input_r,'o');
end
set(h.current_sweep_number,'String',num2str(ExpStruct.sweep_counter));
ExpStruct.SetSweepNumber = 1;
set(h.SetSweepNumber,'String',num2str(1));
% plot(h.sweep_display_axes, ExpStruct.timebase, sweeps{1});
updateAOaxes;


% --- Executes when selected object is changed in uipanel11.
function uipanel11_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel11
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
global h ExpStruct
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    
    case 'CC_output1'
        ExpStruct.outputchoice=1;
    case 'CC_output2'
        ExpStruct.outputchoice=2;
    case 'LED1'
        ExpStruct.outputchoice=3;
    case 'stimLaserGate'
        ExpStruct.outputchoice = 4;
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
    case 'stimEOM'
        ExpStruct.outputchoice=5;
    case 'trigSI5'
        ExpStruct.outputchoice=6;
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
    case 'airPuffer'
        ExpStruct.outputchoice=7;
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
    case 'nextholoTrigger'
        ExpStruct.outputchoice=8;
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
    case 'nextsequenceTrigger'
        ExpStruct.outputchoice=9;
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
    case 'motorTrigger'
        ExpStruct.outputchoice=10;
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
end
setCurrentRamp


% --- Executes on button press in add_output.
function add_output_Callback(hObject, eventdata, handles)
% hObject    handle to add_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h Exp_Defaults ExpStruct Ramp;

replace=get(h.replaceBox,'Value');
if replace
    clear_outputs;
end

%check digital lines and save as 1
if ExpStruct.isdigit(ExpStruct.outputchoice)
    Ramp.rampstart_voltage=1;
    Ramp.rampend_voltage=1;
end

ExpStruct.CurrentRamp{ExpStruct.outputchoice}=Ramp;

switch ExpStruct.outputchoice;
    case 1  %CC cell 1
        temp=make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, Ramp.rampstart_voltage, Ramp.rampend_voltage, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.CCoutput1 = temp/Exp_Defaults.CCexternalcommandsensitivity+ExpStruct.CCoutput1;
    case 2  %CC cell2
        temp=make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, Ramp.rampstart_voltage, Ramp.rampend_voltage, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.CCoutput2 =temp/Exp_Defaults.CCexternalcommandsensitivity+ExpStruct.CCoutput2;
    case 3  %LED
        temp =make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, Ramp.rampstart_voltage, Ramp.rampend_voltage, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.LEDoutput1 = temp+ExpStruct.LEDoutput1;
    case 4 %stimLaser Gate
        temp=make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, 1, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.StimLaserGate = min(temp + ExpStruct.StimLaserGate,1);
        
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
        
    case 5  %stim Laser EOM
        temp =make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, Ramp.rampstart_voltage, Ramp.rampend_voltage, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.StimLaserEOM = temp+ExpStruct.StimLaserEOM;
        
    case 6  %Trigger SI5
        temp=make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, 1, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.triggerSI5 = min(temp + ExpStruct.triggerSI5,1);
        
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
        
    case 7
        temp=make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, 1, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.triggerPuffer = min(temp + ExpStruct.triggerPuffer,1);
        
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
        
    case 8
        temp=make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, 1, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.nextholoTrigger = min(temp + ExpStruct.nextholoTrigger,1);
        
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
        
    case 9
        temp=make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, 1, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.nextsequenceTrigger = min(temp + ExpStruct.nextsequenceTrigger,1);
        
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
    case 10
        temp=make_ramps(Ramp.rampstart_time, Ramp.ramp_duration, Ramp.ramp_frequency, Ramp.ramp_number, 1, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
        ExpStruct.motorTrigger =  min(temp + ExpStruct.motorTrigger,1);
        
        set(handles.rampstart_voltage,'string','1');
        set(handles.rampend_voltage,'string','1');
        
end
ExpStruct.checkStimpattern = 1;
updateAOaxes;
guidata(hObject,handles);

% --- Executes on button press in clear_output.
function clear_output_Callback(hObject, eventdata, handles)
% hObject    handle to clear_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear_outputs

function clear_outputs

global h Exp_Defaults ExpStruct Ramp

switch ExpStruct.outputchoice;
    case 1
        ExpStruct.CCoutput1(:) = 0;
    case 2
        ExpStruct.CCoutput2(:) =0;
    case 3
        ExpStruct.LEDoutput1(:) = 0;
    case 4
        ExpStruct.StimLaserGate(:) = 0;
    case 5
        ExpStruct.StimLaserEOM(:) = 0;
    case 6
        ExpStruct.triggerSI5(:) = 0;
    case 7
        ExpStruct.triggerPuffer(:) = 0;
    case 8
        ExpStruct.nextholoTrigger(:)=0;
    case 9
        ExpStruct.nextsequenceTrigger(:)=0;
    case 10
        ExpStruct.motorTrigger(:)=0;
        
end

%minimum set to zero ramp possible
replace=get(h.replaceBox,'Value');
if ~replace
    Ramp.ramp_number=0;
    ExpStruct.CurrentRamp{ExpStruct.outputchoice}=Ramp;
    setCurrentRamp
end

ExpStruct.checkStimpattern = 1;
updateAOaxes

% --- Executes on button press in save_output.
function save_output_Callback(hObject, eventdata, handles)
% hObject    handle to save_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h Exp_Defaults ExpStruct Ramp
name = get(h.output_name,'String');
contents = cellstr(get(h.output_list,'String'));
pattern_no=length(contents)+1;
contents{pattern_no}=name;
ExpStruct.output_names = contents;
ExpStruct.output_patterns{pattern_no}(:,1) = ExpStruct.CCoutput1;
ExpStruct.output_patterns{pattern_no}(:,2) = ExpStruct.CCoutput2;
ExpStruct.output_patterns{pattern_no}(:,3) = ExpStruct.LEDoutput1;
ExpStruct.output_patterns{pattern_no}(:,4) = ExpStruct.StimLaserGate;
if isfield(ExpStruct, 'EOMoffset') && ExpStruct.EOMoffset ~= 0;
    ExpStruct.StimLaserEOM(ExpStruct.StimLaserEOM==0) = ExpStruct.EOMoffset;
else
    ExpStruct.output_patterns{pattern_no}(:,5) = ExpStruct.StimLaserEOM;
end

ExpStruct.output_patterns{pattern_no}(:,5) = ExpStruct.StimLaserEOM;
ExpStruct.output_patterns{pattern_no}(:,6) = ExpStruct.triggerSI5;
ExpStruct.output_patterns{pattern_no}(:,7) = ExpStruct.triggerPuffer;
ExpStruct.output_patterns{pattern_no}(:,8) = ExpStruct.nextholoTrigger;
ExpStruct.output_patterns{pattern_no}(:,9) = ExpStruct.nextsequenceTrigger;
ExpStruct.output_patterns{pattern_no}(:,10) = ExpStruct.motorTrigger;

%ExpStruct.output_patterns{pattern_no}(:,4) = ExpStruct.LEDoutput2;
%ExpStruct.output_patterns{pattern_no}(:,5:10) = ExpStruct.Lumencor_output;
%ExpStruct.output_patterns{pattern_no}(:,11:16) = ExpStruct.Lumencor_disp_output;

ExpStruct.checkStimpattern = 1;

ExpStruct.RampList{pattern_no}=ExpStruct.CurrentRamp;

set(h.output_list,'String',ExpStruct.output_names)
set(h.numOutputs,'String',num2str(numel(ExpStruct.output_names)))

% --- Executes on button press in load_output.
function load_output_Callback(hObject, eventdata, handles)
% hObject    handle to load_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h
pattern_no = get(h.output_list,'Value');

load_outputs(pattern_no); %loads outputs of pattern_no
%takes ~125ms



% --- Executes on selection change in output_list.
function output_list_Callback(hObject, eventdata, handles)
% hObject    handle to output_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns output_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from output_list


% --- Executes during object creation, after setting all properties.
function output_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function output_name_Callback(hObject, eventdata, handles)
% hObject    handle to output_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_name as text
%        str2double(get(hObject,'String')) returns contents of output_name as a double


% --- Executes during object creation, after setting all properties.
function output_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function save_configuration_Callback(hObject, eventdata, handles)
% hObject    handle to save_configuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h Exp_Defaults ExpStruct Ramp

[FileName, PathName]=uiputfile;
output_patterns = ExpStruct.output_patterns;
output_names = ExpStruct.output_names;
rampList = ExpStruct.RampList;
save(strcat(PathName,FileName,'.mat'),'output_patterns','output_names','rampList');




% --------------------------------------------------------------------
function load_configuration_Callback(hObject, eventdata, handles)
% hObject    handle to load_configuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h Exp_Defaults ExpStruct Ramp

[configname,configpath,nnn] = uigetfile;
load(strcat(configpath,configname));
ExpStruct.output_patterns=output_patterns;
ExpStruct.output_names=output_names;
if exist('rampList','var')
    ExpStruct.RampList=rampList;
else
    disp('Old version does not have rampList');
end
set(h.output_list,'String',ExpStruct.output_names)

len=length(ExpStruct.stimlog);
for i=1:length(ExpStruct.output_patterns);
    ExpStruct.stimlog{len+i}={ExpStruct.output_patterns{i}};
    ExpStruct.stimName{len+i}={ExpStruct.output_names{i}};
end

ExpStruct.configName=configname;
set(h.ConfigsEditText,'String',ExpStruct.configName);


ExpStruct.Expt_Params.ConfigSettings=configname;
set(h.numOutputs,'String',num2str(numel(ExpStruct.output_names)))




function trial_stim_Callback(hObject, eventdata, handles)
% hObject    handle to trial_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trial_stim as text
%        str2double(get(hObject,'String')) returns contents of trial_stim as a double


% --- Executes during object creation, after setting all properties.
function trial_stim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in programChoice.
function programChoice_Callback(hObject, eventdata, handles)
% hObject    handle to programChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns programChoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from programChoice


% --- Executes during object creation, after setting all properties.
function programChoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to programChoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runProgrambox.
function runProgrambox_Callback(hObject, eventdata, handles)
% hObject    handle to runProgrambox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of runProgrambox



function custom_sequence_Callback(hObject, eventdata, handles)
% hObject    handle to custom_sequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.newCustomString =1;
% Hints: get(hObject,'String') returns contents of custom_sequence as text
%        str2double(get(hObject,'String')) returns contents of custom_sequence as a double


% --- Executes during object creation, after setting all properties.
function custom_sequence_CreateFcn(hObject, eventdata, handles)
% hObject    handle to custom_sequence (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PowerWidget.
function PowerWidget_Callback(hObject, eventdata, handles)
% hObject    handle to PowerWidget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PowerWidget
% global laser_struct laserTimer hlaser
% laser_struct.duration = 100;
% laser_struct.voltage = 0.6;
% laser_struct.Fs = 20000;
%
% hlaser=guihandles(manual_laser_control);
% assignin('base', 'hlaser', hlaser);
% assignin('base', 'laser_struct', laser_struct);


% --- Executes on button press in LC0.
function LC0_Callback(hObject, eventdata, handles)
% hObject    handle to LC0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCcolorChoice(1)=get(hObject,'Value');

% Hint: get(hObject,'Value') returns toggle state of LC0


% --- Executes on button press in LC1.
function LC1_Callback(hObject, eventdata, handles)
% hObject    handle to LC1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCcolorChoice(2)=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of LC1

% --- Executes on button press in LC2.
function LC2_Callback(hObject, eventdata, handles)
% hObject    handle to LC2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCcolorChoice(3)=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of LC2

% --- Executes on button press in LC3.
function LC3_Callback(hObject, eventdata, handles)
% hObject    handle to LC3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCcolorChoice(4)=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of LC3

% --- Executes on button press in LC4.
function LC4_Callback(hObject, eventdata, handles)
% hObject    handle to LC4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCcolorChoice(5)=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of LC4


% --- Executes on button press in LC5.
function LC5_Callback(hObject, eventdata, handles)
% hObject    handle to LC5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCcolorChoice(6)=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of LC5


% --- Executes during object creation, after setting all properties.
function uipanel12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function UVgain_Callback(hObject, eventdata, handles)
% hObject    handle to UVgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCintensity(1)=str2num(get(hObject,'String'));
openLumencor
set_lumencor_intensity(ExpStruct.LCintensity(1),1);
% Hints: get(hObject,'String') returns contents of UVgain as text
%        str2double(get(hObject,'String')) returns contents of UVgain as a double


% --- Executes during object creation, after setting all properties.
function UVgain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UVgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Bluegain_Callback(hObject, eventdata, handles)
% hObject    handle to Bluegain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCintensity(2)=str2num(get(hObject,'String'));
openLumencor
set_lumencor_intensity(ExpStruct.LCintensity(2),2);
% Hints: get(hObject,'String') returns contents of Bluegain as text
%        str2double(get(hObject,'String')) returns contents of Bluegain as a double


% --- Executes during object creation, after setting all properties.
function Bluegain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bluegain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Cyangain_Callback(hObject, eventdata, handles)
% hObject    handle to Cyangain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCintensity(3)=str2num(get(hObject,'String'));
openLumencor
set_lumencor_intensity(ExpStruct.LCintensity(3),3);
% Hints: get(hObject,'String') returns contents of Cyangain as text
%        str2double(get(hObject,'String')) returns contents of Cyangain as a double


% --- Executes during object creation, after setting all properties.
function Cyangain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cyangain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tealgain_Callback(hObject, eventdata, handles)
% hObject    handle to Tealgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCintensity(4)=str2num(get(hObject,'String'));
openLumencor
set_lumencor_intensity(ExpStruct.LCintensity(4),4);
% Hints: get(hObject,'String') returns contents of Tealgain as text
%        str2double(get(hObject,'String')) returns contents of Tealgain as a double


% --- Executes during object creation, after setting all properties.
function Tealgain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tealgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Greengain_Callback(hObject, eventdata, handles)
% hObject    handle to Greengain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCintensity(5)=str2num(get(hObject,'String'));
openLumencor
set_lumencor_intensity(ExpStruct.LCintensity(5),5);
% Hints: get(hObject,'String') returns contents of Greengain as text
%        str2double(get(hObject,'String')) returns contents of Greengain as a double


% --- Executes during object creation, after setting all properties.
function Greengain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Greengain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Redgain_Callback(hObject, eventdata, handles)
% hObject    handle to Redgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.LCintensity(6)=str2num(get(hObject,'String'));
openLumencor
set_lumencor_intensity(ExpStruct.LCintensity(6),6);
% Hints: get(hObject,'String') returns contents of Redgain as text
%        str2double(get(hObject,'String')) returns contents of Redgain as a double


% --- Executes during object creation, after setting all properties.
function Redgain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Redgain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rampnotpulse.
function rampnotpulse_Callback(hObject, eventdata, handles)
% hObject    handle to rampnotpulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(hObject,'Value') == get(hObject,'Max'))
    set(handles.rampend_voltage,'BackgroundColor','white');
else
    set(handles.rampend_voltage,'BackgroundColor',[.5 .5 .5]);
end

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of rampnotpulse


% --- Executes on button press in delete_output.
function delete_output_Callback(hObject, eventdata, handles)
% hObject    handle to delete_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global h Exp_Defaults ExpStruct Ramp
pattern_no = get(h.output_list,'Value');

contents = cellstr(get(h.output_list,'String'));

if numel(contents)>1
    ExpStruct.output_patterns(pattern_no)=[];
    contents(pattern_no)=[];
    ExpStruct.output_names = contents;
    
    ExpStruct.checkStimpattern = 1;
    
    ExpStruct.RampList(pattern_no)=[];
    
    if pattern_no>numel(contents);
        v=numel(contents);
        set(h.output_list,'Value',v)
    end;
    
    set(h.output_list,'String',ExpStruct.output_names)
    set(h.numOutputs,'String',num2str(numel(ExpStruct.output_names)))
    
    updateAOaxes
    guidata(hObject,handles);
else
    errordlg('Cannot delete all outputs, jerk!')
end


% --- Executes on button press in dispCell1.
function dispCell1_Callback(hObject, eventdata, handles)
changesweep
% hObject    handle to dispCell1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispCell1


% --- Executes on button press in dispCell2.
function dispCell2_Callback(hObject, eventdata, handles)
changesweep
% hObject    handle to dispCell2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispCell2



function PMTsEditText_Callback(hObject, eventdata, handles)
% hObject    handle to PMTsEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Expt_Params.PMTs=(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of PMTsEditText as text
%        str2double(get(hObject,'String')) returns contents of PMTsEditText as a double


% --- Executes during object creation, after setting all properties.
function PMTsEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PMTsEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ExpStruct
ExpStruct.Expt_Params.PMTs=(get(hObject,'String'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ConfigsEditText_Callback(hObject, eventdata, handles)
% hObject    handle to ConfigsEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Expt_Params.Configs=(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of ConfigsEditText as text
%        str2double(get(hObject,'String')) returns contents of ConfigsEditText as a double


% --- Executes during object creation, after setting all properties.
function ConfigsEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConfigsEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global ExpStruct
ExpStruct.Expt_Params.Configs=(get(hObject,'String'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function epochControl(~)
global ExpStruct h

Epoch = ExpStruct.Epoch;

%check if first
if Epoch > numel(ExpStruct.EpochText1) || ~ischar(ExpStruct.EpochText1{Epoch})
    ExpStruct.EpochEnterTime{Epoch} = clock;
    ExpStruct.EpochText1{Epoch}='';
    ExpStruct.EpochText2{Epoch}='';
    ExpStruct.EpochEnterSweep{Epoch}=ExpStruct.sweep_counter;
end

set(h.Epoch,'String',num2str(ExpStruct.Epoch));
set(h.epochText, 'String', ExpStruct.EpochText1{ExpStruct.Epoch});
set(h.epochText2, 'String', ExpStruct.EpochText2{ExpStruct.Epoch});
set(h.EpochEnter,'String', num2str(ExpStruct.EpochEnterSweep{Epoch}));


function Epoch_Callback(hObject, eventdata, handles)
% hObject    handle to Epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct

ExpStruct.Epoch = max(str2num(get(hObject,'String')),1);

epochControl

% Hints: get(hObject,'String') returns contents of Epoch as text
%        str2double(get(hObject,'String')) returns contents of Epoch as a double


% --- Executes during object creation, after setting all properties.
function Epoch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epochText_Callback(hObject, eventdata, handles)
% hObject    handle to epochText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.EpochText1{ExpStruct.Epoch}=get(hObject,'String');
% Hints: get(hObject,'String') returns contents of epochText as text
%        str2double(get(hObject,'String')) returns contents of epochText as a double


% --- Executes during object creation, after setting all properties.
function epochText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EpochBackButton.
function EpochBackButton_Callback(hObject, eventdata, handles)
% hObject    handle to EpochBackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Epoch = max(ExpStruct.Epoch-1,1);
epochControl



% --- Executes on button press in EpochNextButton.
function EpochNextButton_Callback(hObject, eventdata, handles)
% hObject    handle to EpochNextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.Epoch = max(ExpStruct.Epoch+1,1);
epochControl

function epochText2_Callback(hObject, eventdata, handles)
% hObject    handle to epochText2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.EpochText2{ExpStruct.Epoch}=get(hObject,'String');
% Hints: get(hObject,'String') returns contents of epochText2 as text
%        str2double(get(hObject,'String')) returns contents of epochText2 as a double


% --- Executes during object creation, after setting all properties.
function epochText2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochText2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EpochEnter_Callback(hObject, eventdata, handles)
% hObject    handle to EpochEnter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.EpochEnterSweep{ExpStruct.Epoch}=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of EpochEnter as text
%        str2double(get(hObject,'String')) returns contents of EpochEnter as a double


% --- Executes during object creation, after setting all properties.
function EpochEnter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EpochEnter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PowerWidget.
function PowerWidget_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PowerWidget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PowerWidget


% --- Executes on button press in replaceBox.
function replaceBox_Callback(hObject, eventdata, handles)
% hObject    handle to replaceBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of replaceBox


% --- Executes on button press in RunDuring.
function RunDuring_Callback(hObject, eventdata, handles)
% hObject    handle to RunDuring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RunDuring



function numOutputs_Callback(hObject, eventdata, handles)
% hObject    handle to numOutputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numOutputs as text
%        str2double(get(hObject,'String')) returns contents of numOutputs as a double


% --- Executes during object creation, after setting all properties.
function numOutputs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numOutputs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ExternalTriggerCB.
function ExternalTriggerCB_Callback(hObject, eventdata, handles)
% hObject    handle to ExternalTriggerCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Exp_Defaults s
% Hint: get(hObject,'Value') returns toggle state of ExtTrigger_toggle
Trig_value = get(hObject, 'Value');
if (Trig_value == 1)
    if s.IsRunning == 0;
        Exp_Defaults.ExternalTrigger = 1;
        if (isempty(s.Connections)) % check if external trigger connection doesn't exists
            s.addTriggerConnection('External','dev1/PFI1','StartTrigger');
            s.ExternalTriggerTimeout=600;
            s.TriggersPerRun = 1000;
        end
    else
        errordlg('cannot change external triggering while DAQ is Running')
        set(hObject,'Value',0);
    end;
else
    if s.IsRunning == 1;
        s.stop;
        pause(2)
        Exp_Defaults.ExternalTrigger = 0;
        s.removeConnection(1);
    else
        
        Exp_Defaults.ExternalTrigger = 0;
        s.removeConnection(1);
    end
end


% Hint: get(hObject,'Value') returns toggle state of ExternalTriggerCB


% --- Executes on button press in DemandHologram.
function DemandHologram_Callback(hObject, eventdata, handles)
% hObject    handle to DemandHologram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

holoNumber = str2double(get(handles.demandHoloET,'String'));
demandHologram(holoNumber);


function demandHoloET_Callback(hObject, eventdata, handles)
% hObject    handle to demandHoloET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of demandHoloET as text
%        str2double(get(hObject,'String')) returns contents of demandHoloET as a double


% --- Executes during object creation, after setting all properties.
function demandHoloET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to demandHoloET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setCurrentRamp(~)
global ExpStruct h Ramp

x = ExpStruct.outputchoice;
thisRamp=ExpStruct.CurrentRamp{x};

set(h.rampstart_voltage,'string',num2str(thisRamp.rampstart_voltage));
set(h.rampend_voltage,'string',num2str(thisRamp.rampend_voltage));
set(h.ramp_frequency,'string',num2str(thisRamp.ramp_frequency));
set(h.rampstart_time,'string',num2str(thisRamp.rampstart_time));
set(h.ramp_duration,'string',num2str(thisRamp.ramp_duration));
set(h.ramp_number,'string',num2str(thisRamp.ramp_number));

Ramp=thisRamp;


% --- Executes on button press in doOne.
function doOne_Callback(hObject, eventdata, handles)
% hObject    handle to doOne (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

waitfornidaq

%Future Ians and other clueless coders this is normally called by the timer function
%in start. I did this rather than acquire because it should be more
%resiliant if a session is already started.


% --- Executes on button press in openLumencor.
function openLumencor_Callback(hObject, eventdata, handles)
% hObject    handle to openLumencor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LumncorWidget



% --- Executes on button press in wattToVolt.
function wattToVolt_Callback(hObject, eventdata, handles)
% hObject    handle to wattToVolt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct h Ramp;
persistent LaserPower XYZ_Points xyPowerInterp TFPowerMap;
locations = FrankenScopeRigFile();
if isempty(LaserPower);
    disp('Currently only supports 20x laser power conversion');
    %load('\\128.32.173.33\Imaging\STIM\Calibration Parameters\20X_Objective_Calibration_LaserPower.mat','LaserPower');
    load(locations.PowerCalib,'LaserPower');
end
wattRequest = str2double(ExpStruct.reqWatts);



if ExpStruct.PowerCorrect
    
    % if we dont have the I variable, load the data and create it
    if  isempty(xyPowerInterp)
        load([locations.CalibrationParams 'xyPowerInterp.mat']);
    end
    
    if  isempty(TFPowerMap)
        load([locations.CalibrationParams 'TFPowerMap.mat']);
    end
    if isempty(XYZ_Points)
        
        load([locations.CalibrationParams '20X_Objective_Zoom_2_XYZ_Calibration_Points.mat']);
    end
    
    
    if  ExpStruct.TF
        ScaleFactor=correctPower(LaserPower,TFPowerMap,XYZ_Points);
        
    else
        ScaleFactor=correctPower(LaserPower,xyPowerInterp,XYZ_Points);
    end
    wattRequest=wattRequest/ScaleFactor;
    
end



if  ExpStruct.TF
    Volt = function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutputTF,wattRequest);
else
    Volt = function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutput,wattRequest);
end

if isnan(Volt)
    disp('Error cannot deliver power');
    Volt=0;
end



Ramp.rampstart_voltage = Volt;
Ramp.rampend_voltage = Volt;

set(h.rampstart_voltage,'string',num2str(Ramp.rampstart_voltage));
set(h.rampend_voltage,'string',num2str(Ramp.rampend_voltage));



function reqWatt_Callback(hObject, eventdata, handles);
% hObject    handle to reqWatt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.reqWatts=(get(hObject,'String'));


% --- Executes during object creation, after setting all properties.
function reqWatt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reqWatt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in replaceVoltage.
function replaceVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to replaceVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
k=ExpStruct.StimLaserEOM;
indx=find(k>0);

newVal=(get(handles.rampstart_voltage,'String'));
newVal=str2num(newVal);
k(indx)=newVal;
ExpStruct.StimLaserEOM = k;
updateAOaxes


% --- Executes on button press in TFcheckBox.
function TFcheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to TFcheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.TF=get(hObject,'Value');

% Hint: get(hObject,'Value') returns toggle state of TFcheckBox


% --- Executes on button press in PwrCorrect.
function PwrCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to PwrCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.PowerCorrect=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of PwrCorrect


% --- Executes on button press in dynamicPowerCorrection.
function dynamicPowerCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to dynamicPowerCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ExpStruct
ExpStruct.dynamicPowerCorrection = get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of dynamicPowerCorrection



function EOMoffsetVal_Callback(hObject, eventdata, handles)
% hObject    handle to EOMoffsetVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EOMoffsetVal as text
%        str2double(get(hObject,'String')) returns contents of EOMoffsetVal as a double
global ExpStruct
ExpStruct.EOMoffset = str2num(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function EOMoffsetVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EOMoffsetVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
