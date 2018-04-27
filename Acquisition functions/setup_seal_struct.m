function setup_seal_struct ()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
global seal_test_struct 

seal_test_duration = 0.025;
seal_test_amp = -0.2; 
Fs = 20000;
seal_test_struct.Fs = Fs;

seal_testpulse=linspace(0,0,Fs*seal_test_duration);% mutliple by 1000 to convet kHz to Hz
seal_testpulse((Fs*0.005):(Fs*0.02))=seal_test_amp; seal_testpulse=seal_testpulse'; % test pulse goes from 10 to 20 milliseconds for -4 mV (set to -.2V (assuming 20mV/V scaling in the Multipcalmp)
seal_test_struct.seal_testpulse = seal_testpulse;

seal_test_struct.seal_timebase=linspace(0,seal_test_duration,(Fs*seal_test_duration));
end

