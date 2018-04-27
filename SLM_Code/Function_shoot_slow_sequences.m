function [ ] = Function_shoot_slow_sequences(Setup,sequences)
if Setup.Holodaq.DAQReady==1;
    if numel(sequences) > 1
disp(['You have ' int2str(numel(sequences)) ' sequences, we will pick from the first one']) 
selseq = input('Enter the ID of the sequence you want');
    else
        selseq =1;
    end
    
disp(['You have ' int2str(numel(sequences{selseq})) ' holograms to select'])  


HoloID = 0;
while HoloID<=numel(sequences{selseq})
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
HoloID = counter;

if HoloID<=numel(sequences{selseq})
disp(['Hologram ' int2str(HoloID) ' of ' int2str(numel(sequences{selseq})) ' Selected !'])
[ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequences{selseq}{HoloID} ,0);  
end

end

disp('You are done !')

else
  disp('Your DAQ is not ready to receive next sequence pulse')  
end

end

