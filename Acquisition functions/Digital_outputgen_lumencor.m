function [ Lumencor_output ] = Digital_outputgen( color, starttime, pulsenumber, duration, pulsefrequency )
% Generate a digital output vector for 6 digital output lines; a 6 x sample
% points vector
%   Color can take six values for the six LEDs in the Spectra: 
% UV    = 1
% blue  = 2
% cyan  = 3
% green = 4
% yellow= 5
% red   = 6

% call globals
global Exp_Defaults ExpStruct LED h


% generate 6 column vector of ones by sample length for each LED. Use ones
% because 1 is off and 0 is on
% sample rate is Exp_Defaults.Fs
% sweep duration is Exp_Defaults.sweepduration
% output vector parameters are store in LED struct
% 'h' struct holds handles to GUI
% Lumencor_output = ones(Exp_Defaults.Fs*Exp_Defaults.sweepduration,6);

% generate digital output vector
line1=makepulseoutputs(starttime, pulsenumber, duration, -1 ,pulsefrequency, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
line1=line1+1;
Lumencor_output(:,color)=line1;




%% add these lines to give a multi-LED stimulus using both colors on either side of chosen color
if isfield(h,'MultiLED_check')
val = get(h.MultiLED_check, 'value');
  if val == 1
    if color ~= 1
        Lumencor_output(:,color-1)=line1;
    end
    if color ~= 6
        Lumencor_output(:,color+1)=line1;
    end
  end
end

% if isfield(h,'MultiLED_check')
% val = get(h.MultiLED_check, 'value');
% if val == 1
%     Lumencor_output(:,1) = line2;
% else
%     Lumencor_output(:,4) = line2;
% end

end

