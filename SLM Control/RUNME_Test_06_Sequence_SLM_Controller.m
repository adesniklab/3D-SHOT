clear all;close all;clc;

[Setup ] = function_loadparameters(1); %Includes NIDAQ starting step
Setup.verbose=0;
Setup.CGHMethod = 1; %Overwrite to force GS
% Arrays for image data
[PX PY] = ndgrid(linspace(0.2,0.8,20),linspace(0.2,0.8,20));
Coordinates = [PX(:),PY(:),(PY(:)-PY(:))];

sequences = {};
for j = 1:2
    sequence = {};
    for i = 1:40
[ Hologram,Reconstruction,Masks] = function_Make_3D_SHOT_Holos( Setup,Coordinates(i,:) );        
        sequence{i} = Hologram;
    end
    sequences{j} = sequence;
end

%sequences is a list of sequences
%sequences{i} is a list of holograms to be displayed after a trigger is
%received

%Select sequence by selectin with square pulses pulses at 70 Hz, send too
%many pulses to quit





Setup.SLM.wait_For_Trigger= 1; %
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );

Function_shoot_sequences(Setup,sequences);

[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );

    

