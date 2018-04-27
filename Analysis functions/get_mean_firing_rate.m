function [ mean_spike_rate ] = get_mean_firing_rate( firstsweep, lastsweep,leftlimit, rightlimit)
% Computes the mean spike firing rate in a given time window across a set
% of trials. Limits are taken in in seconds. 

global sweeps Exp_Defaults ExpStruct
mean_spike_rate = 0;

% convert limits from seconds to points
leftlimit = leftlimit*Exp_Defaults.Fs; 
rightlimit = rightlimit*Exp_Defaults.Fs; 

% correct for using sweep limits that are out of bounds
if (lastsweep>ExpStruct.sweep_counter)
    lastsweep = ExpStruct.sweep_counter-1;
end

% loop through selected trials extracting spike counts
for i=firstsweep:lastsweep
    thissweep = sweeps{i};
    thissweep=thissweep(:,1);
    subsweep = thissweep(leftlimit:rightlimit); 
    [~, spiketimes] = get_spike_times(subsweep);
    sz = size(spiketimes);
    mean_spike_rate = mean_spike_rate+(sz(2));

end

% average
mean_spike_rate = mean_spike_rate/(lastsweep-firstsweep+1);

% divide by interval to get Hz
mean_spike_rate = mean_spike_rate/(rightlimit/Exp_Defaults.Fs-leftlimit/Exp_Defaults.Fs);
end


