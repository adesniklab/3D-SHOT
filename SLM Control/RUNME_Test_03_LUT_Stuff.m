try
     [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
end

clear all;
close all;
clc;



%Make sure to adjust parameters to use the linear look up table in this
%case 

%  NiDaq=daq.createSession('ni');
%    DeviceName = 'Dev2';
%   ch = NiDaq.addAnalogInputChannel(DeviceName, 0, 'Voltage');                 %SATSUMA GAIN, first channel
%    NiDaq.Rate = 1000;

%    NiDaq.DurationInSeconds = 0.2;

    
[Setup ] = function_loadparameters();
%  Setup.SLM.lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\linear.lut'
% Setup.SLM.lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\slm4610_FromNico_PCIe.lut';%2/20/18 Lut File
%Setup.SLM.lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\slm4610_at1064_PCIe.lut';%'old' LUT file

Setup.SLM.lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\slm4610_DataFromNico_Ref0.lut';%2/26/18


% Arrays for image data
[XX,YY] = ndgrid(1:Setup.SLM.Nx,1:Setup.SLM.Ny);
XX = mod(XX,16);
XX = double(XX<=7);
 [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
%f = figure(1);
values = zeros(3,256);
for i = 1:256
    mask = (i-1)*XX;
    values(1,i) = max(mask(:));
    values(2,i) = min(mask(:));
    [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, uint8(mask) );
    
    %[data,time] = NiDaq.startForeground;
    %value = mean(data);
    disp(['Pixelvalue: ' int2str(i-1) '->  Enter power in watts ->']);pause(0.5)
    %scatter(i,value) ; hold on
    
%     value = input(['Pixelvalue: ' int2str(i-1) '->  Enter power in watts ->']);
%     try
%         values(3,i) =value;
%     catch 
%         value = input(['ERROR, Try again: Pixelvalue: ' int2str(i-1) '->  Enter power in watts ->']);
%         values(3,i) =value;
%     end
end

%  save('Values06.mat','values')

 [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );