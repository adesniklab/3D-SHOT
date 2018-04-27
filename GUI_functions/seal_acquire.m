

function seal_acquire()

global hseal seal_test_struct  s


s.queueOutputData([ones(size(seal_test_struct.seal_testpulse)) ones(size(seal_test_struct.seal_testpulse)) ones(size(seal_test_struct.seal_testpulse)),...
    ones(size(seal_test_struct.seal_testpulse)) ones(size(seal_test_struct.seal_testpulse)) ones(size(seal_test_struct.seal_testpulse)),...
    seal_test_struct.seal_testpulse seal_test_struct.seal_testpulse seal_test_struct.seal_testpulse seal_test_struct.seal_testpulse]);

% start analog scanning and collect the data from the DAQ buffer into data.
% this the core of the DAQ process
data = s.startForeground();
cell1sweep=data(:,1);   
cell2sweep=data(:,2);
%after data collection analzye inputs for series_r and other properties
[access_R1, access_R2, seal_R1, seal_R2] = analyze_seal_series(cell1sweep, cell2sweep, seal_test_struct.Fs);

%plot the data on the corresponding axes in the GUI figure
plot(hseal.seal_test_axes1,seal_test_struct.seal_timebase,cell1sweep);
plot(hseal.seal_test_axes2,seal_test_struct.seal_timebase,cell2sweep,'r');

set(hseal.access_R1,'String',num2str(access_R1));
set(hseal.access_R2,'String',num2str(access_R2));
set(hseal.Seal_R1,'String',num2str(seal_R1));
set(hseal.Seal_R2,'String',num2str(seal_R2));

xlabel(hseal.seal_test_axes1,'seconds')
xlabel(hseal.seal_test_axes2,'seconds')
ylabel(hseal.seal_test_axes1,'nA')
ylabel(hseal.seal_test_axes2,'nA')

end

