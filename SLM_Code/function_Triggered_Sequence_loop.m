function [  ] = function_Triggered_Sequence_loop( Setup, sequence )

%This function takes as argument sequnece, and will attemp to repeat it up
%to n times then quit. 
%If time out occurs, the sequence is aborted and the next sequence is put
%in place


LN = numel(sequence);
sequencetest = 0;
for i = 1:LN
    if isequal(size(sequence{i}), [Setup.SLM.Nx Setup.SLM.Ny]) ==0 ; sequencetest = 1;end
    if isequal(sequence{i}, uint8(sequence{i})) ==0 ; sequencetest = 1;end    
end

if sequencetest ==0

disp(['This Sequence Contains ' int2str(LN ) ' holograms, SLM Loaded !'])
counter = 1;
timelimit = (Setup.SLM.timeout_ms/1000)-0.2;
abug = 0;
t=0;
while t<timelimit    
tic;
[ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequence{mod(counter,LN)+1} ,1);  
t = toc;
counter = counter+1  ;    
end

disp(['Sequence ended while waiting to display hologram ' int2str(counter-1)])


else
disp('Your sequence has the wrong format, fix it !')    
end


end

