function autoCalibSI;
%% Introduction
% This is the alignment code to register SLM based holographic 2P
%   Photostimulation with ScanImage based 2P Imaging.

% This code assumes that you have three computers:
%   1) The Holography Computer
%       controls the SLM and the Sutter stage, and the substage camera.
%    2) The Scan Image Computer
%       controls all 2P image acquisition, as well as the optotune (or
%       other remote focusing)
%    3) The DAQ Computer
%        Typically the Master Computer, the central agregator and triggerer
%        during experiments, directly in control of the Laser power control
%        (EOM). During calibration is slave to the Holography Computer.

% This function 'autoCalibSI' is to be run on the ScanImage Computer. It
%   is designed to be used with alignSLMtoCam on the Holography Computer. And
%   autoCalibDAQ on the DAQ computer.

% Mostly this code acts as a slave to the Holography computer

% Written by Ian Antón Oldenburg with help from the Adesnik Lab 2019

%% Initialization and Pathing
addpath(genpath('C:\Users\Res_Imaging\Documents\MATLAB\msocket'));

disp('establishing socket connection with Holo Comp')
holoIP = '128.32.173.87';% '128.32.173.99';
HoloSocket = msconnect(holoIP,3014);

%handshake
invar=[];
while ~strcmp(invar,'A');
    invar = msrecv(HoloSocket,0.1);
    disp('Not Recieved')
end
disp('Recieved')

sendVar ='B';
mssend(HoloSocket,sendVar);
disp('Input from Holo Computer confirmed');

%%
%hSI = evalin('base','hSI');
%global autoCalibPlaneToUse

%autoCalibPlaneToUse = 5;

%hSI.hBeams.pzAdjust = 1;
%hSI.hBeams.pzCustom= {@autoCalibSIPowerFun} ;

%hSI.hFastZ.userZs = [ 0 autoCalibPlaneToUse];
%hSI.hFastZ.numVolumes = 10000;
%hSI.hFastZ.enable =1;

%hSI.extTrigEnable =0;


% hSI.startGrab();
%
% hSI.abort();

%disp('Waiting for cue from HoloComp')
%go =1;
%while go;
%    pause(0.1);
%    invar =msrecv(HoloSocket,0.1);
%    if ~isempty(invar) && ~ischar(invar)
%        fprintf(['Update Z Plane ' num2str(invar(1)) ' ']);
%        autoCalibPlaneToUse = invar(1);


        %         disp('Grab')
        %         hSI.acqState
        %
        %         hSI.startGrab();
        %         hSI.acqState
%        if invar(2)==0
%            hSI.abort();
%            disp('Aborted')
%        elseif invar(2)==1
%            if strcmpi(hSI.acqState,'idle')
%                hSI.hBeams.pzCustom= {@autoCalibSIPowerFun} ;
%
%                if invar(1)==0
%                    hSI.hFastZ.userZs = [ 0 5];
%                else
%                    hSI.hFastZ.userZs = [ 0 autoCalibPlaneToUse];
%                end
%                hSI.startGrab();
%                disp('Started')
%            else
%                hSI.abort();
%                hSI.hBeams.pzAdjust = 1;
%                hSI.hBeams.pzCustom= {@autoCalibSIPowerFun} ;
%
%                if invar(1)==0
%                    hSI.hFastZ.userZs = [ 0 50];
%                else
%                    hSI.hFastZ.userZs = [ 0 autoCalibPlaneToUse];
%                end
%                hSI.startGrab();
%                disp('restarted')
%            end
%        else
%            disp('Unrecognized Command')
%        end


%        mssend(HoloSocket,'gotit');

        % pause(1)
        %         if invar(2)
        %             hSI.startGrab();
        %         else
        %            hSI.abort();
        %         end
%    end

%    if strcmp(invar,'end')
%        disp('end kthx');
%        go=0;
%        mssend(HoloSocket,'kthx');
%        hSI.abort();
%    end
%end


disp('Waiting for Auto Command from HoloComp')
go =1;

invar =msrecv(HoloSocket,0.1);
while ~isempty(invar)
    invar =msrecv(HoloSocket,0.1);
end

while go;
     pause(0.1);
    invar =msrecv(HoloSocket,0.1);
 if ~isempty(invar)
     if strcmp(invar,'end')
        disp('end kthx');
        go=0;
        mssend(HoloSocket,'kthx');
        hSI.abort();
     else
         disp('Eval Command Received')
         try
         out = eval(invar);
         catch
             out='No Output';
             try
                 eval(invar);
             catch
                 out='Eval Error';
             end
         end
         if isempty(out)
             out='-';
         end
         disp(out)
         mssend(HoloSocket,out);
     end
 end
end
