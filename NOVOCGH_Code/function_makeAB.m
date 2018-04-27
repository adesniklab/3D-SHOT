function [ Hologram,Reconstruction] = function_makeAB( locations, Setup )
Depths = locations(:,3);
NZ = numel(Depths);
Masks = zeros(Setup.SLM.Nx,Setup.SLM.Ny,NZ);
[UX,UY] = ndgrid(linspace(0,1,Setup.SLM.Nx), linspace(0,1,Setup.SLM.Ny));
for i = 1:NZ
    distmap = (UX-locations(i,1)).^2+(UY-locations(i,2)).^2;
    themask = double(distmap<=locations(i,4));
    if sum(themask(:))== 0; themask = double(distmap == min(distmap(:)));end;
    Masks(:,:,i) = themask;
end

if Setup.useGPU ==1
    Masks = gpuArray(Masks);
end;
[ HStacks ] = function_Hstacks( Setup,Depths );
%%%%% COMPUTE HOLOGRAMS FROM MASKS HERE
if Setup.CGHMethod == 1 % Case Superposition
    [Holo] = function_Superposition( Setup, HStacks, Masks );
elseif  Setup.CGHMethod == 2 % Case Global GS
    [Holo] = function_globalGS(Setup, HStacks, Masks );
elseif  Setup.CGHMethod == 3 % NovoCGH
    [Holo] = function_NOVO_CGH_VarIEuclid( Setup, HStacks, Masks,Depths );
elseif  Setup.CGHMethod == 4 % Two photon NOVO CGH
    [Holo] = function_NOVO_CGH_TPEuclid( Setup, HStacks, sqrt(Masks),Depths );
elseif  Setup.CGHMethod == 5 % Case Global GS
[Holo] = function_sequentialGS(Setup, HStacks, Masks );
else
    disp('There is no such CGH method')
end
%%%%%%%%% CLEAN UP
Hologram = uint8(floor((Setup.SLM.pixelmax*(Holo.phase+pi)/(2*pi))));
%f = figure(1); imagesc(Hologram); axis image; pause(2); close(f)
[ Reconstruction ] = function_VolumeIntensity( Setup,Holo.phase,HStacks);


end

