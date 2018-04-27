function [output] = makepulseoutputs(start_time, pulsenumber, pulseduration, pulseamp ,pulsefrequency, Fs, sweepduration)
% Generates the analog output waveform for the LED or other analog device

%create the LED output wave
% make LEDoutput vector so that is has the right number of sampling points 
% which must be the same as test pulse
% note that the number of points in the analog outputs vectors actaully
% determines the number of points in the analog input vectors

timebase=linspace(0,sweepduration,(Fs*sweepduration));
output=linspace(0,0,Fs*sweepduration); 
starttime = (start_time*Fs/1000); % convert from milliseconds to points

for (i=1:pulsenumber)
    output(starttime+1:round((starttime+(pulseduration*Fs/1000))))=pulseamp;
    starttime=round(starttime+((1/pulsefrequency)*Fs));
end 
output=output(1:(Fs*sweepduration)); % in case vector is too long, resize
output((Fs*sweepduration-10):(Fs*sweepduration))=0; % always set last 10 points to 0 to prevent LED from staying on
output=output';
    
end

