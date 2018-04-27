try;function_close_sutter( Sutter );catch;end;
try; [Setup.SLM ] = Function_Stop_SLM( Setup.SLM ); end;

clear all;close all;clc;
[Setup ] = function_loadparameters();
load([Setup.Datapath '\01_Power_Calibration_Holograms.mat']);
load([Setup.Datapath '\02_Z_Calibration_Data.mat']);

modelterms.POWER = [0 0 0; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1 ; 1 1 1 ; 2 0 0; 0 2 0; 0 0 2; 2 0 1; 2 1 0; 0 2 1; 0 1 2; 1 2 0; 1 0 2;   ];  %XY spatial calibration model for Power interpolations

[ Sutter ] = function_Sutter_Start( Setup );
Bgdframe =  double(function_Basler_get_frames(Setup, 1 ));
%Rezero scanimage focus reference
function_Basler_Preview(Setup, 5);
Sutter.Reference = getPosition(Sutter.obj);
smallUZ = linspace(-30,30,15);
dataUZ = linspace(-30,30,15);
for i = 1:15
    position = Sutter.Reference;
    position(3) = position(3) + (smallUZ(i));
    moveTime=moveTo(Sutter.obj,position);
    pause(0.1)
    dummydata =  max(double(function_Basler_get_frames(Setup, 1 ))-Bgdframe,0);
    dataUZ(i) = sum(sum((dummydata)));
end
ff = fit(smallUZ', dataUZ'-min(dataUZ), 'gauss1');
  position = Sutter.Reference;
    position(3) = position(3) + ff.b1;
    moveTime=moveTo(Sutter.obj,position);
    Sutter.Reference = getPosition(Sutter.obj);
f = figure(1);
plot(smallUZ,dataUZ);
title(['new reference z = ' num2str(ff.b1) '\mu m'])

%% 
disp('NOW SLM will turn on, place enough power but not too much to avoid saturation')
input('Make sure Stim laser is on internal control, and that power is divided (e.g. 2% divided 150x)')
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
TrueZ = polyvaln(COC.Z_SLM_TRUE ,PCalib.Z);
LZ = numel(TrueZ);

 f = figure(1);
for i = 1:LZ
      position = Sutter.Reference; position(3) = position(3)+TrueZ(i);
      moveTime=moveTo(Sutter.obj,position); pause(0.1); 
      
      selection = (PCalib.Z(i) == PCalib.Coordinates(:,3));
      selid = 1:(PCalib.LX*PCalib.LY*PCalib.LZ); selid = selid(selection);
     
      for ii = selid
        [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequences{1}{ii});  pause(0.02);
        frame =  double(function_Basler_get_frames(Setup, 1 ));
        frame =  max(frame-Bgdframe,0);
        frame = imgaussfilt(frame,2);
        try
        [ x,y ] =function_findcenter(frame );
        frame = frame((x-40):(x+40),(y-40):(y+40));
        PCalib.Coordinates(ii,4) = sum(frame(:));
        catch
        PCalib.Coordinates(ii,4) = 0;    
        end
        scatter3(PCalib.Coordinates(ii,1),PCalib.Coordinates(ii,2),PCalib.Coordinates(ii,3),[],PCalib.Coordinates(ii,4),'filled'); hold on; pause(0.01); colorbar;
      end
      
end
  moveTime=moveTo(Sutter.obj,Sutter.Reference); pause(0.1); 
close(f);

%normalize
PCalib.Coordinates(:,4) = PCalib.Coordinates(:,4)/max(PCalib.Coordinates(:,4));

%Rectify to intensity
PCalib.TwophotonIntensity = PCalib.Coordinates(:,4);
PCalib.Intensity = sqrt(PCalib.Coordinates(:,4));

%interpolate
COC.PowerAdjust =  polyfitn(PCalib.Coordinates(:,1:3),PCalib.Intensity ,modelterms.POWER);
[ Corcoeffguess ] = function_Power_Adjust( PCalib.Coordinates(:,1:3), COC ); 

f = figure(1);
subplot(2,2,1)
scatter3(PCalib.Coordinates(:,1),PCalib.Coordinates(:,2),PCalib.Coordinates(:,3),[],PCalib.Intensity,'filled'); hold on; pause(0.01); colorbar; caxis([0 1])
xlabel('SLM x [A.U.]');
ylabel('SLM y [A.U.]');
zlabel('SLM z [A.U.]');
title({'Recorded Light Intensity ','normalized [A.U.]'})
subplot(2,2,2)
scatter3(PCalib.Coordinates(:,1),PCalib.Coordinates(:,2),PCalib.Coordinates(:,3),[],Corcoeffguess,'filled'); hold on; pause(0.01); colorbar; caxis([0 1])
xlabel('SLM x [A.U.]');
ylabel('SLM y [A.U.]');
zlabel('SLM z [A.U.]');
title({'Interpolated Light Intensity','normalized [A.U.]'})
subplot(2,2,3)
scatter3(PCalib.Coordinates(:,1),PCalib.Coordinates(:,2),PCalib.Coordinates(:,3),[],abs(PCalib.Intensity-Corcoeffguess),'filled'); hold on; pause(0.01); colorbar; caxis([0 1])
xlabel('SLM x [A.U.]');
ylabel('SLM y [A.U.]');
zlabel('SLM z [A.U.]');
title({'Error','normalized [A.U.]'})
subplot(2,2,4)
scatter3(PCalib.Coordinates(:,1),PCalib.Coordinates(:,2),PCalib.Coordinates(:,3),[],PCalib.Coordinates(:,4),'filled'); hold on; pause(0.01); colorbar; caxis([0 1])
xlabel('SLM x [A.U.]');
ylabel('SLM y [A.U.]');
zlabel('SLM z [A.U.]');
title({'Recorded Two photon absorption','normalized [A.U.]'})
saveas(f,[Setup.Displaypath '\03_Power_Calibration.fig'])
save([Setup.Datapath '\03_Power_Calibration_Data_Interpolant.mat'],'PCalib','COC')

position = Sutter.Reference; moveTime=moveTo(Sutter.obj,position);
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
function_close_sutter( Sutter );
 