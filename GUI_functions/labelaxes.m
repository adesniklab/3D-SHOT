
function labelaxes(~)
global h ExpStruct Exp_Defaults

get(h.Cell1_type_popup,'Value');
if (get(h.Cell1_type_popup,'Value'))==1
    ylabel(h.Whole_cell1_axes,'pA')
else
    ylabel(h.Whole_cell1_axes,'mV')
end

if (get(h.Cell2_type_popup,'Value'))==1
%     ylabel(h.Whole_cell2_axes,'pA')
else
    ylabel(h.Whole_cell2_axes,'mV')
end
xlabel(h.Whole_cell1_axes,'seconds')
xlabel(h.Whole_cell2_axes,'seconds')
val = get(h.Highpass_check, 'Value'); % check for highpass filtering
if (val == 1)
    ylabel(h.Whole_cell1_axes_Rs,'spikerate')
else
    ylabel(h.Whole_cell1_axes_Rs,'megaohm')
end
ylabel(h.Whole_cell1_axes_Ih,'Ihold')
ylabel(h.Whole_cell1_axes_Ir,'Ri')
xlabel(h.Whole_cell1_axes_Ir, 'minutes')
xlabel(h.Whole_cell2_axes_Ir, 'minutes')
xlabel(h.LEDoutput_axes, 'seconds')
ylabel(h.LEDoutput_axes, 'Volts')
xlabel(h.analysis1_axes, 'minutes')
% compute total experiment time
TotalExpTime = max(ExpStruct.trialtime)+0.001;

xlim(h.Whole_cell1_axes_Rs,[0 TotalExpTime*1.33])
xlim(h.Whole_cell1_axes_Ih,[0 TotalExpTime*1.33])
xlim(h.Whole_cell1_axes_Ir,[0 TotalExpTime*1.33])
xlim(h.Whole_cell2_axes_Ih,[0 TotalExpTime*1.33])
xlim(h.Whole_cell2_axes_Ir,[0 TotalExpTime*1.33])
xlim(h.Whole_cell2_axes_Rs,[0 TotalExpTime*1.33])
xlim(h.analysis1_axes,[0 TotalExpTime*1.33])

ylim(h.Whole_cell1_axes_Rs,[0 25])
% ylim(h.Whole_cell1_axes_Ih,[-1000 500])
ylim(h.Whole_cell1_axes_Ir,[-300 0])
ylim(h.Whole_cell2_axes_Rs,[0 25])
% ylim(h.Whole_cell2_axes_Ih,[-1000 500])
ylim(h.Whole_cell2_axes_Ir,[-300 0])

% % label axes on barrelmapping GUI
% value5 =  get(h.AcquireBarrels_button, 'Value');
% if (value5 == 1)
%     for (i=1:5) 
%         thisaxis = strcat('axes',num2str(i));
%         thisaxishandle = getfield(ExpStruct.MapH,thisaxis); 
%         xlabel(thisaxishandle, 'seconds');
%         ylabel(thisaxishandle, 'pA');
%     end
% end

