try function_close_sutter( Sutter ); end;

clear all;close all;clc;
[Setup ] = function_loadparameters();
load([Setup.Datapath '\05_XYZ_Alignment_Holograms.mat']); pause(0.1);
sequencepick=[0:10:70];%[0 10 20 30 40 50 60 70 80 90 ];
repeats = 2;
load([Setup.Datapath '\03_Power_Calibration_Data_Interpolant.mat'])
[ Sutter ] = function_Sutter_Start( Setup );
input('Find focal plane and then hit Enter...');
Sutter.Reference = getPosition(Sutter.obj);
truesequencepick = sequencepick;
for i = 1:repeats
    disp(['Select Optotune depths : ' int2str(sequencepick) ', and scan'])
    for j = 1:numel(sequencepick)
        input(['Enter when placed at z = ' int2str(sequencepick(j))]);
        position = getPosition(Sutter.obj);
        truesequencepick(j) = position(3)-Sutter.Reference(3) ;
    end
    truedepths{i} =  truesequencepick;
    f = figure(1)
    subplot(1,2,1)
    scatter(sequencepick,truesequencepick); hold on; xlabel('Z scanimage coordinates');
    ylabel('True Z [\mum]');pause(0.1);
end

meandepths = linspace(0,0,numel(sequencepick));
for i= 1:repeats
    meandepths = meandepths+truedepths{i};
end
meandepths = meandepths/repeats;

f = figure(1)
subplot(1,2,2)
scatter(sequencepick,meandepths,'blue','filled'); hold on; pause(0.1)
xlabel('Z scanimage coordinates')
ylabel('True Z [\mum]')
COC.Polynomial.Z = [0; 1 ;2;3];             %Z spatial calibration model for C_Of_C between Optotune and true space
COC.Z_TRUE_SI = polyfitn(meandepths,sequencepick',COC.Polynomial.Z);
COC.Z_SI_TRUE = polyfitn(sequencepick,meandepths',COC.Polynomial.Z);
COC.Z_SLM_SI = polyfitn(polyvaln(COC.Z_TRUE_SLM ,meandepths),sequencepick',COC.Polynomial.Z);
COC.Z_SI_SLM = polyfitn(sequencepick,polyvaln(COC.Z_TRUE_SLM ,meandepths)',COC.Polynomial.Z);
Guess.SIFromUtrue = polyvaln(COC.Z_TRUE_SI ,meandepths);
vv = linspace(min(meandepths)-10,max(meandepths)+10,200);
ww = polyvaln(COC.Z_TRUE_SI ,vv);
vvv = linspace(min(sequencepick)-10,max(sequencepick)+10,200);
www = polyvaln(COC.Z_SI_TRUE ,vvv);
scatter(sequencepick,meandepths,'red'); hold on; pause(0.1)
plot(ww,vv); hold on; plot(vvv,www);
legend({'Measure' 'Interpolation' 'SI from true' 'True form SI'})
saveas(f,[Setup.Displaypath '\04_SI_True_Z_Calibration.fig'])
save([Setup.Datapath '\04_All_Z_Calibration_Data.mat'],'COC')
function_close_sutter( Sutter );