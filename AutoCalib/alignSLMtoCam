function alignSLMtoCam
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

% This function 'alignSLMtoCam' is to be run on the Holography Computer. It
%   is designed to be used with autoCalibSI on the Scan Image Computer. And
%   autoCalibDAQ on the DAQ computer.

% Known Hardware requirements:
%   - A compatible substage Camera
%   - COM port controlled Sutter stage manipulator
%   - A Graphics Card for fast hologram computation

% The initial phases of this function require manually setting up the
% substage camera and preparing the alignment. The subsequent phase is
% fully automatic, and designed to run overnight. Depending on the speed of
% your camera and sutter stage, this can be very slow.

% Written by Ian Antón Oldenburg with help from the Adesnik Lab 2019


%% Section 1: Manual Setup
%% Initialization
% in case rerunning the script, try to stop ongoing processes to avoid errors.
try function_close_sutter( Sutter ); end
try function_stopBasCam(Setup); end
try [Setup.SLM ] = Function_Stop_SLM( Setup.SLM ); end


clear;close all;clc
%% Pathing...

tBegin = tic;
addpath(genpath('C:\Users\Holography\Documents\MATLAB\msocket\'));
rmpath(genpath('C:\Users\Holography\Documents\GitHub\SLM-Managment\'));
addpath(genpath('C:\Users\Holography\Desktop\SLM_Management\New_SLM_Code\'));
addpath(genpath('C:\Users\Holography\Desktop\SLM_Management\NOVOCGH_Code\'));
addpath(genpath('C:\Users\Holography\Desktop\SLM_Management\Calib_Data\'));
addpath(genpath('C:\Users\Holography\Desktop\SLM_Management\Basler\'));
addpath(genpath('C:\Users\Holography\Desktop\SLM_Management\IanTestCode\'));
disp('done pathing')

%% Setup Stuff
disp('Setting up stuff...');

[Setup ] = function_loadparameters2();
Setup.CGHMethod=2;
Setup.GSoffset=0;
Setup.verbose =0;
Setup.useGPU =1;


if Setup.useGPU
    disp('Getting gpu...'); %this can sometimes take a while at initialization
    g= gpuDevice;
end

[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );

Setup.Sutterport ='COM3';
try; function_close_sutter( Sutter ); end
[ Sutter ] = function_Sutter_Start( Setup );

try function_stopBasCam(Setup); end
[Setup] = function_startBasCam(Setup);
disp('Ready')

%% Make mSocketConnections with DAQ and SI Computers

disp('Waiting for msocket communication From DAQ')
%then wait for a handshake
srvsock = mslisten(3003);
masterSocket = msaccept(srvsock,5);
msclose(srvsock);
sendVar = 'A';
mssend(masterSocket, sendVar);
%MasterIP = '128.32.177.217';
%masterSocket = msconnect(MasterIP,3002);

invar = [];

while ~strcmp(invar,'B');
    invar = msrecv(masterSocket,.5);
end;
disp('communication from Master To Holo Established');
%%
disp('Waiting for msocket communication to ScanImage Computer')
%then wait for a handshake
srvsock2 = mslisten(3021);
SISocket = msaccept(srvsock2,5);
msclose(srvsock2);
sendVar = 'A';
mssend(SISocket, sendVar);
%MasterIP = '128.32.177.217';
%masterSocket = msconnect(MasterIP,3002);

invar = [];

while ~strcmp(invar,'B');
    invar = msrecv(SISocket,.1);
end;
disp('communication from Master To SI Established');

%% Put all Manual Steps First so that it can be automated

%% Set Power Levels

pwr = 40; %13 at full; 50 at 15 divided
disp(['individual hologram power set to ' num2str(pwr) 'mW']);

%%
disp('Find the spot and check if this is the right amount of power')
slmCoords = [0.4 0.4 0 1];
[ Holo,Reconstruction,Masksg ] = function_Make_3D_SHOT_Holos( Setup,slmCoords );

blankHolo = zeros([1920 1152]);

Function_Feed_SLM( Setup.SLM, Holo);
mssend(masterSocket,[pwr/1000 1 1]);

function_BasPreview(Setup);
mssend(masterSocket,[0 1 1]);

%% Make Sure you're centered
disp('Find Focal Plane, Center and Zero the Sutter')
disp('Leave the focus at Zoom 1. at a power that is less likely to bleach (14%)')
disp('Don''t forget to use Ultrasound Gel on the objective so it doesn''t evaporate')
mssend(masterSocket,[0 1 1]);

% function_Basler_Preview(Setup, 5);
function_BasPreview(Setup);

temp = input('Turn off Focus and press any key to continue');
Sutter.Reference = getPosition(Sutter.obj);


mssend(SISocket,[0 0]);

disp('Make Sure the DAQ computer is running autoCalibDAQ. and the SI computer running autoCalibSI');
disp('Make sure both lasers are on and the shutters open')
disp('Scanimage should be idle, nearly in plane with focus. and with the gain set high enough to see most of the FOV without saturating')


position = Sutter.Reference;
position(3) = position(3) + 100;
moveTime=moveTo(Sutter.obj,position);
disp('testing the sutter double check that it moved to reference +100');
temp = input('Ready to go (Press any key to continue)');

position = Sutter.Reference;
moveTime=moveTo(Sutter.obj,position);

%% Create a random set of holograms or use flag to reload
disp('First step Acquire Holograms')
reloadHolos =1;
tSingleCompile = tic;

if ~reloadHolos
    disp('Generating New Holograms...')
    disp('Everything after this should be automated so sitback and enjoy')

    npts = 750; %You can almost get through 750 with water before it evaporates.

    RX = 0.4;
    RY = 0.4;

    %ranges set by exploration moving holograms looking at z1 fov.
    slmXrange = [0.125 0.8]; %[0.5-RX 0.4+RX]; %you want to match these to the size of your imaging area
    slmYrange = [0.075 0.85];%[0.5-RY 0.5+RY];
    slmZrange = [-0.05 0.1];% [-0.1 0.15];

    dummy = rand;

    slmCoords=zeros(4,npts);
    for i =1:npts
        slmCoords(:,i) = [...
            rand*(slmXrange(2)-slmXrange(1))+slmXrange(1),...
            rand*(slmYrange(2)-slmYrange(1))+slmYrange(1),...
            rand*(slmZrange(2)-slmZrange(1))+slmZrange(1),...
            1];
    end

    figure(1);scatter3(slmCoords(1,:),slmCoords(2,:),slmCoords(3,:),'o')
    drawnow;
    %%compile random holograms




    disp('Compiling Holograms...')
    t = tic;
    try
        [ multiHolo,Reconstruction,Masksg ] = function_Make_3D_SHOT_Holos( Setup,slmCoords' );
        multiPts = npts;
    catch
        multiPts = 100;%round(npts/2);
        disp('Could not create multi holo, trying with fewer points')
        [ multiHolo,Reconstruction,Masksg ] = function_Make_3D_SHOT_Holos( Setup,slmCoords(:,1:multiPts));
    end
    fprintf(['Multi target Holo took ' num2str(toc(t)) 's\n'])
    multiCompileT = toc(t);

    % querry = input('do you want to check the range of the holos. turn off blasting then (1 yes, 0 no)');
    %
    % if querry ==1
    %      %%Check Range of multi holo
    %  disp('Starting with shutter closed, will display multiHolo. check that the range is appropriate on the basler');
    %   Function_Feed_SLM( Setup.SLM, multiHolo);
    %   mssend(masterSocket,[pwr/1000 1 multiPts]);
    %   function_BasPreview(Setup); %function_Basler_Preview(Setup, 5);
    % mssend(masterSocket,[0 1 1]);
    % end

   disp('Compiling Single Holograms')
%    disp('|------------------------------|')
%    fprintf('|')
%    tikmark = round(npts/30);
    parfor i =1:npts
        t=tic;
        fprintf(['Holo ' num2str(i)]);
        subcoordinates = slmCoords(:,i);

        [ Hologram,Reconstruction,Masksg ] = function_Make_3D_SHOT_Holos( Setup,subcoordinates' );
        hololist(:,:,i)=Hologram;
        fprintf([' took ' num2str(toc(t)) 's\n']);

%         if mod(i,tikmark)==0
%         fprintf('.')
%         end
    end
%     fprintf('|\n')

    out.hololist = hololist;
    out.slmCoords = slmCoords;
    out.multiHolo = multiHolo;
    save('tempHololist2.mat','out');
else
    disp('Reloading old Holograms...')
    try
        load('tempHololist2.mat','out');
    catch
        [f, p] =uigetfile;
        load(fullfile(p,f),'out');
    end
    hololist = out.hololist;
    slmCoords = out.slmCoords;
    npts = size(slmCoords,2);
    multiHolo = out.multiHolo;
    figure(1);scatter3(slmCoords(1,:),slmCoords(2,:),slmCoords(3,:),'o')

end

disp(['Done compiling holograms. Took ' num2str(toc(tSingleCompile)) 's']);

singleCompileT = toc(tSingleCompile);

out.hololist=[];

%% Collect background frames for signal to noise testing
disp('Collecting Background Frames');

nBackgroundFrames = 5;

Bgdframe = function_BasGetFrame(Setup,nBackgroundFrames);% function_Basler_get_frames(Setup, nBackgroundFrames );
Bgd = uint8(mean(Bgdframe,3));
meanBgd = mean(single(Bgdframe(:)));
stdBgd =  std(single(Bgdframe(:)));

threshHold = meanBgd+3*stdBgd;

fprintf(['3\x03c3 above mean threshold ' num2str(threshHold,4) '\n'])

%% Scan Image Planes Calibration
disp('Begining SI Depth calibration, we do this first incase spots burn holes with holograms')
tSI=tic;

disp('Initialize ScanImage Computer')
%check if connected
mssend(SISocket,'1+2');
invar=[];
while ~strcmp(num2str(invar),'3') %stupid cludge so that [] read as false
    invar = msrecv(SISocket,0.01);
end
disp('linked')


%commands copied from autocalibSI
mssend(SISocket,['hSI = evalin(''base'',''hSI'');']);
mssend(SISocket,['global autoCalibPlaneToUse']);
mssend(SISocket,['autoCalibPlaneToUse = 1;']); %default second plane
mssend(SISocket,['hSI.hBeams.pzAdjust = 1;']);
mssend(SISocket,['hSI.hBeams.pzCustom= {@autoCalibSIPowerFun} ;']);
mssend(SISocket,['hSI.hFastZ.userZs = [ 0 autoCalibPlaneToUse];']);
mssend(SISocket,['hSI.hFastZ.numVolumes = 10000;']);
mssend(SISocket,['hSI.hFastZ.enable =1;']);
mssend(SISocket,['hSI.extTrigEnable =0;']);

%wait until everything is done
mssend(SISocket,'3+5');
invar=[];
while ~strcmp(num2str(invar),'8') %stupid cludge so that [] read as false
    invar = msrecv(SISocket,0.01);
end

zsToUse = [0:2:20]; %Scan Image Maxes out at 89

SIUZ = -25:5:150;% linspace(-120,200,SIpts);
SIpts = numel(SIUZ);

%generate xy grid
sz = size(Bgd);
gridpts = 25;
xs = round(linspace(1,sz(1),gridpts+2));
ys = round(linspace(1,sz(2),gridpts+2));

xs([1 end])=[];
ys([1 end])=[];
range =15;

clear dimx dimy XYSI
c=0;
for i=1:gridpts
    for k=1:gridpts
        c=c+1;
        dimx(:,c) = xs(i)-range:xs(i)+range;
        dimy(:,c) = ys(k)-range:ys(k)+range;

        XYSI(:,c) = [xs(i) ys(k)];
    end
end

disp(['We will collect ' num2str(numel(zsToUse)) ' planes.'])

SIVals = zeros([SIpts c numel(zsToUse)]);

for k =1:numel(zsToUse)
    t=tic;
    z = zsToUse(k);
    fprintf(['Testing plane ' num2str(z) ': ']);

    mssend(SISocket,['changeSIPlane(' z ')']); %ToDo check that this works.
    invar=[];
    while ~strcmp(invar,'gotit')
        invar = msrecv(SISocket,0.01);
    end
    %streamline handshake


    dataUZ = zeros([sz SIpts]);
    for i = 1:numel(SIUZ)
        fprintf([num2str(round(SIUZ(i))) ' ']);

        currentPosition = getPosition(Sutter.obj);
        position = Sutter.Reference;
        position(3) = position(3) + (SIUZ(i));
        diff = currentPosition(3)-position(3);
        %           tic;
        moveTime=moveTo(Sutter.obj,position);
        %           toc;
        if i==1
            pause(1)
        else
            pause(0.1);
        end

        frame = function_BasGetFrame(Setup,3);%function_Basler_get_frames(Setup, 3 );
        frame = uint8(mean(frame,3));



        frame =  max(frame-Bgd,0);
        frame = imgaussfilt(frame,2);
        dataUZ(:,:,i) =  frame;

        %          figure(1);
        %          subplot(1,2,1);
        %          imagesc(frame);
        %          subplot(1,2,2);
        %          imagesc(nanmean(dataUZ,3));
        %          drawnow
    end
    position = Sutter.Reference;
    moveTime=moveTo(Sutter.obj,position);
    pause(0.1)

    mssend(SISocket,['changeSIPlane(-1)']); %ToDo check that this works.
    invar=[];
    while ~strcmp(invar,'gotit')
        invar = msrecv(SISocket,0.01);
    end


    for i =1:c
        SIVals(:,i,k) = squeeze(mean(mean(dataUZ(dimx(:,i),dimy(:,i),:))));
    end


    disp([' Took ' num2str(toc(t)) 's']);


end

%mssend(SISocket,'end');

disp(['Scanimage calibration done whole thing took ' num2str(toc(tSI)) 's']);
siT=toc(tSI);

%%

disp('Putting off the actual analysis until later, Just saving for now')
out.SIVals =SIVals;
out.XYSI =XYSI;
out.zsToUse =zsToUse;
out.SIUZ = SIUZ;

save('TempSIAlign.mat','out')


%% Coarse Data
% npts=100;

disp('Begining Coarse Holo spot finding')
coarsePts = 9; %odd number please
coarseUZ = linspace(-120,200,coarsePts);
mssend(masterSocket,[0 1 1]);

invar='flush';
while ~isempty(invar)
    invar = msrecv(masterSocket,0.01);
end

vals = nan(coarsePts,npts);
xyLoc = nan(2,npts);
tstart=tic;
sz = size(Bgd);
sizeFactor = 4; %will have to manually test that this is scalable by 4
newSize = sz / sizeFactor;

dataUZ2 = uint8(nan([newSize  numel(coarseUZ) npts]));
maxProjections=uint8(nan([newSize  npts]));

range=round(16 / sizeFactor);


for i = 1:numel(coarseUZ)
    fprintf(['First Pass Holo, Depth: ' num2str(coarseUZ(i)) '. Holo : '])
    t = tic;

    currentPosition = getPosition(Sutter.obj);
    position = Sutter.Reference;
    position(3) = position(3) + (coarseUZ(i));
    diff = currentPosition(3)-position(3);
    moveTime=moveTo(Sutter.obj,position);

    if i==1
        pause(1)
    else
        pause(0.1);
    end

    for k=1:npts
        fprintf([num2str(k) ' ']);

        if mod(k,25)==0
            fprintf('\n')
        end


        Function_Feed_SLM( Setup.SLM, hololist(:,:,k));

        mssend(masterSocket,[pwr/1000 1 1]);
        invar=[];
        while ~strcmp(invar,'gotit')
            invar = msrecv(masterSocket,0.01);
        end
        frame = function_BasGetFrame(Setup,1);%;
        frame = uint8(mean(frame,3));

        mssend(masterSocket,[0 1 1]);
        invar=[];
        while ~strcmp(invar,'gotit')
            invar = msrecv(masterSocket,0.01);
        end
        frame =  max(frame-Bgd,0);
        frame = imgaussfilt(frame,2);
        frame = imresize(frame,newSize);
        dataUZ2(:,:,i,k) =  frame;

        %          figure(1);
        %          subplot(1,2,1);
        %          imagesc(frame);
        %          subplot(1,2,2);
        %          imagesc(nanmean(dataUZ,3));
        %          drawnow
    end
    fprintf(['\nPlane Took ' num2str(toc(t)) ' seconds\n'])

end

position = Sutter.Reference;
moveTime=moveTo(Sutter.obj,position);
pause(0.1)

disp('Calculating Depths and Vals')
for k=1:npts
    dataUZ = dataUZ2(:,:,:,k);
    mxProj = max(dataUZ,[],3);
    [ x,y ] =function_findcenter(mxProj );
    xyLoc(:,k) = [x,y]*sizeFactor;

    maxProjections(:,:,k)=mxProj;

    dimx = max((x-range),1):min((x+range),size(frame,1));
    dimy =  max((y-range),1):min((y+range),size(frame,2));

    thisStack = squeeze(mean(mean(dataUZ(dimx,dimy,:))));
    vals(:,k) = thisStack;
    depthIndex = find(thisStack == max(thisStack),1);

    fprintf(['Spot ' num2str(k) ' centered at depth ' num2str(round(coarseUZ(depthIndex)))...
        'um. Value: ' num2str(round(vals(depthIndex,k))) '\n']);
end
%     fprintf(['Took ' num2str(toc(t),2) 's\n']);

fprintf(['All Done. Total Took ' num2str(toc(tstart)) 's\n']);
coarseT = toc(tstart);

%% Second pass
disp('Begining fine spot finding')
tFine = tic;

finePts = 13;
fineRange = 40;

[mx, mxi] = max(vals);

fineVals = nan(finePts,npts);
fineZs = nan(finePts,npts);
xyFine = nan(2,npts);

peakValue = nan([1 npts]);
peakDepth = nan([1 npts]);
peakFWHM = nan([1 npts]);

range=16;

invar='flush';
while ~isempty(invar)
    invar = msrecv(masterSocket,0.01);
end

counter = 0;
for k=1:npts
    if mx(k)>threshHold
        counter=counter+1;
        t=tic;

        disp(['Second Pass Holo ' num2str(k) ' of ' num2str(npts)]);
        disp([num2str(counter) ' of ' num2str(sum(mx>threshHold)) ' eligible Holos']);
        disp(['Esitmated depth ' num2str(coarseUZ(mxi(k)))]);

        Function_Feed_SLM( Setup.SLM, hololist(:,:,k));

        fineUZ = linspace(coarseUZ(mxi(k))-fineRange,coarseUZ(mxi(k))+fineRange,finePts);
        fineZs(:,k) = fineUZ;

        dataUZ = uint8(nan([size(Bgdframe(:,:,1))  finePts]));
        fprintf('Depth: ')

        for i = 1:numel(fineUZ)
            fprintf([num2str(round(fineUZ(i))) ' ']);

            currentPosition = getPosition(Sutter.obj);
            position = Sutter.Reference;
            position(3) = position(3) + (fineUZ(i));
            diff = currentPosition(3)-position(3);
            %          tic;
            moveTime=moveTo(Sutter.obj,position);
            %          toc;
            if i==1
                pause(1)
            else
                pause(0.1);
            end

            mssend(masterSocket,[pwr/1000 1 1]);
            invar=[];
            while ~strcmp(invar,'gotit')
                invar = msrecv(masterSocket,0.01);
            end
            frame = function_BasGetFrame(Setup,3);%function_Basler_get_frames(Setup, 1 );
            frame = uint8(mean(frame,3));

            mssend(masterSocket,[0 1 1]);
            invar=[];
            while ~strcmp(invar,'gotit')
                invar = msrecv(masterSocket,0.01);
            end
            frame =  max(frame-Bgd,0);
            frame = imgaussfilt(frame,2);
            dataUZ(:,:,i) =  frame;

        end
        position = Sutter.Reference;
        moveTime=moveTo(Sutter.obj,position);
        pause(0.1)

        mxProj = max(dataUZ,[],3);
        [ x,y ] =function_findcenter(mxProj );
        xyFine(:,k) = [x,y];

        dimx = max((x-range),1):min((x+range),size(frame,1));
        dimy =  max((y-range),1):min((y+range),size(frame,2));

        thisStack = squeeze(mean(mean(dataUZ(dimx,dimy,:))));
        fineVals(:,k) = thisStack;
        depthIndex = find(thisStack == max(thisStack),1);

        try
            ff = fit(fineUZ', thisStack, 'gauss1');
            peakValue(k) =ff.a1;
            peakDepth(k) =ff.b1;
            peakFWHM(k) = 2*sqrt(2*log(2))*ff.c1/sqrt(2);
        catch
            disp('Error on Fit')
            peakValue(k) = NaN;
            peakDepth(k) = NaN;
            peakFWHM(k) = NaN;
        end

        fprintf(['\nFine measurement centered at depth ' num2str(round(fineUZ(depthIndex)))...
            'um. Value: ' num2str(round(fineVals(depthIndex,k))) '\n']);
        fprintf(['Took ' num2str(toc(t),2) 's\n']);
    end
end
fprintf(['All Done. Total Took ' num2str(toc(tFine)) 's\n']);

%%Convert to list of slm cam pairs
c=0;
clear slmXYZ basXYZ basVal
for i=1:npts
    if mx(i)>threshHold
        c=c+1;

        slmXYZ(:,c) = slmCoords(:,i);
        basXYZ(1:2,c) = xyFine(:,i);
        basXYZ(3,c) = peakDepth(i);

        basVal(c) = peakValue(i);
    end
end

% basVal=basVal./max(basVal); %Convert basVal into scalar

disp('Saving the fine SLM to Camera Data.');
out.slmXYZ = slmXYZ;
out.basXYZ = basXYZ;
out.basVal = basVal;

out.FWHM = peakFWHM;

out.fineVals = fineVals;
out.fineZs = fineZs;

out.maxProjections = maxProjections;

save('tempSLMtoBasVals','out')
fineT = toc(tFine);

disp('second super secure save')
save('Alignment.mat')
%     disp(['All in all the procedure took ' num2str(toc(tBegin)) 's! Bye.']);


%%
slmXYZBackup2 = slmXYZ;
basXYZBackup2 = basXYZ;
basValBackup2 = basVal;



%% exclude trials
excludeTrials = all(basXYZ(1:2,:)==[1 1]');

excludeTrials = excludeTrials | basVal>260; %max of this camera is 255

basDimensions = size(Bgdframe);
excludeTrials = excludeTrials | basXYZ(1,:)>=basDimensions(1)-1;
excludeTrials = excludeTrials | basXYZ(2,:)>=basDimensions(2)-1;

slmXYZBackup = slmXYZ(:,~excludeTrials);
basXYZBackup = basXYZ(:,~excludeTrials);
basValBackup = basVal(:,~excludeTrials);
%% fit SLM to Camera
%use model terms

basXYZ = basXYZBackup;
slmXYZ = slmXYZBackup;
basVal = basValBackup;

disp('Fitting SLM to Camera')
modelterms =[0 0 0; 1 0 0; 0 1 0; 0 0 1;...
    1 1 0; 1 0 1; 0 1 1 ; 1 1 1 ;...
    2 0 0; 0 2 0; 0 0 2;  ...
    2 0 1; 2 1 0; 0 2 1; 1 2 0; 0 1 2;  1 0 2; ... ];  %XY spatial calibration model for Power interpolations
    2 2 0; 2 0 2; 0 2 2; 2 1 1; 1 2 1; 1 1 2;];
reOrder = randperm(size(slmXYZ,2));
slmXYZ = slmXYZ(:,reOrder);
basXYZ = basXYZ(:,reOrder);

holdback = 100;%50;

refAsk = (slmXYZ(1:3,1:end-holdback))';
refGet = (basXYZ(1:3,1:end-holdback))';

%  SLMtoCam = function_3DCoC(refAsk,refGet,modelterms);

errScalar = 2.5;%2.5;
[SLMtoCam, trialN] = function_3DCoCIterative(refAsk,refGet,modelterms,errScalar,0);

Ask = refAsk;
True = refGet;
Get = function_Eval3DCoC(SLMtoCam,Ask);

figure(103);clf
subplot(1,2,1)
scatter3(True(:,1),True(:,2),True(:,3),'*','k')
hold on
scatter3(Get(:,1), Get(:,2), Get(:,3),'o','r')

ylabel('Y Axis Pixels')
xlabel('X axis Pixels')
zlabel('Depth \mum')
% legend('Measured targets', 'Estimated Targets');
title({'Reference Data'; 'SLM to Camera'})

refRMS = sqrt(sum((Get-True).^2,2));
subplot(1,2,2)
scatter3(True(:,1),True(:,2),True(:,3),[],refRMS,'filled');
colorbar
ylabel('Y Axis Pixels')
xlabel('X axis Pixels')
zlabel('Depth \mum')
title({'Reference Data'; 'RMS Error in position'})
caxis([0 30])


Ask = (slmXYZ(1:3,end-holdback:end))';
True = (basXYZ(1:3,end-holdback:end))';
Get = function_Eval3DCoC(SLMtoCam,Ask);

figure(101);clf
subplot(1,3,1)
scatter3(True(:,1),True(:,2),True(:,3),'*','k')
hold on
scatter3(Get(:,1), Get(:,2), Get(:,3),'o','r')


ylabel('Y Axis Pixels')
xlabel('X axis Pixels')
zlabel('Depth \mum')
legend('Measured targets', 'Estimated Targets');
title('SLM to Camera')

RMS = sqrt(sum((Get-True).^2,2));
meanRMS = nanmean(RMS);
disp('Error based on Holdback Data...')
disp(['The RMS error: ' num2str(meanRMS) ' pixels for SLM to Camera']);

pxPerMu = size(frame,1) / 1000; %really rough approximate of imaging size

disp(['Thats approx ' num2str(meanRMS/pxPerMu) ' um']);

xErr = sqrt(sum((Get(:,1)-True(:,1)).^2,2));
yErr = sqrt(sum((Get(:,2)-True(:,2)).^2,2));
zErr = sqrt(sum((Get(:,3)-True(:,3)).^2,2));

disp('Mean:')
disp(['X: ' num2str(mean(xErr)/pxPerMu) 'um. Y: ' num2str(mean(yErr)/pxPerMu) 'um. Z: ' num2str(mean(zErr)) 'um.']);
disp('Max:')
disp(['X: ' num2str(max(xErr)/pxPerMu) 'um. Y: ' num2str(max(yErr)/pxPerMu) 'um. Z: ' num2str(max(zErr)) 'um.']);

subplot(1,3,2)
scatter3(True(:,1),True(:,2),True(:,3),[],RMS,'filled');
colorbar
ylabel('Y Axis Pixels')
xlabel('X axis Pixels')
zlabel('Depth \mum')
title('RMS Error in position')


refAsk = (basXYZ(1:3,1:end-holdback))';
refGet = (slmXYZ(1:3,1:end-holdback))';

%  camToSLM = function_3DCoC(refAsk,refGet,modelterms);

[camToSLM, trialN] = function_3DCoCIterative(refAsk,refGet,modelterms,errScalar,0);


Ask = (basXYZ(1:3,end-holdback:end))';
True = (slmXYZ(1:3,end-holdback:end))';
Get = function_Eval3DCoC(camToSLM,Ask);


figure(101);
subplot(1,3,3)
scatter3(True(:,1),True(:,2),True(:,3),'*','k')
hold on
scatter3(Get(:,1), Get(:,2), Get(:,3),'o','r')

ylabel('Y Axis SLM units')
xlabel('X axis SLM units')
zlabel('Depth units')
legend('Measured targets', 'Estimated Targets');
title('Camera to SLM')

% RMS = sqrt(sum((Get-True).^2,2));
% meanRMS = nanmean(RMS);
%
% disp(['The RMS error: ' num2str(meanRMS) ' SLM units for Camera to SLM']);




CoC.camToSLM=camToSLM;
CoC.SLMtoCam = SLMtoCam;

out.CoC=CoC;
out.CoCmodelterms = modelterms;

rtXYZ = function_Eval3DCoC(SLMtoCam,function_Eval3DCoC(camToSLM,basXYZ(1:3,end-holdback:end)'));

err = sqrt(sum((rtXYZ - basXYZ(1:3,end-holdback:end)').^2,2));
meanRTerr = nanmean(err);
disp(['The Mean Round Trip RMS error: ' num2str(meanRTerr) ' pixels (' num2str(meanRTerr/pxPerMu) ' um) camera to SLM to camera']);

%% fit power as a function of SLM
disp('Fitting Power as a function of SLM')
%  modelterms =[0 0 0; 1 0 0; 0 1 0; 0 0 1;...
%      1 1 0; 1 0 1; 0 1 1; 1 1 1; 2 0 0; 0 2 0; 0 0 2;...
%      2 0 1; 2 1 0; 0 2 1; 0 1 2; 1 2 0; 1 0 2;   ];  %XY spatial calibration model for Power interpolations
slmXYZ = slmXYZBackup;
basVal = basValBackup;


modelterms =[0 0 0; 1 0 0; 0 1 0; 0 0 1;...
    1 1 0; 1 0 1; 0 1 1; 1 1 1; 2 0 0; 0 2 0; 0 0 2;];%...
%     2 0 1; 2 1 0; 0 2 1; 0 1 2; 1 2 0; 1 0 2;...
%     2 2 0; 2 0 2; 0 2 2; 2 1 1; 1 2 1; 1 1 2; ];  %XY spatial calibration model for Power interpolations

intVal = basVal;
intVal = sqrt(intVal); %convert fluorescence intensity (2P) to 1P illumination intensity
intVal=intVal./max(intVal(:));

refAsk = (slmXYZ(1:3,1:end-holdback))';
refGet = intVal(1:end-holdback);

SLMtoPower =  polyfitn(refAsk,refGet,modelterms);

Ask = (slmXYZ(1:3,end-holdback:end))';
True = intVal(end-holdback:end)';

Get = polyvaln(SLMtoPower,Ask);

RMS = sqrt(sum((Get-True).^2,2));
meanRMS = nanmean(RMS);

figure(1);clf
subplot(2,3,1)
scatter3(slmXYZ(1,:),slmXYZ(2,:),slmXYZ(3,:),[],intVal,'filled');
ylabel('Y Axis SLM units')
xlabel('X axis SLM units')
zlabel('Z axis SLM units')
title('Measured Power (converted to 1p)')
colorbar
axis square

subplot(2,3,2)
scatter3(slmXYZ(1,:),slmXYZ(2,:),slmXYZ(3,:),[],polyvaln(SLMtoPower,slmXYZ(1:3,:)'),'filled');
ylabel('Y Axis SLM units')
xlabel('X axis SLM units')
zlabel('Z axis SLM units')
title('Estimated Power Norm.')
colorbar
axis square

subplot(2,3,4)
% scatter3(slmXYZ(1,:),slmXYZ(2,:),slmXYZ(3,:),[],polyvaln(SLMtoPower,slmXYZ(1:3,:)')-intVal','filled');
scatter3(slmXYZ(1,:),slmXYZ(2,:),slmXYZ(3,:),[],basVal,'filled');

ylabel('Y Axis SLM units')
xlabel('X axis SLM units')
zlabel('Z axis SLM units')
title('Raw Fluorescence')
colorbar
axis square

subplot(2,3,5)
c = sqrt((polyvaln(SLMtoPower,slmXYZ(1:3,:)')-intVal').^2);
scatter3(slmXYZ(1,:),slmXYZ(2,:),slmXYZ(3,:),[],c,'filled');
ylabel('Y Axis SLM units')
xlabel('X axis SLM units')
zlabel('Z axis SLM units')
title('Error RMS (A.U.)')
colorbar
axis square

subplot(2,3,3)
c = (polyvaln(SLMtoPower,slmXYZ(1:3,:)').^2);
scatter3(slmXYZ(1,:),slmXYZ(2,:),slmXYZ(3,:),[],c,'filled');
ylabel('Y Axis SLM units')
xlabel('X axis SLM units')
zlabel('Z axis SLM units')
title('Estimated 2P Power')
colorbar
axis square

subplot(2,3,6)
normVal = basVal./max(basVal(:));

c = (polyvaln(SLMtoPower,slmXYZ(1:3,:)').^2)-normVal';
scatter3(slmXYZ(1,:),slmXYZ(2,:),slmXYZ(3,:),[],c,'filled');
ylabel('Y Axis SLM units')
xlabel('X axis SLM units')
zlabel('Z axis SLM units')
title('Error 2P Power')
colorbar
axis square


disp(['The RMS error: ' num2str(meanRMS) ' A.U. Power Estimate']);
disp(['The Max power error: ' num2str(max(RMS)*100) '% of request']);

CoC.SLMtoPower = SLMtoPower;
out.CoC = CoC;
out.powerFitmodelTerms = modelterms;
%% Extract data to fit OptotuneZ as a function of camera XYZ

disp('Fitting optotune to Camera... extracting optotune depths')
tFits=tic;

out.SIVals =SIVals;
out.XYSI =XYSI;
out.zsToUse =zsToUse;
out.SIUZ = SIUZ;

nGrids =size(SIVals,2);
nOpt = size(zsToUse,2);
fastWay = 0;

 clear SIpeakVal SIpeakDepth
fprintf('Extracting point: ')
parfor i=1:nGrids
    for k=1:nOpt
        if fastWay
            [a, b] = max(SIVals(:,i,k));
            SIpeakVal(i,k)=a;
            SIpeakDepth(i,k) =SIUZ(b);
        else
            try
                ff = fit(SIUZ', SIVals(:,i,k), 'gauss1');
                SIpeakVal(i,k) =ff.a1;
                SIpeakDepth(i,k) =ff.b1;
            catch
                SIpeakVal(i,k) = nan;
                SIpeakDepth(i,k) = nan;
            end
        end
    end
    fprintf([num2str(i) ' '])
    if mod(i,25)==0
        disp(' ')
    end
end

fprintf('\ndone\n')


b1 = SIpeakVal;
b2 = SIpeakDepth;

excl = SIpeakVal<(threshHold/1.5);
disp([num2str(sum(excl(:))) ' points excluded b/c below threshold'])
SIpeakVal(excl)=nan;
SIpeakDepth(excl)=nan;
% excl = SIpeakVal>20;
% SIpeakVal(excl)=nan;
% SIpeakDepth(excl)=nan;

excl = SIpeakDepth<-50;
disp([num2str(sum(excl(:))) ' points excluded b/c too deep'])
SIpeakVal(excl)=nan;
SIpeakDepth(excl)=nan;


%% CamToOpt
modelterms =[0 0 0; 1 0 0; 0 1 0; 0 0 1;...
    1 1 0; 1 0 1; 0 1 1; 1 1 1; 2 0 0; 0 2 0; 0 0 2;...
    2 0 1; 2 1 0; 0 2 1; 0 1 2; 1 2 0; 1 0 2;...
     2 2 0; 2 0 2; 0 2 2; 2 1 1; 1 2 1; 1 1 2; ];  %XY spatial calibration model for Power interpolations

camXYZ(1:2,:) =  repmat(XYSI,[1 nOpt]);
camXYZ(3,:) =  SIpeakDepth(:);

camPower = SIpeakVal(:);

optZ = repmat(zsToUse,[nGrids 1]);
optZ = optZ(:);

testSet = randperm(numel(optZ),50);

otherSet = ones([numel(optZ) 1]);
otherSet(testSet)=0;
otherSet = logical(otherSet);

refAsk = (camXYZ(1:3,otherSet))';
refGet = optZ(otherSet);

camToOpto =  polyfitn(refAsk,refGet,modelterms);


Ask = camXYZ(1:3,testSet)';
True = optZ(testSet);

Get = polyvaln(camToOpto,Ask);

RMS = sqrt(sum((Get-True).^2,2));
meanRMS = nanmean(RMS);

CoC.camToOpto= camToOpto;
%%fig
figure(201);clf
scatter3(camXYZ(1,:),camXYZ(2,:),camXYZ(3,:),[],camPower,'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis \mum')
title('Measured Fluorescence intensity by space')
c = colorbar;
c.Label.String = 'Fluorescent Intensity';
axis square

figure(2);clf
subplot(2,2,1)
scatter3(camXYZ(1,:),camXYZ(2,:),camXYZ(3,:),[],optZ,'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis \mum')
title('Measured Optotune Level (A.U.)')
c = colorbar;
c.Label.String = 'Optotune Depth';
axis square

subplot(2,2,2)
scatter3(camXYZ(1,:),camXYZ(2,:),camXYZ(3,:),[],polyvaln(camToOpto,camXYZ(1:3,:)'),'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis \mum')
title('Estimated Optotune Level (A.U.)')
c = colorbar;
c.Label.String = 'Optotune Depth';
axis square

subplot(2,2,3)
scatter3(camXYZ(1,:),camXYZ(2,:),camXYZ(3,:),[],polyvaln(camToOpto,camXYZ(1:3,:)')-optZ,'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis \mum')
title('Error (A.U.)')
c = colorbar;
c.Label.String = 'Optotune Depth';
axis square

subplot(2,2,4)
c = sqrt((polyvaln(camToOpto,camXYZ(1:3,:)')-optZ).^2);
scatter3(camXYZ(1,:),camXYZ(2,:),camXYZ(3,:),[],c,'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis \mum')
title('Error RMS (A.U.)')
c = colorbar;
c.Label.String = 'Optotune Depth';
axis square

%%optZtoCam
cam2XYZ(1:2,:) =  repmat(XYSI,[1 nOpt]);
cam2XYZ(3,:) =  optZ(:);
obsZ =  SIpeakDepth(:);

testSet = randperm(numel(obsZ),50);
otherSet = ones([numel(obsZ) 1]);
otherSet(testSet)=0;
otherSet = logical(otherSet);

refAsk = (cam2XYZ(1:3,otherSet))';
refGet = obsZ(otherSet);

OptZToCam =  polyfitn(refAsk,refGet,modelterms);


Ask = cam2XYZ(1:3,testSet)';
True = obsZ(testSet);

Get = polyvaln(OptZToCam,Ask);

RMS = sqrt(sum((Get-True).^2,2));
meanRMS = nanmean(RMS);
disp(['The mean error in Optotune depth prediction is : ' num2str(meanRMS) 'um']);
disp(['The Max error is: ' num2str(max(RMS)) 'um'])

CoC.OptZToCam= OptZToCam;

out.CoC=CoC;
out.SIfitModelTerms = modelterms;
%%fig
figure(3);clf
subplot(2,2,1)
scatter3(cam2XYZ(1,:),cam2XYZ(2,:),cam2XYZ(3,:),[],obsZ,'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis Optotune Units')
title('Measured Optotune Level (A.U.)')
c = colorbar;
c.Label.String = 'Depth \mum';
axis square

subplot(2,2,2)
scatter3(cam2XYZ(1,:),cam2XYZ(2,:),cam2XYZ(3,:),[],polyvaln(OptZToCam,cam2XYZ(1:3,:)'),'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis Optotune Units')
title('Estimated Optotune Level (A.U.)')
c = colorbar;
c.Label.String = 'Depth \mum';
axis square

subplot(2,2,3)
scatter3(cam2XYZ(1,:),cam2XYZ(2,:),cam2XYZ(3,:),[],polyvaln(OptZToCam,cam2XYZ(1:3,:)')-obsZ,'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis Optotune Units')
title('Error (A.U.)')
c = colorbar;
c.Label.String = 'Depth \mum';
axis square

subplot(2,2,4)
c = sqrt((polyvaln(OptZToCam,cam2XYZ(1:3,:)')-obsZ).^2);
scatter3(cam2XYZ(1,:),cam2XYZ(2,:),cam2XYZ(3,:),[],c,'filled');
ylabel('Y Axis pixels')
xlabel('X axis pixels')
zlabel('Z axis Optotune Units')
title('Error RMS (A.U.)')
c = colorbar;
c.Label.String = 'Depth \mum';
axis square

disp(['All fits took ' num2str(toc(tFits)) 's']);
fitsT = toc(tFits);
%% Now using these CoC lets create holograms that shoot a pattern into a field of view
disp('Picking Holes to Burn')


nBurnGrid = 8; %number of points in the burn grid

sz = size(Bgd);

% xpts = linspace(1,sz(1),nBurnGrid+2);
% xpts([1 end])=[];
%
% ypts = linspace(1,sz(2),nBurnGrid+2);
% ypts([1 end])=[];

%changed 2/22/19 so fill area better
xpts = linspace(1,sz(1),nBurnGrid);
ypts = linspace(1,sz(2),nBurnGrid);


XYpts =[];
for i=1:nBurnGrid
    for k=1:nBurnGrid
        XYpts(:,end+1) = [xpts(i) ypts(k)];
    end
end

zsToBlast = 0:10:80; %OptoPlanes to Blast
interXdist = xpts(2)-xpts(1);
%  xOff = round(interXdist/numel(zsToBlast));
interYdist = ypts(2)-ypts(1);
%  yOff = round(interYdist/numel(zsToBlast));

gridSide = ceil(sqrt(numel(zsToBlast)));
xOff = round(interXdist/gridSide);
yOff = round(interYdist/gridSide);

%Turn into a more unique looking pattern
numPts = size(XYpts,2);
FractionOmit = 0.25;
XYpts(:,randperm(numPts,round(numPts*FractionOmit)))=[];
XYpts = reshape(XYpts,[2 numel(XYpts)/2]);

disp([num2str(size(XYpts,2)) ' points per plane selected. ' num2str(size(XYpts,2)*numel(zsToBlast)) ' total'])

figure(6);
scatter(XYpts(1,:),XYpts(2,:),'o');


figure(4); clf


clear XYtarg SLMtarg
for i = 1:numel(zsToBlast)

    %offset the xy points each Z plane

    %      XYuse = bsxfun(@plus,XYpts,([xOff yOff].*(i-1))');

    a = mod(i-1,gridSide);
    b = floor((i-1)/gridSide);
    %      [a b]

    XYuse = bsxfun(@plus,XYpts,([xOff*a yOff*b])');




    optoZ = zsToBlast(i);

    zOptoPlane = ones([1 size(XYuse,2)])*optoZ;

    Ask = [XYuse; zOptoPlane];
    estCamZ = polyvaln(OptZToCam,Ask');
    meanCamZ(i) = nanmean(estCamZ); %for use by sutter
    Ask = [XYuse; estCamZ'];
    estSLM = function_Eval3DCoC(camToSLM,Ask');
    estPower = polyvaln(SLMtoPower,estSLM);

    XYtarg{i} = [XYuse; zOptoPlane];
    SLMtarg{i} = [estSLM estPower];

    subplot(1,2,1)
    scatter3(XYuse(1,:),XYuse(2,:),estCamZ,[],estPower,'filled')

    hold on
    subplot (1,2,2)
    scatter3(estSLM(:,1),estSLM(:,2),estSLM(:,3),[],estPower,'filled')

    hold on
end


subplot(1,2,1)
title('Targets in Camera Space')
zlabel('Depth \mum')
xlabel('X pixels')
ylabel('Y pixels')

subplot(1,2,2)
title('Targets in SLM space')
xlabel('X SLM')
ylabel('Y SLM')
zlabel('Z SLM')
c = colorbar;
c.Label.String = 'Estimated Power';

%% Burn Holes
disp('Compiling Holos To Burn')
tCompileBurn = tic;

clear tempHololist
for k = 1:numel(zsToBlast)
    parfor i=1:size(XYuse,2)
        t=tic;
        fprintf(['Compiling Holo ' num2str(i) ' for depth ' num2str(k)]);
        subcoordinates =  [SLMtarg{k}(i,1:3) 1];
        DE(i) = SLMtarg{k}(i,4);
        [ Hologram,~,~ ] = function_Make_3D_SHOT_Holos( Setup,subcoordinates );
        tempHololist(:,:,i)=Hologram;
        fprintf([' took ' num2str(toc(t)) 's\n']);
    end
    holos{k}=tempHololist;
    Diffraction{k}=DE;
end
disp(['Compiling Done took ' num2str(toc(tCompileBurn)) 's']);

compileBurnT = toc(tCompileBurn);

%%
disp('Blasting Holes for SI to SLM alignment, this will take about an hour and take 25Gb of space')
tBurn = tic;

%confirm that SI computer in eval Mode
mssend(SISocket,'1+2');
invar=[];
while ~strcmp(num2str(invar),'3') %stupid cludge so that [] read as false
    invar = msrecv(SISocket,0.01);
end
disp('linked')

%mssend(SISocket,'hSI.startGrab()');
%setup acquisition

numVol =5; %number of SI volumes to average
baseName = '''calib''';

mssend(SISocket,['hSI.hFastZ.userZs = [' num2str(zsToBlast) '];']);
mssend(SISocket,['hSI.hFastZ.numVolumes = [' num2str(numVol) '];']);
mssend(SISocket,'hSI.hFastZ.enable = 1 ;');

mssend(SISocket,'hSI.hBeams.pzAdjust = 0;');
mssend(SISocket,'hSI.hBeams.powers = 14;'); %power on SI laser. important no to use too much don't want to bleach

mssend(SISocket,'hSI.extTrigEnable = 0;'); %savign
mssend(SISocket,'hSI.hChannels.loggingEnable = 1;'); %savign
mssend(SISocket,'hSI.hScan2D.logFilePath = ''E:\Calib\Temp'';');
% mssend(SISocket,'hSI.hScan2D.logFileCounter = 1;');
mssend(SISocket,['hSI.hScan2D.logFileStem = ' baseName ';']);
mssend(SISocket,'hSI.hScan2D.logFileCounter = 1;');


% mssend(SISocket,'1+2');

mssend(SISocket,['hSICtl.updateView;']);

%clear invar
invar = msrecv(SISocket,0.01);
while ~isempty(invar)
    invar = msrecv(SISocket,0.01);
end

mssend(SISocket,'30+7');
invar=[];
while ~strcmp(num2str(invar),'37')
    invar = msrecv(SISocket,0.01);
end
disp('completed parameter set')

%%Burn

%AcquireBaseline
disp('Acquire Baseline')

mssend(SISocket,'hSI.startGrab()');
%clear invar
invar = msrecv(SISocket,0.01);
while ~isempty(invar)
    invar = msrecv(SISocket,0.01);
end
wait = 1;
while wait
    mssend(SISocket,'hSI.acqState;');
    invar = msrecv(SISocket,0.01);
    while isempty(invar)
        invar = msrecv(SISocket,0.01);
    end

    if strcmp(invar,'idle')
        wait=0;
        disp(['Ready for Next'])
    else
        %             disp(invar)
    end
end


disp('Now Burning')

for k=1:numel(zsToBlast)

    offset = round(meanCamZ(k));
    currentPosition = getPosition(Sutter.obj);
    position = Sutter.Reference;
    position(3) = position(3) + (offset);
    diff = currentPosition(3)-position(3);
    %           tic;
    moveTime=moveTo(Sutter.obj,position);
    %           toc;
    if k==1
        pause(1)
    else
        pause(0.1);
    end

    tempHololist=holos{k};

    for i=1:size(XYuse,2)
        t=tic;
        fprintf(['Blasting Hole ' num2str(i) '. Depth ' num2str(zsToBlast(k))]);
        Function_Feed_SLM( Setup.SLM, tempHololist(:,:,i));

        DE = Diffraction{k}(i);

        blastPower = pwr*5 /1000 /DE;

        if blastPower>2 %cap for errors, now using a high divided mode so might be high
            blastPower =2;
        end

        stimT=tic;
        mssend(masterSocket,[blastPower 1 1]);
        while toc(stimT)<0.5
        end
        mssend(masterSocket,[0 1 1]);


        mssend(SISocket,'hSI.startGrab()');
        invar = msrecv(SISocket,0.01);
        while ~isempty(invar)
            invar = msrecv(SISocket,0.01);
        end

        wait = 1;
        while wait
            mssend(SISocket,'hSI.acqState');
            invar = msrecv(SISocket,0.01);
            while isempty(invar)
                invar = msrecv(SISocket,0.01);
            end

            if strcmp(invar,'idle')
                wait=0;
                %             disp(['Ready for Next'])
            else
                %             disp(invar)
            end
        end
        disp([' Took ' num2str(toc(t)) 's'])
    end



end

position = Sutter.Reference;
moveTime=moveTo(Sutter.obj,position);

burnT = toc(tBurn);
disp(['Done Burning. Took ' num2str(burnT) 's']);

disp('Done with Lasers and ScanImage now, you can turn it off')

%% Move file to modulation

disp('Moving files')
tMov = tic;

%on ScanImage Computer
destination = '''X:\frankenshare\FrankenscopeCalib''' ;
source = '''E:\Calib\Temp\calib*''';

%clear invar
invar = msrecv(SISocket,0.01);
while ~isempty(invar)
    invar = msrecv(SISocket,0.01);
end


mssend(SISocket,['movefile(' source ',' destination ')']);
invar = msrecv(SISocket,0.01);
while isempty(invar)
    invar = msrecv(SISocket,0.01);
end
disp(['Moved. Took ' num2str(toc(tMov)) 's']);
MovT= toc(tMov);


%% read/compute frame


%%
mssend(SISocket,'end');
%%

tLoad = tic;
pth = 'Z:\frankenshare\FrankenscopeCalib'; %On this computer
files = dir(pth);

baseN = eval(baseName);

[dummy fr] = bigread3(fullfile(pth,files(3).name) );

nOpto = numel(zsToBlast);
nBurnHoles = size(XYuse,2);

baseFr = mean(fr(:,:,1:nOpto:end),3);%mean(fr(:,:,1:nOpto:end),3);%Probably more accurate to just do correct zoom, but sometimes having difficulty

k=1;c=0; SIXYZ =[];
for i=4:numel(files)
    t = tic;
    fprintf(['Loading/Processing Frame ' num2str(i)]);
    try
        [dummy fr] = bigread3(fullfile(pth,files(i).name) );
        if c>=nBurnHoles
            k=k+1;
            c=0;
        end
        c=c+1;

        Frame = mean(fr(:,:,:),3);%mean(fr(:,:,k:nOpto:end),3); %Probably more accurate to just do correct zoom, but sometimes having difficulty
        Frames{k}(:,:,c) = Frame;

        if c>1
            testFr = Frames{k}(:,:,c-1) - Frame;
            [ x,y ] =function_findcenter(testFr );
        else
            x = 0;
            y=0;
        end
    catch
        fprintf('\nError in Hole analysis... probably loading.')
        x = 0;
        y=0;
    end


    SIXYZ(:,end+1) = [x,y,zsToBlast(k)];
    disp([' Took ' num2str(toc(t)) ' s']);
end

SIXYZbackup=SIXYZ;
disp(['Done Loading/Processing SI files. Took ' num2str(toc(tLoad)) 's'])
loadT = toc(tLoad);

%%

modelterms =[0 0 0; 1 0 0; 0 1 0; 0 0 1;...
    1 1 0; 1 0 1; 0 1 1; 1 1 1; 2 0 0; 0 2 0; 0 0 2;];%...

%
%     2 0 1; 2 1 0; 0 2 1; 0 1 2; 1 2 0; 1 0 2;...
%     2 2 0; 2 0 2; 0 2 2; 2 1 1; 1 2 1; 1 1 2; ];  %XY spatial calibration model for Power interpolations


cam3XYZ = [XYtarg{:};];
SIXYZ = SIXYZbackup;

cam3XYZ=cam3XYZ(:,1:size(SIXYZ,2));

excl = SIXYZ(1,:)==0;
cam3XYZ(:,excl)=[];
SIXYZ(:,excl)=[];

% testSet = randperm(size(SIXYZ,2),25);
% otherSet = ones([size(SIXYZ,2) 1]);
% otherSet(testSet)=0;
% otherSet = logical(otherSet);

refAsk = SIXYZ(1:3,:)';
refGet = (cam3XYZ(1:3,:))';
errScalar =2.5;

[SItoCam, trialN] = function_3DCoCIterative(refAsk,refGet,modelterms,errScalar,1);

[CamToSI, trialN] = function_3DCoCIterative(refGet,refAsk,modelterms,errScalar,1);

CoC.CamToSI = CamToSI;
CoC.SItoCam = SItoCam;
out.CoC=CoC;

%% alternate calculation
% modelterms =[0 0 0; 1 0 0; 0 1 0; 0 0 1;...
%     1 1 0; 1 0 1; 0 1 1; 1 1 1; 2 0 0; 0 2 0; 0 0 2;...
%     2 0 1; 2 1 0; 0 2 1; 0 1 2; 1 2 0; 1 0 2;...
%     2 2 0; 2 0 2; 0 2 2; 2 1 1; 1 2 1; 1 1 2; ];  %XY spatial calibration model for Power interpolations

tempSLM = cellfun(@(x) x',SLMtarg,'UniformOutput',false);
slm3XYZ = [tempSLM{:}];
SIXYZ = SIXYZbackup;

slm3XYZ=slm3XYZ(1:3,1:size(SIXYZ,2));

excl = SIXYZ(1,:)==0;
slm3XYZ(:,excl)=[];
SIXYZ(:,excl)=[];

refAsk = SIXYZ(1:3,:)';
refGet = (slm3XYZ(1:3,:))';
errScalar =2.5;

[SItoSLM, trialN] = function_3DCoCIterative(refAsk,refGet,modelterms,errScalar,1);
[SLMtoSI, trialN] = function_3DCoCIterative(refGet,refAsk,modelterms,errScalar,1);

CoC.SItoSLM = SItoSLM;
CoC.SLMtoSI = SLMtoSI;
%% Display the Hologram quality by depth
for i =1:size(fineVals,2)
    if ~isnan(fineVals(:,i))
                    fTemp = fit(fineZs(:,i), fineVals(:,i), 'gauss1');

                    depth(i) = fTemp.b1;
                    FWHM(i) = 2.3548 *fTemp.c1/sqrt(2);% 2*sqrt(2*log(2))*fTemp.c1;
                    disp([num2str(i) ': FWHM: ' num2str(FWHM(i))]);
    else
       depth(i)=nan;
       FWHM(i)=nan;
    end
end

%%
figure(1001); clf
subplot(1,2,1);
plot(FWHM,depth,'o')
% plot(FWHM,slmCoords(3,:),'o')

ylabel('Axial Depth \mum')
xlabel('FWHM \mum')
ylim([-50 200])
xlim([10 35])

refline(0,0)
refline(0,100)


subplot(1,2,2);
scatter3(slmCoords(1,:),slmCoords(2,:),slmCoords(3,:),[],FWHM,'filled')
caxis([15 40])
h= colorbar;
xlabel('SLM X')
ylabel('SLM Y')
zlabel('SLM Z')
set(get(h,'label'),'string','FWHM \mum')
%% Calculate round trip errors
numTest = 10000;

rangeX = [0 511];%[0 511];
rangeY = [0 511];%[0 511];
rangeZ = [0 90];

clear test;
valX = round((rangeX(2)-rangeX(1)).*rand(numTest,1)+rangeX(1));
valY = round((rangeY(2)-rangeY(1)).*rand(numTest,1)+rangeY(1));
valZ = round((rangeZ(2)-rangeZ(1)).*rand(numTest,1)+rangeZ(1));

test = [valX valY valZ];
%%display
test2 = function_SLMtoSI(function_SItoSLM(test,CoC),CoC);
ER1xy = test2(:,1:2)-test(:,1:2);
RMSE1xy = sqrt(sum(ER1xy'.^2));

SIpxPerMu = 512/800;

ER1z = test2(:,3)-test(:,3);
RMSE1z = abs(ER1z);

meanE1rxy = mean(RMSE1xy);
meanE1rz = mean(RMSE1z);

figure(12);clf
subplot(3,2,1)
histogram(RMSE1xy/SIpxPerMu,0:0.1:12)
xlim([0 12])
xlabel('XY Error \mum')
title({'4 Step CoC'; ['Mean RMS err: ' num2str(meanE1rxy) '\mum']})

subplot(3,2,2)
histogram(RMSE1z,0:0.1:12)
xlim([0 12])
xlabel('Z Error optoTuneUnits')
title(['Mean RMS err: ' num2str(meanE1rz) ' optotune Units'])

estSLM = function_Eval3DCoC(CoC.SItoSLM,test);
test2 = function_Eval3DCoC(CoC.SLMtoSI,estSLM);
ER2xy = test2(:,1:2)-test(:,1:2);
RMSE2xy = sqrt(sum(ER2xy'.^2));

SIpxPerMu = 512/800;

ER2z = test2(:,3)-test(:,3);
RMSE2z = abs(ER2z);
meanE2rxy = mean(RMSE2xy);
meanE2rz = mean(RMSE2z);

subplot(3,2,3)
histogram(RMSE2xy/SIpxPerMu,0:0.1:12)
xlim([0 12])
xlabel('XY Error \mum')
title({'1 Step CoC'; ['Mean RMS err: ' num2str(meanE2rxy) '\mum']})

subplot(3,2,4)
histogram(RMSE2z,0:0.1:12)
xlim([0 12])
xlabel('Z Error optoTuneUnits')
title(['Mean RMS err: ' num2str(meanE2rz) ' optotune Units'])


estSLM = function_Eval3DCoC(CoC.SItoSLM,test);
estSIasym = function_SLMtoSI(estSLM,CoC);

ERA = estSIasym-test;
RMSErAxy = sqrt(sum(ERA(:,1:2)'.^2));
RMSErAz = abs(ERA(:,3));


subplot(3,2,5)
histogram(RMSErAxy,0:0.1:12)
xlim([0 12])
xlabel('XY Error \mum')

meanE3rxy = mean(RMSErAxy);
meanE3rz = mean(RMSErAz);
title({'Asymetric CoC'; ['Mean RMS err: ' num2str(meanE3rxy) '\mum']})

subplot(3,2,6)
histogram(RMSErAz,0:0.1:12)
xlim([0 12])
xlabel('Z Error optoTuneUnits')
title(['Mean RMS err: ' num2str(meanE3rz) ' optotune Units'])
%%Plot scatter
N=10000;


figure(13);clf
subplot(1,2,1)
val=RMSErAxy;
scatter3(test(1:N,1),test(1:N,2),test(1:N,3),[],val(1:N),'filled')
xlabel('SI X')
ylabel('SI Y')
zlabel('Opto Depth')
caxis([0 15])
colorbar
title('Simulated XY error, both methods')

subplot(1,2,2)
val=RMSErAz;
scatter3(test(1:N,1),test(1:N,2),test(1:N,3),[],val(1:N),'filled')
xlabel('SI X')
ylabel('SI Y')
zlabel('Opto Depth')
caxis([0 15])
colorbar
title('Simulated Z error, both methods')



%% Save Output Function
pathToUse = 'C:\Users\Holography\Desktop\SLM_Management\Calib_Data';
disp('Saving...')
tSave = tic;

save(fullfile(pathToUse,[date '_Calib.mat']),'CoC')
save(fullfile(pathToUse,'ActiveCalib.mat'),'CoC')



times.saveT = toc(tSave);
times.loadT = loadT;
times.MovT = MovT;
times.burnT = burnT;
times.compileBurnT = compileBurnT;
times.fitsT = fitsT;
times.fineT = fineT;
times.coarseT = coarseT;
times.siT = siT;
times.singleCompileT = singleCompileT;
% times.multiCompileT = multiCompileT;

totT = toc(tBegin);
times.totT = totT;
save(fullfile(pathToUse,'CalibWorkspace.mat'));
disp(['Saving took ' num2str(toc(tSave)) 's']);

disp(['All Done, total time from begining was ' num2str(toc(tBegin)) 's. Bye!']);

%% use this to run
%[SLMXYZP] = function_SItoSLM(SIXYZ,CoC);




[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );

try; function_close_sutter( Sutter ); end
try function_stopBasCam(Setup); end
