function testMultiTargetsDAQ
%%Create DAQ Session
locations = FrankenScopeRigFile();

s = daq.createSession('ni'); %ni is company name

s.Rate=20000;
s.ExternalTriggerTimeout=30000000; %basically never time out
s.addAnalogOutputChannel('Dev3',2,'Voltage');

load(locations.PowerCalib,'LaserPower');


%initalize contact
IP='128.32.173.87';

[HoloSocket]=msocketPrep(IP);



%% get data
disp('Waiting for Hologram info')
timeoutTime = 1000000;

tstart = tic;
go =1;
while go;
    invar=msrecv(HoloSocket,.01); %order: power, DE, nTargets
    if ~isempty(invar) && ~ischar(invar)
        fprintf('Update Power: ')
        
        PowerRequest = (invar(1)*invar(3))/invar(2);
        if PowerRequest ==0
            Volt=0;
        else
        Volt = function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutputTF,PowerRequest);
        end
        fprintf([num2str(PowerRequest,2) ' W. -> ' num2str(Volt,2) ' V. ']);
        
        Fs = s.Rate;
        trialLength = 0.10;%s
        eomOffset = -0.15;
        
        [output] = makepulseoutputs(1, 1, trialLength*Fs, Volt ,1, Fs, trialLength);
        
        output(output==0)=eomOffset;
        output(end-20:end)=[];
        
        
        s.queueOutputData([output]);
        s.startForeground;
        
        mssend(HoloSocket,'gotit');

        fprintf(['Time since last run ' num2str(toc(tstart),2) 's\n']);
        tstart=tic;
    end
    
    if toc(tstart)>timeoutTime || strcmp(invar,'end');
        go=0;
        mssend(HoloSocket,'kthx');

    end
end

[output] = makepulseoutputs(1, 1, trialLength*Fs, eomOffset ,1, Fs, trialLength);
output(output==0)=eomOffset;
s.queueOutputData([output]);
s.startForeground;
disp('Ended')

 
