
function setup_input_output (~)

% create input, output and timebase vectors

global cell1 cell2 LED Ramp ExpStruct Exp_Defaults motor

LEDoutput=ExpStruct.LEDoutput1; sweepduration=Exp_Defaults.sweepduration;


% set initial values for the LED output here

rampstart_voltage=0; % in volts
rampend_voltage=0; % in volts
ramp_duration=0; % in milliseconds
ramp_frequency=0; % in Hz
ramp_number=0;     
rampstart_time=0;  % in milleseconds

ExpStruct.LEDoutput1= make_ramps(rampstart_time, ramp_duration,ramp_frequency,ramp_number,rampstart_voltage,rampend_voltage, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.LEDoutput2= zeros(size(ExpStruct.LEDoutput1));

ExpStruct.timebase=linspace(0,sweepduration,(Exp_Defaults.Fs*sweepduration));

% set initial values for the Lumencor output here




% setup testpulse for votlage clamp
ExpStruct.testpulse = makepulseoutputs(50,1, 50, -0.2, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);

% setup current injection params for cell1
ccpulseamp1=0;
ccpulse_dur1=1000;
ccnumpulses1=1;
ccpulsefreq1=0.1;
ccpulsestarttime1=1000;
deltacurrentpulseamp1=100;
ExpStruct.CCoutput1=makepulseoutputs(ccpulsestarttime1,ccnumpulses1, ccpulse_dur1, ccpulseamp1, ccpulsefreq1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.CCoutput1=ExpStruct.CCoutput1/400; % scale by externalcommand sensitivity under Current clamp

% setup current injection params for cell2
ccpulseamp2=0;
ccpulse_dur2=1000;
ccnumpulses2=1;
ccpulsefreq2=0.1;
ccpulsestarttime2=1000;
deltacurrentpulseamp2=100;
ExpStruct.CCoutput2=makepulseoutputs(ccpulsestarttime2,ccnumpulses2, ccpulse_dur2, ccpulseamp2, ccpulsefreq2, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
ExpStruct.CCoutput2=ExpStruct.CCoutput2/400; % scale by externalcommand sensitivity under Current clamp
%ExpStruct.piezooutput=makecosineoutputs(ccpulsestarttime1,ccnumpulses1, ccpulse_dur1, ccpulseamp1, ccpulsefreq1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);

% delta param
ExpStruct.deltaparam=0.5;

% user gains
user_gain1 = 2;%1; % set gains according to Multiclamp. 1V/nA default setting for voltage clamp
user_gain2 = 2;%1;

highpass_freq1=500;
highpass_freq2=500;

series_r1=[];
holding_i1=[];
input_r1=[];
spikerate1=[];

series_r2=[];
holding_i2=[];
input_r2=[];

ExpStruct.outputchoice=1;
ExpStruct.output_names = {'All off'};
ExpStruct.output_patterns{1}(:,1) = ExpStruct.CCoutput1;
ExpStruct.output_patterns{1}(:,2) = ExpStruct.CCoutput2;
ExpStruct.output_patterns{1}(:,3) = ExpStruct.LEDoutput1;
ExpStruct.output_patterns{1}(:,4) = ExpStruct.StimLaserGate;
ExpStruct.output_patterns{1}(:,5) = ExpStruct.StimLaserEOM;
ExpStruct.output_patterns{1}(:,6) = ExpStruct.triggerSI5;
ExpStruct.output_patterns{1}(:,7) = ExpStruct.triggerPuffer;
ExpStruct.output_patterns{1}(:,8) = ExpStruct.nextholoTrigger;
ExpStruct.output_patterns{1}(:,9) = ExpStruct.nextsequenceTrigger;
ExpStruct.output_patterns{1}(:,10) = ExpStruct.motorTrigger;










cell1 = struct('series_r', series_r1, 'holding_i', holding_i1, 'input_r', input_r1, 'pulseamp', ...
    ccpulseamp1, 'pulseduration', ccpulse_dur1, 'pulsenumber', ccnumpulses1, 'pulsefrequency', ccpulsefreq1, ...
    'pulse_starttime', ccpulsestarttime1, 'deltacurrentpulseamp', deltacurrentpulseamp1, 'user_gain', user_gain1, ...
    'highpass_freq', highpass_freq1, 'spikerate1', spikerate1);

cell2 = struct('series_r', series_r2, 'holding_i', holding_i2, 'input_r', input_r2, 'pulseamp', ...
    ccpulseamp2, 'pulseduration', ccpulse_dur2, 'pulsenumber', ccnumpulses2, 'pulsefrequency', ccpulsefreq2, ...
    'pulse_starttime', ccpulsestarttime2, 'deltacurrentpulseamp', deltacurrentpulseamp2,'user_gain', user_gain2, ...
    'highpass_freq', highpass_freq2);

Ramp = struct('rampend_voltage', rampend_voltage, 'rampstart_time', rampstart_time, 'rampstart_voltage', rampstart_voltage, ...
                'ramp_duration', ramp_duration, 'ramp_frequency', ramp_frequency, 'ramp_number', ramp_number);

