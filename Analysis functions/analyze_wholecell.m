function [ output ] = analyze_wholecell( cellnum )
% Computes requested value from most recently acquired sweep
%   Detailed explanation goes here
global h ExpStruct Exp_Defaults cell1 cell2 
Fs=Exp_Defaults.Fs;
% get type of analysis to do
contents = cellstr(get(h.online_analysis_popup,'String'));
type = contents{get(h.online_analysis_popup,'Value')};


% get position of cursors on main axes
if isfield(ExpStruct,'analysis_limits')
 if (cellnum==1)
   val=ExpStruct.analysis_limits.cell1;
   thissweep=ExpStruct.cell1sweep;
 else
    val=ExpStruct.analysis_limits.cell2;
    thissweep=ExpStruct.cell2sweep;
 end



% zero the trace
 thissweep = thissweep-mean(thissweep(1:100));

 switch type

    case 'amplitude (pos)'
        output=max(thissweep(round(val(1)*Fs):round(val(3)*Fs)));
    case 'amplitude (neg)'
        output=min(thissweep(round(val(1)*Fs):round(val(3)*Fs)));
    case 'slope'
        output=(val(4)-val(2))/(val(3)-val(1));
    case 'charge'
        output=trapz(thissweep(round(val(1)*Fs):round(val(3)*Fs)));
    case 'spike rate' 
        [ height, spiketimes ] = get_spike_times(thissweep(round(val(1)*Fs):round(val(3)*Fs)));
        a = size(spiketimes);
        output=a(2);
 end     

else
    errordlg('Please set limits');
end

end

