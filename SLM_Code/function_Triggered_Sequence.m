function [  ] = function_Triggered_Sequence( Setup, sequence, n  )

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
    
    if n == 1
        disp(['This Sequence Contains ' int2str(numel(sequence)) ' holograms, SLM Loaded !'])
        counter = 1;
        abug = 0;
        while counter <= numel(sequence) && abug==0
            tic;
            [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequence{counter} );
            t = toc;
            if t> (Setup.SLM.timeout_ms/1000)-0.2; abug =1; end;
            counter = counter+1  ;
        end
        if abug==1
            disp(['Sequence ended while waiting to display hologram ' int2str(counter-1)])
        else
            disp('Sequence successfully completed until the end')
        end
        
    else
        disp(['LOADED !  ' int2str(n) ' sequences of ' int2str(numel(sequence)) ' holograms'])
        bigcounter = 1;
        while bigcounter<=n
            counter = 1;
            abug = 0;
            while counter <= numel(sequence) && abug==0
                tic
                [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequence{counter} );
                t = toc; if t> (Setup.SLM.timeout_ms/1000)-0.2; abug =1;end;
                counter = counter+1;
            end
            
            if abug==1
                disp(['Time out ! Sequence ' int2str(bigcounter) ', aborted while waiting for hologram ' int2str(counter-1)'  ])
            else
                disp('Sequence successfully completed !')
            end
            bigcounter  = bigcounter+1;
        end
        disp('Sequences completed, see errors above if any.')
        
    end
    
else
    disp('Your sequence has the wrong format, fix it !')
end


end

