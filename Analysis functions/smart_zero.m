function [ zeroed_trace ] = smart_zero( trace )
% Finds period of least variance in the baseline of a trace and uses that
% period to subtract off the mean

global Exp_Defaults

% convert limits in seconds into limits in samples
% leftlimit = leftlimit*Exp_Defaults.Fs;
% rightlimit = rightlimit*Exp_Deafults.Fs;

% extract baseline portion to average, usually half to one second
baseline = trace(0.15*Exp_Defaults.Fs:Exp_Defaults.Fs); 

% break baseline into 20 50-ms segments and analyze the variance

var_vector = zeros(1,15);

for i=1:15
    temp = baseline((i*(Exp_Defaults.Fs/20):((i+1)*(Exp_Defaults.Fs/20)-1)));
    var_vector(i) = var(temp); 
end
% find which segment has the lowest variance
min_var_segment = find(var_vector==min(var_vector));

% compute the mean value of the least variable segment
newbaseline = baseline(round((min_var_segment*0.05*Exp_Defaults.Fs)):round((min_var_segment+1)*0.05*Exp_Defaults.Fs));
DCoffset = mean(newbaseline);
zeroed_trace = trace-DCoffset;  

end

