%% Setupdaq
% This script opens the Acq GUI, establishes contact with the NIDAQ board, and calls functions to
% initialize necessary variables


%% Check for existing Acq figure. If an instance of Acq is open, abort
% setupdaq to prevent loss of unsaved data and prompt user to close current
% instance
if exist('h','var')
    if ishandle(h.figure1)
        close(Acq)
        error('Please close current experiment before running setupdaq')
    end
end
%% 

% clear workspace
clear all

% intialize globals
global Exp_Defaults ExpStruct globalTimer s LED Ramp cell1 cell2 h sweeps motor a dmd countdown listener 
useDMD =0;
dmd.useDMD = useDMD;






% create DAQ session
s = daq.createSession('ni');
s.addAnalogInputChannel('Dev2',0:1,'Voltage');
%  s.Channels(1).InputType = 'SingleEndedNonReferenced';
s.Channels(1).InputType = 'SingleEnded'; %swapped 8/10 
%  s.Channels(2).InputType = 'SingleEndedNonReferenced';
s.Channels(2).InputType = 'SingleEnded';

% s.addDigitalChannel('dev1', 'Port0/Line8:15', 'InputOnly');


% Add a listener that will save data into the 'sweeps' variable at the end
% of a sweep using the 'save2sweeps' function
listener = s.addlistener('DataAvailable',@save2sweeps);


% Use this listener instead to update the GUI while a sweep is in progress. To do
% this it is necessary to alter s.NotifyWhenDataAvailableExceeds to a
% length shorter than the sweep length (i.e. the length of the analog
% outputs)
% ExpStruct.fastlistener = s.addlistener('DataAvailable',@fastsave2sweeps);


%Give nidaq a second to initialize before changing defaults for it
pause(1)

% add digital channels
s.addDigitalChannel('Dev2', 'Port0/Line0:5', 'OutputOnly');
s.addDigitalChannel('Dev2', 'Port0/Line8:15', 'InputOnly');

 
%% set necessary defaults- open and edit the 'setup_defaults' fcn to change any of these settings
setup_defaults





% setup experiment timer

globalTimer=timer('TimerFcn', 'waitfornidaq', 'TaskstoExecute', Exp_Defaults.total_sweeps, ...
    'Period',Exp_Defaults.ISI, 'ExecutionMode','fixedRate');
globalTimer.BusyMode='queue';
%globalTimer.BusyMode='drop';

countdown=timer('TimerFcn', 'acqCountdown', 'TaskstoExecute', ceil((Exp_Defaults.ISI-Exp_Defaults.sweepduration)), ...
    'Period',1, 'ExecutionMode','fixedRate','BusyMode','error');


ExpStruct.readyTorun=1;

% store GUI handles in h and dmd for global access

if useDMD
    dmd = guihandles(DMDcontrol9000);
end
h = guihandles(Acq);


%% get the GUI all pretty and ready

% set initial state of save checkbox
set(h.default_save_check, 'Value',Exp_Defaults.ifsave);

% set the close request function
% this call back function executtes on asking to close the GUI and is setup
% to save certain data variables and structures in the workspace
set(Acq,'closerequestfcn',@close_req_fcn);

% label the axes
labelaxes()
updateAOaxes
set(findall(Acq, '-property', 'FontSize'), 'FontSize', 8)

if useDMD
    dmd.cell_disp_no=1;
    dmd.type_disp_no=1;
    %for 5x
    dmd.scalefactor=20/11;
end

% get date in string format and automatically set experiment name
ExpStruct.ExperimentName = autoExptname();
set(h.ExperimentName, 'String', ExpStruct.ExperimentName);
ExpStruct.SaveName=strcat(ExpStruct.SavePath,ExpStruct.ExperimentName);

% load default analog outputs
%load('C:\Users\User\Documents\MATLAB\QuarterCell_IAO\DAQ Configuration Files\whitenoise_default.rpt.mat')
if exist('output_patterns','var');
    ExpStruct.output_patterns=output_patterns;
    ExpStruct.output_names=output_names;
    set(h.output_list,'String',ExpStruct.output_names);
end

%Prepare stimlog with this of possible output patterns and names. 
%will be added to if load configs happens
% ExpStruct.stimlog={ExpStruct.output_patterns{1}};
if length(ExpStruct.output_patterns)>1
    len=length(ExpStruct.stimlog);
    for i=1:length(ExpStruct.output_patterns);
    ExpStruct.stimlog{len+i}={ExpStruct.output_patterns{i}};
    ExpStruct.stimName{len+i}={ExpStruct.output_names{i}};
    end
else 
ExpStruct.stimlog={ExpStruct.output_patterns};
ExpStruct.stimName={ExpStruct.output_names};
end

%set name field with current name
%set(h.ConfigsEditText,'String',ExpStruct.configName);

% get Experiment parameters from previous experiment from same day if not first experiment
load_old_Expt_params; 
updateHoloRequest
getCurrentHolo


%% load DMD dynamic link library
if useDMD
    filename = 'C:\Program Files (x86)\Texas Instruments-DLP\SampleApp64bit\lib\PortabilityLayer.dll';
    headname ='C:\Program Files (x86)\Texas Instruments-DLP\SampleApp64bit\include\PortabilityLayer.h';
    loadlibrary(filename, headname, 'alias', 'DMD');
end
