clear all;
close all;
clc;

[Setup ] = function_loadparameters();
Setup.CGHMethod = 1; %Overwrite to force GS

% Arrays for image data
Coordinates = 0.4*rand(10,4)+0.3;
Coordinates(:,4) = [1 1 1 1 1 2 2 2 2 2];
Coordinates(:,3) = floor(1*Coordinates(:,3));
[ HologramA,Reconstruction,Masks ] = function_Make_3D_SHOT_Holos( Setup,Coordinates );
Coordinates = 0.4*rand(10,4)+0.3;
Coordinates(:,4) = [1 1 1 1 1 2 2 2 2 2];
Coordinates(:,3) = floor(1*Coordinates(:,3));
[ HologramB,Reconstruction,Masks ] = function_Make_3D_SHOT_Holos( Setup,Coordinates );

f = figure(1);
subplot(1,2,1); imagesc(HologramA); axis image;
subplot(1,2,2); imagesc(HologramB); axis image;
pause(2);close(f);

Setup.SLM.wait_For_Trigger= 0; 
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
   
    % Loop between our ramp images
     tic
    for p = 1:1000
        [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, HologramA);   
        %pause(0.3);
        [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, HologramB);   
        %pause(0.3);
    end
    toc
    
    tic
    for p = 1:20
        [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, HologramA);    
        [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, HologramB);       
    end
    toc
    
    
 [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );