clear all
close all
clc

[Setup ] = function_loadparameters();

Coordinates = rand(500,3);
Coordinates(:,3) = floor(3*Coordinates(:,3));

[ Hologram,Reconstruction,Masks ] = function_Make_3D_SHOT_Holos( Setup,Coordinates );


f = figure(1)
for i = 1:3
subplot(3,3,i);
imagesc(squeeze(Masks(:,:,i))); title('Masks');axis image; axis off;
subplot(3,3,3+i);
imagesc(squeeze(Reconstruction(:,:,i))); title('Reconstruction'); axis image; axis off
end
