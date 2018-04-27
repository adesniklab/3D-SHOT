
function analyze_series_r ()
% function [series_r holding_i input_r] = analyze_series_r ()

global ExpStruct Exp_Defaults cell1 cell2

cell1sweep=ExpStruct.cell1sweep; cell2sweep=ExpStruct.cell2sweep;
Fs=Exp_Defaults.Fs; sweep_counter=ExpStruct.sweep_counter;

% find max and min around test pulse which should go from 50-100 ms
Max = max(cell1sweep((Fs*.040):(Fs*.060)));
Min = min(cell1sweep((Fs*.040):(Fs*.060)));
peak_capacitance = Min - Max;
cell1.series_r(sweep_counter)=(-4/peak_capacitance)*1000; % multiply by 1000 to corrent for nA to pA conversion

% analyze series resistance for cell 2
Max = max(cell2sweep((Fs*.040):(Fs*.060)));
Min = min(cell2sweep((Fs*.040):(Fs*.060)));
peak_capacitance = Min - Max;
cell2.series_r(sweep_counter)=(-4/peak_capacitance)*1000;

% analyze holding current for cells 1 & 2
avg1=mean(cell1sweep((Fs*0.03):round(Fs*0.035))); % have to use round to keep second limit as integer
avg2=mean(cell2sweep((Fs*0.03):round(Fs*0.035)));
cell1.holding_i(sweep_counter)=avg1;
cell2.holding_i(sweep_counter)=avg2;

% analyze input resistance for cells 1 & 2
R1=4/(mean(cell1sweep((Fs*.080):(Fs*.095)))-mean(cell1sweep((Fs*.01):(Fs*.02))));
R2=4/(mean(cell2sweep((Fs*.080):(Fs*.095)))-mean(cell2sweep((Fs*.01):(Fs*.02))));
cell1.input_r(sweep_counter)=R1*1000;
cell2.input_r(sweep_counter)=R2*1000;


