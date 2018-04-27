clear all;close all;clc;

[Setup ] = function_loadparameters(); %Includes NIDAQ starting step
Setup.verbose=0;
load([Setup.Datapath '\04_All_Z_Calibration_Data.mat']);

RX = 0.40;
Discretize = 300;
numberOfPoints = 50;
filename = '_200targets_NO_Scat_variE';


Cloud.X =  linspace(0.5-RX,0.5+RX,Discretize );
Cloud.Y =  linspace(0.5-RX,0.5+RX,Discretize );
Cloud.Z =  linspace(0.04,-0.075,Discretize );
x = rand(1, 2*numberOfPoints);
y = rand(1, 2*numberOfPoints);
z = rand(1, 2*numberOfPoints);
minAllowableDistance = 0.05;
% Initialize first point.
keeperX = x(1);
keeperY = y(1);
keeperZ = y(1);
% Try dropping down more points.
counter = 2;
for k = 2 : 2*numberOfPoints
	% Get a trial point.
	thisX = x(k);
	thisY = y(k);
    thisZ = z(k);
	% See how far is is away from existing keeper points.
	distances = sqrt((thisX-keeperX).^2 + (thisY - keeperY).^2 + (thisZ - keeperZ).^2);
	minDistance = min(distances);
	if minDistance >= minAllowableDistance
		keeperX(counter) = thisX;
		keeperY(counter) = thisY;
   		keeperZ(counter) = thisZ;
		counter = counter + 1;
	end
end

keeperX = Cloud.X(floor(( Discretize-1)*keeperX(1:numberOfPoints))+1);
keeperY = Cloud.Y(floor(( Discretize-1)*keeperY(1:numberOfPoints))+1);
keeperZ = Cloud.Z(floor(( Discretize-1)*keeperZ(1:numberOfPoints))+1);

[ Corcoeffguess ] = function_Power_Adjust( [keeperX;keeperY;keeperZ]', COC ); 

scatter3(keeperX, keeperY, keeperZ, [],1./Corcoeffguess,'filled');
grid on;


Setup.CGHMethod = 1; %Use superposition for these holgorams
Setup.verbose = 1;
Hologram  = function_Make_3D_SHOT_Holos(Setup,[keeperX;keeperY;keeperZ;1./Corcoeffguess']');
Data.points = [keeperX;keeperY;keeperZ;1./Corcoeffguess']';
[ Sutter ] = function_Sutter_Start( Setup );
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
[ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, Hologram,0);   
pause(0.1);

disp('find zero for two photon imaging then turn on laser');
%Rezero scanimage focus reference
function_Basler_Preview(Setup, 5);
Sutter.Reference = getPosition(Sutter.obj);

Data.UZ = linspace(-50,250,300);
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
input('Turn off laser power to avoid urning your zero order')

[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
function_close_sutter( Sutter );
