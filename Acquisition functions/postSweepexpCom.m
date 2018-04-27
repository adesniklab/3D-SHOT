function postSweepexpCom(~)

global cell1 cell2 LED Ramp ExpStruct Exp_Defaults h s sweeps a


if get(h.runProgrambox,'Value') == 1
%     if isfield(ExpStruct,'postSweepprogramChoice')
%         string = ExpStruct.postSweepprogramChoice;
%         eval(string);
%     end
    string = get(h.programChoice,'String');
    eval(string{get(h.programChoice,'Value')});
    ExpStruct.expcom=get(h.programChoice,'Value');
    
    input = get(h.custom_sequence,'String');
    ExpStruct.programInput = input;
    ExpStruct.programRunAfter{ExpStruct.sweep_counter}=1;
else
    ExpStruct.programRunAfter{ExpStruct.sweep_counter}=0;
end