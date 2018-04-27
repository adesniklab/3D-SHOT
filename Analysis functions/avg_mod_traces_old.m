function [average_trace] = avg_mod_traces(stimnum, first, last) % cellnum, stimsequence)
%This function takes in the sweeps cell array and produces another cell
%array containing average traces according to the number of stimuli
%  This function will produce average traces for stimulus type across a set
%  of trials. Currenlty it uses cell #1 by default, and the stimulus
%  sequnece is indexed by ExpStruct.motorstim. First and last correspond to
%  the sweep bound for averaging.
% HAA 4/21/13
% 
 global ExpStruct sweeps
   
  cfig = gcf;
 close(cfig);
    average_trace=zeros(length(sweeps{1}),stimnum);
    for (i=first:last)
                tempsweep=sweeps{i}; tempsweep=tempsweep(:,1);
%         zero each trace
        tempsweep=tempsweep-mean(tempsweep(1:100));
%         update the average_trace according to the appropriate stmiuls
%         indexed from ExpStruct.motorstim
%         average_trace(:,ExpStruct.motorstim(i)+1)=average_trace(:,ExpStruct.motorstim(i)+1)+tempsweep;
    average_trace(:,ExpStruct.VisStimSeq(i))=average_trace(:,ExpStruct.VisStimSeq(i))+tempsweep;
    end
    average_trace=average_trace/((last-first)/stimnum);
    % zero the averaged trace
    baseline=average_trace(1:100); baseline=mean(baseline);
    average_trace=average_trace-baseline;
    
    for (i=1:stimnum)
        subplot(1,stimnum,i), plot(ExpStruct.timebase,average_trace(:,i),'r');
        hold on
        xlim([0.5 2.5]); ylim([min(min(average_trace)) max(max(average_trace))]);
    end

end











