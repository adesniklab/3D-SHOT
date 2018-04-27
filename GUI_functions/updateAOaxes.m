

global h ExpStruct Exp_Defaults
cla(h.LEDoutput_axes);

if ishold(h.LEDoutput_axes) == 0;
    hold(h.LEDoutput_axes);
end


% if length(ExpStruct.timebase) ~= length(ExpStruct.LEDoutput2);
%     ExpStruct.LEDoutput2 = zeros(length(ExpStruct.timebase),1);
% end
try
plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.LEDoutput1,'LineWidth',1,'Color','k');
plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.StimLaserGate,'LineWidth',1,'Color','b');
plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.StimLaserEOM,'LineWidth',1,'Color','r');
plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.triggerSI5,'LineWidth',1,'Color','m');
plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.triggerPuffer,'LineWidth',1,'Color',[.7 .4 0]);
plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.nextholoTrigger,'LineWidth',1,'Color',[0 .8 0]);
plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.nextsequenceTrigger,'LineWidth',1,'Color','c');
plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.motorTrigger,'LineWidth',1,'Color','y');
catch
    errordlg('sweep lengths are too short! <updateAOaxes>')
end


% plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.Lumencor_disp_output(:,1),'Color',[1 0 1]);
% plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.Lumencor_disp_output(:,2),'Color',[0 0 1]);
% plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.Lumencor_disp_output(:,3),'Color',[0 0.5 1]);
% plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.Lumencor_disp_output(:,4),'Color',[0 1 0.5]);
% plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.Lumencor_disp_output(:,5),'Color',[0 1 0]);
% plot(h.LEDoutput_axes,ExpStruct.timebase,ExpStruct.Lumencor_disp_output(:,6),'Color',[1 0 0]);
% 
%,ExpStruct.timebase, ExpStruct.piezooutput);
% axis(h.LEDoutput_axes, [0 Exp_Defaults.sweepduration -6  6])
% axis(h.LEDoutput_axes, [0 Exp_Defaults.sweepduration -1  max(ExpStruct.LEDoutput)])
xlabel(h.LEDoutput_axes, 'seconds');
ylabel(h.LEDoutput_axes, 'V');

currentCCoutput1=ExpStruct.CCoutput1*Exp_Defaults.CCexternalcommandsensitivity;
if isempty(ExpStruct.CCoutput2)~=1;
    currentCCoutput2=ExpStruct.CCoutput2*Exp_Defaults.CCexternalcommandsensitivity; % reverse scale just for plotting
    plot(h.CCoutput_axes,ExpStruct.timebase,currentCCoutput1,ExpStruct.timebase,currentCCoutput2);
elseif isempty(ExpStruct.CCoutput1)~=1;
    plot(h.CCoutput_axes,ExpStruct.timebase,currentCCoutput1);
    
end

    
if max(currentCCoutput1)>600;
    axis(h.CCoutput_axes, [0 Exp_Defaults.sweepduration -200 1.1*max(currentCCoutput1)]);
else
    axis(h.CCoutput_axes, [0 Exp_Defaults.sweepduration -200 700]);
end
xlabel(h.CCoutput_axes, 'seconds');
ylabel(h.CCoutput_axes, 'pA');
% axis(h.CCoutput_axes, [0 Exp_Defaults.sweepduration -6  6])
ExpStruct.testpulse = makepulseoutputs(50,1, 50, -0.2, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);

    