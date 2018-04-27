function [output] = make_ramps (rampstart_time, ramp_duration, ramp_frequency, ramp_number, rampstart_voltage, rampend_voltage, Fs, sweepduration)

timebase=linspace(0,sweepduration,(Fs*sweepduration));
output=linspace(0,0,Fs*sweepduration); 
starttime = (rampstart_time*Fs/1000); % convert from milliseconds to points


    starttime = (rampstart_time*Fs/1000); % convert from milliseconds to points

    intercept=0;
    % if else added for use with ramp and hold to correct for errant single
    % point value for roll off ramp
 for i=1:ramp_number
  %  if 
     
%         (rampstart_voltage<rampend_voltage);
        output(round(rampstart_time*Fs/1000):round(rampstart_time*Fs/1000+ramp_duration*Fs/1000)-1) = linspace(rampstart_voltage,...
        rampend_voltage,Fs/1000*ramp_duration);
%     else
%         output((rampstart_time*Fs/1000+1):(rampend_time*(Fs/1000))) = linspace(rampstart_voltage,...
%         rampend_voltage,Fs/1000*(rampend_time-rampstart_time))+intercept;
%     end
 rampstart_time=rampstart_time+(1/ramp_frequency*1000);
 end
    output=output';


end