clear all;close all;clc;

% hERE WE BUILD A LINE STREtching laong the z-axis
CalibZ.N = 25;                              %Number of points in the single axis z- calibration
CalibZ.X = linspace(0.42,0.42,CalibZ.N);    % X offset from the zero order (0.5)
CalibZ.Y = linspace(0.42,0.42,CalibZ.N);    % y offset from the zero order (0.5)
CalibZ.Z = linspace(-.05,0.07,CalibZ.N);    % 2018 02 27 changede from -0.07 to + 0.07

% This is a XYZ maze of points for power calibration
PCalib.LX = 20; %Number of points on each axis
PCalib.LY = 20;
PCalib.LZ = 20;
RX = 0.30;      % Radius of point cloud, from 0 to 0.5
RY = 0.30;

PCalib.X = linspace(0.5-RX,0.5+RX,PCalib.LX );
PCalib.Y = linspace(0.5-RY,0.5+RY,PCalib.LY );
PCalib.Z =  linspace(-.05,.07,PCalib.LZ );

[Setup ] = function_loadparameters();
sequence = {};
Setup.CGHMethod = 1; %Use superposition for these holgorams
Setup.verbose = 0;
for i = 1:CalibZ.N
    disp(['Now computing hologram depth ' int2str(i) ' of ' int2str(CalibZ.N)])
    Coordinates = [CalibZ.X(i) CalibZ.Y(i) CalibZ.Z(i) 1];
    sequence{i} = function_Make_3D_SHOT_Holos(Setup,Coordinates);
end
sequences{1} = sequence;
save([Setup.Datapath '\01_Z_Calibration_Holograms.mat'],'sequences','CalibZ')

%UNCOMMENT OUT POWER CALIBRATION HOLOGRAMS

counter = 1;
sequence = {};
for i = 1:PCalib.LX
    for j = 1:PCalib.LY
        for k = 1:PCalib.LZ
            disp(['Now computing power calib hologram # ' int2str(counter) ' of ' int2str(PCalib.LX*PCalib.LY*PCalib.LZ)])
            PCalib.Coordinates(counter,:) = [PCalib.X(i) PCalib.Y(j) PCalib.Z(k) 1];
            sequence{counter} = function_Make_3D_SHOT_Holos(Setup,PCalib.Coordinates(counter,:));
            counter = counter+1;
        end
    end
end

sequences{1} = sequence;
save([Setup.Datapath '\01_Power_Calibration_Holograms.mat'],'sequences','PCalib','-v7.3');
disp('Data saved');






