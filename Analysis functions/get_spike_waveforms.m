function [ spike_wfs ] = get_spike_waveforms( sweep_no )
%UNTITLED extracts raw data around eacfh detected spike time and displays
% by aligned to peak.
%   Detailed explanation goes here

global Exp_Defaults sweeps
Fs=Exp_Defaults.Fs; 

% get first cell of thissweep
thissweep = sweeps{sweep_no};
thissweep=thissweep(:,1);

% high pass filter the data
filtsweep=highpass_filter(thissweep);

% create spikes array
spike_wfs = {};

% create time vector
tm=linspace(0,1/Fs,61);

% first get spike times
[ height, spiketimes ] = get_spike_times(filtsweep);
size(spiketimes)
% get spike number
spikenum=size(spiketimes); spikenum=spikenum(2);
% extract spike waveforms and put into array 'spikes'
if (spikenum > 1)
 for i=1:spikenum
    this_spike_time = round(spiketimes(i)*Fs);
    spike_wfs{i} = thissweep(this_spike_time-30:this_spike_time+30); 
    spike_wfs{i} = spike_wfs{i}-mean(spike_wfs{i});
    axis = gca;
    hold on;
    plot(axis,tm, spike_wfs{i});
   
 end
   xlabel(axis, 'time (ms)');
    ylabel(axis, 'uV')
    xlim(axis, [0 0.00005]);
else
    error('No spikes in this sweep');
end



