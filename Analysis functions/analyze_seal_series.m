
function [access_R1, access_R2, seal_R1, seal_R2] = analyze_seal_series(cell1sweep, cell2sweep, Fs)

% analyze series resistance for cell 1
Max = max(cell1sweep((Fs*0.004):(Fs*0.01)));
Min = min(cell1sweep((Fs*0.004):(Fs*0.01)));
peak_capacitance = Min - Max;
access_R1=-4/peak_capacitance;
% access_R1=round(access_R1);

% analyze series resistance for cell 2
Max = max(cell2sweep((Fs*0.004):(Fs*0.01)));
Min = min(cell2sweep((Fs*0.004):(Fs*0.01)));
peak_capacitance = Min - Max;   
access_R2=-4/peak_capacitance;
% access_R2=round(access_R2);

% analyze input resistance for cells 1 & 2

R1=-4/(mean(cell1sweep((Fs*0.012):(Fs*0.018)))-mean(cell1sweep((Fs*0.001):(Fs*0.004))));
R2=-4/(mean(cell2sweep((Fs*0.012):(Fs*0.018)))-mean(cell2sweep((Fs*0.001):(Fs*0.004))));

seal_R1=round(R1); 
seal_R2=round(R2);

end


