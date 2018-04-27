function acqCountdown
global h ExpStruct ExpDefaults countdown

timeleft = get(countdown,'TasksToExecute')-get(countdown,'TasksExecuted');
set(h.running_text,'String',num2str(timeleft+1),'ForegroundColor','r');