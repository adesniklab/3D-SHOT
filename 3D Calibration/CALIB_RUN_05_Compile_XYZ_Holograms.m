clear all;close all;clc;
[Setup ] = function_loadparameters();
load([Setup.Datapath '\04_All_Z_Calibration_Data.mat'])
%try; load('07_XYZ_Calibration','COC') catch; disp('I dont know where COC is'); end;

SLM.RangeX = 0.25;
SLM.RangeY = 0.3;%0.25;
SLM.XYNP = 13 ; %Number of random points in maze

Calibrations.ODepths = {[0:10:70],[0:10:70]};%{linspace(0,90,10),linspace(0,90,10)};
Calibrations.Zooms = {1,1.5};

done=0;
SLM.UXY = linspace(0.5-SLM.RangeX,0.5+SLM.RangeX,SLM.XYNP);
while done == 0;
    SLM.Map = rand(SLM.XYNP,SLM.XYNP)>0.5;
    [XX,YY] = ndgrid(1:SLM.XYNP,1:SLM.XYNP);
    SLM.XList = SLM.UXY(XX(SLM.Map));
    SLM.YList = SLM.UXY(YY(SLM.Map));
    LP = numel(SLM.XList);
    f = figure(1); scatter(SLM.XList,SLM.YList,'filled','red'); axis image; pause(0.5);
    Setup.Ncycles= 1;
    saveas(f,[Setup.Displaypath '\05_XY_SLM_Maze.fig'])
    commandwindow
    done = input('Enter 1 to continue, 0 to re-draw alignment maze');
end



for i = 1:numel(Calibrations.Zooms)
SLM.Depths.SI = Calibrations.ODepths{i};
SLM.Depths.True = polyvaln(COC.Z_SI_TRUE ,SLM.Depths.SI);
%XYZ.Depths.SLM = polyvaln(COC.Z_TRUE_SLM ,SLM.Depths.True);
SLM.Depths.SLM = polyvaln(COC.Z_SI_SLM ,SLM.Depths.SI);
LN = numel(SLM.Depths.SI);
SLM.Hologram = {};
Setup.CGHMethod = 1; %Use superposition for these holgorams
Setup.verbose = 0;
    for j = 1:LN
        disp(['Depth = ' int2str(j) ' expect :' int2str(LP) ' Pts']);
        for k = 1:LP
            fprintf([int2str(k) ' ']);
            SLM.Hologram{j,k}  = function_Make_3D_SHOT_Holos(Setup,[SLM.XList(k) ,SLM.YList(k),SLM.Depths.SLM(j) 1]);
            imagesc(SLM.Hologram{j,k} ); pause(0.01)
        end
    end
    Calibrations.SLM{i} = SLM;
end

disp('Done !')
save([Setup.Datapath '\05_XYZ_Alignment_Holograms.mat'],'Calibrations','-v7.3')
