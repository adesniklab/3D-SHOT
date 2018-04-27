function [ ] = Function_shoot_One_sequences(Setup,sequences)
if 1==1;
disp(['You have ' num2str(Setup.TimeToPickSequence) ' seconds to select which sequence to use, send too many pulses to quit'])
disp(['You have ' int2str(numel(sequences)) ' sequences to choose from'])  
    
%sequenceID = 0;
%while sequenceID<=numel(sequences)
%disp('Anytime now !')
%state = 0;
%counter = 0;
%while state == 0;state = inputSingleScan(Setup.DAQ);end;
%while state == 1;state = inputSingleScan(Setup.DAQ);end;
%tic; t = toc;
%while t<Setup.TimeToPickSequence
%while state == 0&&t<Setup.TimeToPickSequence;state = inputSingleScan(Setup.DAQ);t=toc;end;
%while state == 1&&t<Setup.TimeToPickSequence;state = inputSingleScan(Setup.DAQ);t=toc;end;
%counter = counter+1;
%t=toc;
%end
%sequenceID = counter;
%
%if sequenceID<=numel(sequences)
%disp(['Sequence ' int2str(sequenceID) ' of ' int2str(numel(sequences)) ' Selected !'])

sequenceID = 1;
input('Enter when you are ready to run the sequence (SLM timeout) !!!')

function_Triggered_Sequence( Setup, sequences{sequenceID} ,1 );

sequenceID = 1000000 ; %Force exist after one


disp('You are done !')

else
  disp('Your DAQ is not ready to receive next sequence pulse')  
end

end

