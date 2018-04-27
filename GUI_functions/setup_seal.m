
clear seal_test_struct hseal sealTimer

global seal_test_struct sealTimer hseal sClk s

setup_seal_struct


sealTimer=timer('TimerFcn', 'seal_acquire', 'TaskstoExecute', 500, 'Period',.03, 'ExecutionMode','fixedRate', 'BusyMode', 'drop');

hseal = guihandles(seal_test);
assignin('base', 'hseal', hseal);
