%Analysis functions


function avg_traces(~)
    
global sweeps ExpStruct h
    prompt = {'Enter first sweep:', 'Enter last sweep:'}; %'type:'};
    dlg_title = 'Input sweep bounds';
    num_lines=1;
    def = {'1','10'};
    answer=inputdlg(prompt, dlg_title, num_lines, def);
    first=str2num(answer{1});
    last=str2num(answer{2});
 
        average_trace1=zeros(length(sweeps{first}),1); 
        average_trace2=zeros(length(sweeps{first}),1); 
        for (i=first:last)
            tempsweep=sweeps{i}; 
            tempsweep1=tempsweep(:,1);
            tempsweep2=tempsweep(:,2);
            % zero each trace
            tempsweep1=tempsweep1-mean(tempsweep1(4000:5000));
            tempsweep2=tempsweep2-mean(tempsweep2(4000:5000));
            % update the averag trace
            average_trace1=average_trace1+tempsweep1;
            average_trace2=average_trace2+tempsweep2;
        end
    average_trace1=average_trace1/(last-first);
    average_trace2=average_trace2/(last-first);
    % zero the averaged trace
    baseline1=average_trace1(1:100); baseline1=mean(baseline1);
    average_trace1=average_trace1-baseline1;
    baseline2=average_trace2(1:100); baseline2=mean(baseline2);
    average_trace2=average_trace2-baseline2;
    plot(h.sweep_display_axes,ExpStruct.timebase,[average_trace1 average_trace2]);
  
    
end

    
    
    
    