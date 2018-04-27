function [ ] = Function_shoot_looped_sequences(Setup,sequences)
if Setup.Holodaq.DAQReady==1;
disp(['You have ' num2str(Setup.TimeToPickSequence) ' seconds to select which sequence to use, send too many pulses to quit'])
disp(['You have ' int2str(numel(sequences)) ' sequences to choose from'])  
    
sequenceID = 0;
while sequenceID<=numel(sequences)
disp('Anytime now !')
state = 0;
counter = 0;
while state == 0;state = inputSingleScan(Setup.DAQ);end;
while state == 1;state = inputSingleScan(Setup.DAQ);end;
tic; t = toc;
while t<Setup.TimeToPickSequence
while state == 0&&t<Setup.TimeToPickSequence;state = inputSingleScan(Setup.DAQ);t=toc;end;
while state == 1&&t<Setup.TimeToPickSequence;state = inputSingleScan(Setup.DAQ);t=toc;end;
counter = counter+1;
t=toc;
end
sequenceID = counter

if sequenceID<=numel(sequences)
disp(['Sequence ' int2str(sequenceID) ' of ' int2str(numel(sequences)) ' Selected !'])
function_Triggered_Sequence_loop( Setup, sequences{sequenceID});
end

end

disp('You are done !')

else
  disp('Your DAQ is not ready to receive next sequence pulse')  
end

end

