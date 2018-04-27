% Version updated for Frankenscope duty 12/16/17 ARM\
try;
    [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
end;

clear all; close all; clc;
[Setup ] = function_loadparameters(2);
Setup.CGHMethod=1;

cycleiterations =1; % Change this number to repeat the sequence N times instead of just once

%Overwrite delay duration
Setup.TimeToPickSequence = 0.05;    %second window to select sequence ID
Setup.SLM.timeout_ms = 4000;     %No more than 2000 ms until time out
calibID =2;                     % Select the calibration ID (z1=1 but does not exist, Z1.5=2, Z1 sutter =3);
%%
try
    if calibID ~=3;
        load([Setup.Datapath '\07_XYZ_Calibration.mat']);
    else
        load([Setup.Datapath '\07_XYZ_Calibration_alan.mat']);
    end
catch
    disp('Missing Spatial calibration file')
end

load([Setup.Holorequestpath 'HoloRequest.mat']);

if ~isfield(holoRequest,'ignoreROIdata')  %if we're doing things normally
    try
        load([Setup.Holorequestpath 'ROIData.mat']);
        
    catch
        disp('No ROIData file')
        return
    end
    
    
    LN = numel(ROIdata.rois);
    SICoordinates = zeros(3,LN);
    for i = 1:LN
        u = mean(ROIdata.rois(i).vertices);
        u(1)=u(1)+holoRequest.xoffset;
        u(2)=u(2)+holoRequest.yoffset;
        
        SICoordinates(1:2,i) = u;
        SICoordinates(3,i) = ROIdata.rois(i).OptotuneDepth;
    end
    SLMCoordinates = zeros(4,LN);
    
else  %if I'm doing a custom sequence
    LN = size(holoRequest.targets,1);
    SICoordinates = holoRequest.targets;
    SICoordinates(:,1)=SICoordinates(:,1)+holoRequest.xoffset;
    SICoordinates(:,2)=SICoordinates(:,2)+holoRequest.yoffset;    
    SICoordinates=SICoordinates';
    SLMCoordinates = zeros(4,LN);
end
%% Convert ot SLM coordinates
SLMCoordinates(1,:) = polyvaln(COC.SI_SLM_X{calibID} ,SICoordinates');
SLMCoordinates(2,:) = polyvaln(COC.SI_SLM_Y{calibID} ,SICoordinates');
SLMCoordinates(3,:) = polyvaln(COC.SI_SLM_Z{calibID} ,SICoordinates');

%Add power
SLMCoordinates(4,:) = 1./function_Power_Adjust( SLMCoordinates(1:3,:)',COC );

AttenuationCoeffs = function_Power_Adjust( SLMCoordinates(1:3,:)', COC );

%%%%%%%%%%%%%%%%%%%%

f = figure(1);
subplot(1,2,1)
scatter3(SICoordinates(1,:),SICoordinates(2,:),SICoordinates(3,:),[],SLMCoordinates(4,:),'filled'); colorbar;
xlabel('X, SI coordinates');ylabel('Y, SI coordinates'); zlabel('Z, SI coordinates'); title('Intensity Correction coefficients');
subplot(1,2,2)
scatter3(SLMCoordinates(1,:),SLMCoordinates(2,:),SLMCoordinates(3,:),[],SLMCoordinates(4,:),'filled'); colorbar;
xlabel('X, SLM coordinates');ylabel('Y, SLM coordinates'); zlabel('Z, SLM coordinates'); title('Intensity Correction coefficients');
pause(1); close(f);

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

DE_list=DE;
locations=FrankenScopeRigFile();
save('Y:\holography\FrankenRig\HoloRequest-DAQ\HoloRequest.mat','DE_list','-append')


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

[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
Setup.SLM.wait_For_Trigger= 1;
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
Function_shoot_sequences_due(Setup,sequences,cycleiterations);
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );

disp('Update Holorequest or ROIS and relaunch, otherwise, see you next time !')








