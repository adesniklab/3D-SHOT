clear all;close all;clc;

Data.UZ = linspace(-150,150,300);

[Setup ] = function_loadparameters(); %Includes NIDAQ starting step
Setup.verbose=0;
load([Setup.Datapath '\04_All_Z_Calibration_Data.mat']);
[ Sutter ] = function_Sutter_Start( Setup );
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
Sutter.Reference = getPosition(Sutter.obj);

RX = 0.19;
scalefactor = linspace(1,1,1);

for i = 1:numel(scalefactor)
s = scalefactor(i);
filename = ['Square_' int2str(100*s) '_'];
Cloud.X =  linspace(0.5-s*RX,0.5+s*RX,3 );
Cloud.Y =  linspace(0.5-s*RX,0.5+s*RX,3 );
Cloud.Z =  linspace(0.025,-0.025,3 );
keeperX = Cloud.X([1 1 1 1 3 3 3 3]);
keeperY = Cloud.Y([1 3 1 3 1 3 1 3]);
keeperZ = Cloud.Z([1 1 3 3 1 1 3 3]);
[ Corcoeffguess ] = function_Power_Adjust( [keeperX;keeperY;keeperZ]', COC ); 
Corcoeffguess =Corcoeffguess -Corcoeffguess +1;
%scatter3(keeperX, keeperY, keeperZ, [],1./Corcoeffguess,'filled');
%grid on;
Setup.CGHMethod = 1; %Use superposition for these holgorams
Setup.verbose = 1;
Hologram  = function_Make_3D_SHOT_Holos(Setup,[keeperX;keeperY;keeperZ;1./Corcoeffguess']');
Data.points = [keeperX;keeperY;keeperZ;1./Corcoeffguess']';

[ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, Hologram);   
pause(0.1);

disp('find zero for two photon imaging then turn on laser');
%Rezero scanimage focus reference
if i == 1
function_Basler_Preview(Setup, 5);
Sutter.Reference = getPosition(Sutter.obj);
end
 Data.Reference =  function_Basler_get_frames(Setup, 1 );
 position = Sutter.Reference;
 position(1) = position(1) + 50;
 moveTime=moveTo(Sutter.obj,position);
 pause(0.1)
 Data.FiftyMicrons =  function_Basler_get_frames(Setup, 1 );
position = Sutter.Reference;
 moveTime=moveTo(Sutter.obj,position);



  dummydata =  double(function_Basler_get_frames(Setup, 1 ));
  [LX,LY] = size(dummydata);
  stack = zeros(LX,LY,numel(Data.UZ),'uint8');

for i = 1:numel(Data.UZ)
    position = Sutter.Reference;
    position(3) = position(3) + (Data.UZ(i));
    moveTime=moveTo(Sutter.obj,position);
    pause(0.1)
    dummydata =  function_Basler_get_frames(Setup, 1 );
    stack(:,:,i) = dummydata;
end   
saveastiff(stack,[Setup.Displaypath '\' filename '.tif']) 
save([Setup.Displaypath '\' filename '_Info.mat'],'Data')
position = Sutter.Reference; moveTime=moveTo(Sutter.obj,position);
%input('Turn off laser power to avoid urning your zero order')




end

[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
function_close_sutter( Sutter );
