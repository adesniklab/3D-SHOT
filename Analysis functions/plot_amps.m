function plot_amps(~)
global ExpStruct Exp_Defaults sweeps h 

    prompt = {'Enter left limit in ms:', 'Enter right limit in ms:'};
    dlg_title = 'Input limits';
    num_lines=1;
    def = {'1','10'};
    answer=inputdlg(prompt, dlg_title, num_lines, def);
    left=str2num(answer{1});
    left=left*Exp_Defaults.Fs; % convert entered ms into points
    right=str2num(answer{2});
    right=right*Exp_Defaults.Fs; % convert entered ms into points
       
       
    for (i=1:ExpStruct.sweep_counter)
        temp=sweeps{1};
        temp1=temp(:,1);
        temp1=temp1(left:right);
        temp2=temp(:,2);
        temp2=temp2(left:right);
        
        amps1(i)=min(temp1);
        amps2(i)=min(temp2); 
    end

    plot(h.sweep_display_axes,amps1, amps2,'+')
end

