function [ height, spiketimes ] = get_spike_times( thissweep )
% Extracts spikes times for a given sweep.
% Threshold is given in absolute pA or mV. The defaults 
%   Detailed explanation goes here

% call globals for getting sampling rate
global Exp_Defaults 

% extract appropriate sweep

thissweep=thissweep(:,1);

% high pass filter the data
thissweep=highpass_filter(thissweep);

% get absoulte value of threshold since sweep will be inverted
threshold = 6*std(thissweep);

% invert sweep 
thissweep=thissweep*-1;

% core line for extracting spike times
% set minimum time distance between found spike times to avoid multiple
% points per any given spike (default is 0.003 s)
if (~isempty(find(thissweep>threshold)));
[y,spiketimes]=findpeaks(thissweep, 'minpeakheight',threshold,'minpeakdistance',(Exp_Defaults.Fs)*0.003);
spiketimes = spiketimes';
spiketimes = spiketimes/Exp_Defaults.Fs;
height=ones(size(spiketimes)); 
height=max(y);
else
    spiketimes = 0;
    height = 0;
end

end

