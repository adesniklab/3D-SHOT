%% Webcame record
savedir='C:\Users\slmadesnik\Desktop\data\alan\';
recordDuration = 15; %second
basename = 'Demo';


obj=imaq.VideoDevice;
vid=videoinput('winvideo');
vid.LoggingMode='disk';

src=getselectedsource(vid);
frameRates=set(src, 'FrameRate');
src.FrameRate=frameRates{1};

framesPerAcq = recordDuration * str2num(frameRates{1});
vid.FramesPerTrigger=framesPerAcq;

%setup daq trigger connection
[Setup ] = function_loadparameters(1);
S=Setup.DAQ; clear Setup;

nAcqs=1000;
i=1;

triggerconfig(vid, 'manual')

while i<nAcqs
stop(vid);
logfile=VideoWriter([savedir basename '_' num2str(i) '.avi'],'uncompressed AVI');
vid.DiskLogger=logfile;
start(vid);


disp('Ready to go');

state = 0;
while state == 0
    state = inputSingleScan(S);
end


trigger(vid);
pause(recordDuration)
state=0;
disp(['Acquired Movie # ' num2str(i)])
i=i+1;


end




%acuire x frames....
%log to disc....
%incriment filenamne...

%close vid