function [average_trace, charge] = avg_mod_traces( first, last, type) % cellnum, stimsequence)
% [average_trace] = avg_mod_traces( sweeps, stimnum, first, last, type)
%
% Creates average_traces for each stimulus in sweeps cell array from the
% first to last trial. Type=0 corresponds to visual cortex. Type=1 corresponds to barrel cortex expt.
%This function takes in the sweeps cell array and produces another cell array.
%array containing average traces according to the number of stimuli
%  This function will produce average traces for stimulus type across a set
%  of trials. Currently it uses cell #1 by default, and the stimulus
%  sequence that is indexed by ExpStruct.motorstim or .VisStimSeq. First and last correspond to
%  the sweep bounds for averaging.
% HAA 4/21/13
% 
 global ExpStruct Exp_Defaults sweeps

 
 if type == 0 % if V1 experiment
    stimnum = max(ExpStruct.VisStimSeq);
    leftmeasure = 0.5*Exp_Defaults.Fs;
    rightmeasure = 1.5*Exp_Defaults.Fs;
 else % if barrel cortex experiment
    stimnum = max(ExpStruct.motorstim)+1; % +1 b/c motorstim indexed from 0
    leftmeasure = 1*Exp_Defaults.Fs;
    rightmeasure = 3*Exp_Defaults.Fs;
 end
 
 average_trace = struct;
 average_trace.running=zeros(length(sweeps{1}),stimnum);
 average_trace.notrunning=zeros(length(sweeps{1}),stimnum);
 charge = struct; 
 charge.running = zeros(1,stimnum);
 charge.running_error = zeros(1,stimnum);
 charge.notrunning = zeros(1,stimnum);
 charge.notrunning_error = zeros(1,stimnum);
 charge.runningvalues = cell(1,stimnum);
 charge.notrunningvalues = cell(1,stimnum);
 running_trials = 0; % counter for number of running trials
 no_running_trials = 0;

  for (i=first:last)
        tempsweep=sweeps{i};
        running_trace = tempsweep(:,2);
        tempsweep=tempsweep(:,1);
       
%         zero each trace
        tempsweep = smart_zero(tempsweep);
%         tempsweep=tempsweep-mean(tempsweep(1:10000));
%         tempsweep=tempsweep-mean(tempsweep(4000:20000));
%%       Test if animal was running during stimulus period. Set stimulus
%       period limits manually here for the expt type. 
    if (type == 0) % for visual cortex
        speed = get_running_speed(running_trace, 1, 2);
             if (speed>=1) % running faster then 1 inch per second
                average_trace.running(:,ExpStruct.VisStimSeq(i))=average_trace.running(:,ExpStruct.VisStimSeq(i))+tempsweep;
                % compute and store charge from tempsweep
                tempcharge_vector = charge.runningvalues{ExpStruct.VisStimSeq(i)};
                tempcharge_vector(length(tempcharge_vector)+1) = abs(trapz(tempsweep(leftmeasure:rightmeasure))); 
                charge.runningvalues{ExpStruct.VisStimSeq(i)} = tempcharge_vector;
                % update number of running trials
                running_trials=running_trials+1;
%                 hold on;
%                 set(0,'CurrentFigure', runfig); 
           %     subplot(1,stimnum,ExpStruct.VisStimSeq(i)), plot(ExpStruct.timebase,tempsweep,'Color', [0.75 0.75 0.75]);
            else % not running
                average_trace.notrunning(:,ExpStruct.VisStimSeq(i+1))=average_trace.notrunning(:,ExpStruct.VisStimSeq(i+1))+tempsweep;
              % compute and store charge from tempsweep
                tempcharge_vector = charge.notrunningvalues{ExpStruct.VisStimSeq(i)};
                tempcharge_vector(length(tempcharge_vector)+1) = abs(trapz(tempsweep(leftmeasure:rightmeasure))); 
                charge.notrunningvalues{ExpStruct.VisStimSeq(i)} = tempcharge_vector;
                no_running_trials=no_running_trials+1;
%                 hold on;
%                 set(0,'CurrentFigure', NRfig); 
            %    subplot(1,stimnum,ExpStruct.VisStimSeq(i+1)), plot(ExpStruct.timebase,tempsweep,'Color', [0.75 0.75 0.75]);
            end
                     
    else % type = 1 for barrel cortex
        speed = get_running_speed(running_trace, 1, 2);
            if (speed>1) % running faster then 1 inch per second
               average_trace.running(:,ExpStruct.motorstim(i)+1)=average_trace.running(:,ExpStruct.motorstim(i)+1)+tempsweep;
               % compute and store charge from tempsweep
               tempcharge_vector = charge.runningvalues{ExpStruct.motorstim(i)+1};
               tempcharge_vector(length(tempcharge_vector)+1) = abs(trapz(tempsweep(leftmeasure:rightmeasure))); 
               charge.runningvalues{ExpStruct.motorstim(i)+1} = tempcharge_vector;
               running_trials=running_trials+1;
               hold on;
%                set(0,'CurrentFigure', runfig);
               subplot(1,stimnum,ExpStruct.motorstim(i)+1), plot(ExpStruct.timebase,tempsweep,'Color', [0.75 0.75 0.75]);
            else % not running
               average_trace.notrunning(:,ExpStruct.motorstim(i)+1)=average_trace.notrunning(:,ExpStruct.motorstim(i)+1)+tempsweep;
               % compute and store charge from tempsweep
               tempcharge_vector = charge.notrunningvalues{ExpStruct.motorstim(i)+1};
               tempcharge_vector(length(tempcharge_vector)+1) = abs(trapz(tempsweep(leftmeasure:rightmeasure))); 
               charge.notrunningvalues{ExpStruct.motorstim(i)+1} = tempcharge_vector;
               no_running_trials=no_running_trials+1;
               hold on;
%                set(0,'CurrentFigure', NRfig); 
               subplot(1,stimnum,ExpStruct.motorstim(i)+1), plot(ExpStruct.timebase,tempsweep,'Color', [0.75 0.75 0.75]);
            end    
    end

  end
%%     finish the averages
    average_trace.running = average_trace.running/(running_trials/stimnum);
    average_trace.notrunning = average_trace.notrunning/(no_running_trials/stimnum); 
%     
%     for i=1:stimnum
%         charge.running(i)=mean(charge.runningvalues{i});
%         charge.notrunning(i)=mean(charge.notrunningvalues{i});
%     end
    
   %%  zero the averaged traces and calculate charge
  
    for (i=1:stimnum)
        tempsweep = average_trace.running(:,i);
        tempsweep = smart_zero(tempsweep);
        average_trace.running(:,i)=tempsweep;
        % compute charge for each average trace
        charge.running(:,i)=abs(trapz(tempsweep(ExpStruct.TuningStruct.leftmeasure*Exp_Defaults.Fs:ExpStruct.TuningStruct.rightmeasure*Exp_Defaults.Fs))); 
        charge.running_error(i) = std(charge.runningvalues{i})/sqrt(size(charge.runningvalues{i},1)); 
        
        tempsweep = average_trace.notrunning(:,i);
        tempsweep = tempsweep - mean(tempsweep(1:100));
        average_trace.notrunning(:,i)=tempsweep;
        charge.notrunning(:,i)=abs(trapz(tempsweep(ExpStruct.TuningStruct.leftmeasure*Exp_Defaults.Fs:ExpStruct.TuningStruct.rightmeasure*Exp_Defaults.Fs))); 
    end
end

%   %% plot the traces  
%     for (i=1:stimnum)
%         set(0,'CurrentFigure', runfig); 
%         a=max(isnan(average_trace.running))==1;
%         if max(isnan(average_trace.running))~=1
%             subplot(1,stimnum,i), plot(ExpStruct.timebase,average_trace.running(:,i),'r');
%             hold on
%             if type == 0
%                  xlim([0.2, 2]);
%             else
%                  xlim([0.2 3.5]); 
%             end
%             ylim([min(min(average_trace.running(Exp_Defaults.Fs:end))) max(max(average_trace.running(Exp_Defaults.Fs:end)))]);
%         end
%     end
%         
%     for (i=1:stimnum)
%         set(0,'CurrentFigure', NRfig); 
%         subplot(1,stimnum,i), plot(ExpStruct.timebase,average_trace.notrunning(:,i),'b');
%         hold on
%         if type == 0
%             xlim([0.2, 2]);
%         else
%             xlim([0.2 3.5]); 
%         end
%       %   ylim([min(min(average_trace.notrunning(Exp_Defaults.Fs:end))) max(max(average_trace.notrunning(Exp_Defaults.Fs:end)))]);
% %         ylim([-600, 2500]);
%     end
%         
%          
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
