function [ filtered_sweep ] = highpass_filter( inputsweep )
% This function implements a forwards and backwards butterwoth filter
% following UltraMegaSort2000 (Kleinfeld lab)
global Exp_Defaults
Fs = Exp_Defaults.Fs;

Wp = [ 700 8000] * 2 / Fs; % pass band for filtering
Ws = [ 500 9000] * 2 / Fs; % transition zone
[N,Wn] = buttord( Wp, Ws, 3, 20); % determine filter parameters
[B,A] = butter(N,Wn); % builds filter
filtered_sweep = filtfilt( B, A, inputsweep ); % runs filter


end

