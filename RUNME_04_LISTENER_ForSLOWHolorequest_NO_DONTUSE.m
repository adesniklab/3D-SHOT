clear all; close all; clc;
[Setup ] = function_loadparameters(1);
Setup.CGHMethod=1;

cycleiterations =1; % Change this number to repeat the sequence N times instead of just once

%Overwrite delay duration
Setup.TimeToPickSequence = 0.2;    %2 second window to select sequence ID
Setup.SLM.timeout_ms = 2000;     %No more than 2000 ms until time out
calibID = 1;                     % Select the calibration ID (change for another zoom if needed)

try
load([Setup.Datapath '\07_XYZ_Calibration.mat']);
catch
    disp('Missing Spatial calibration file')
end

try
load([Setup.Holorequestpath 'ROIData.mat']);
catch
    disp('ROIData file')
end

LN = numel(ROIdata.rois);
SICoordinates = zeros(3,LN);
for i = 1:LN
u = mean(ROIdata.rois(i).vertices);
SICoordinates(1:2,i) = u;
SICoordinates(3,i) = ROIdata.rois(i).OptotuneDepth;
end
SLMCoordinates = zeros(4,LN);
%Convert ot SLM coordinates
SLMCoordinates(1,:) = polyvaln(COC.SI_SLM_X{calibID} ,SICoordinates');
SLMCoordinates(2,:) = polyvaln(COC.SI_SLM_Y{calibID} ,SICoordinates');
SLMCoordinates(3,:) = polyvaln(COC.SI_SLM_Z{calibID} ,SICoordinates');
%Add power
SLMCoordinates(4,:) = 1./function_Power_Adjust( SLMCoordinates(1:3,:)', COC );

AttenuationCoeffs = function_Power_Adjust( SLMCoordinates(1:3,:)', COC );

f = figure(1);
subplot(1,2,1)
scatter3(SICoordinates(1,:),SICoordinates(2,:),SICoordinates(3,:),[],SLMCoordinates(4,:),'filled'); colorbar;
xlabel('X, SI coordinates');ylabel('Y, SI coordinates'); zlabel('Z, SI coordinates'); title('Intensity Correction coefficients');
subplot(1,2,2)
scatter3(SLMCoordinates(1,:),SLMCoordinates(2,:),SLMCoordinates(3,:),[],SLMCoordinates(4,:),'filled'); colorbar;
xlabel('X, SLM coordinates');ylabel('Y, SLM coordinates'); zlabel('Z, SLM coordinates'); title('Intensity Correction coefficients');
pause(1); close(f);

load([Setup.Holorequestpath 'HoloRequest.mat']);
Setup.verbose =0;
hololist = zeros(Setup.Nx,Setup.Ny, numel(holoRequest.rois),'uint8');
DE = linspace(0,0,numel(holoRequest.rois));
for j = 1:numel(holoRequest.rois)
    disp(['Now compiling hologram ' int2str(j) ' of ' int2str(numel(holoRequest.rois))])
    ROIselection = holoRequest.rois{j};
    myattenuation = AttenuationCoeffs(ROIselection);
    energy = 1./myattenuation; energy = energy/sum(energy);
    DE(j) = sum(energy.*myattenuation);
    disp(['Diffraction efficiency of the hologram : ' int2str(100*DE(j)) '%']);
    subcoordinates = SLMCoordinates(:,ROIselection);
    [ Hologram,Reconstruction,Masksg ] = function_Make_3D_SHOT_Holos( Setup,subcoordinates' );
    hololist(:,:,j) = Hologram;
% compile holograms    
end

LSequences = numel(holoRequest.Sequence);
sequences = {};

for i = 1:LSequences
    sequence = {};
    
    for iterations = 1:cycleiterations
    for j = 1:numel(holoRequest.Sequence{i})
        sequence{(iterations-1)*numel(holoRequest.Sequence{i})+j} =  squeeze(hololist(:,:,holoRequest.Sequence{i}(j)));
    end
    end
    sequences{i} = sequence;
end


[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
Function_shoot_slow_sequences(Setup,sequences);
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );

disp('Update Holorequest or ROIS and relaunch, otherwise, see you next time !')







       
