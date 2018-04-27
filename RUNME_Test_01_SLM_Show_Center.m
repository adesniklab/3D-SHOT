try
     [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
end

clear all;
close all;
clc;

[Setup ] = function_loadparameters(2);
Setup.CGHMethod = 1; %Overwrite to force GS

% Arrays for image data
Hologram = zeros(Setup.Nx,Setup.Ny);
sizes = 200;
[UX,UY] = ndgrid(1:sizes,1:sizes);
mask = 215*mod(UX+UY,2);
cx = floor(Setup.Nx/2-sizes/2);
cy = floor(Setup.Ny/2-sizes/2);
Hologram(cx:(cx+sizes-1),cy:(cy+sizes-1)) = mask;
Hologram = uint8(Hologram);
f = figure(1);
imagesc(Hologram)


try
     [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
end
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
   
    % Loop between our ramp images
        [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, Hologram);   
        pause(0.1);
    input('Done ?');
    
 [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );