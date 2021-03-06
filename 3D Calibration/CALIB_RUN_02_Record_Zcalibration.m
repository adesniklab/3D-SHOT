try; function_close_sutter( Sutter ); end
clear all;close all;clc;

% Ministack is a ssmall stack around estimated target to refine data
nnz = 20;                       %Number of z steps PER ministack
UZ = linspace(-45,45,nnz);      %locations in microns for ministacks
skips = 4;                      %If you don't want to do all manual pts skip them and do n by n

disp('Start with zeroing the imaging plane, show focus please')
[Setup ] = function_loadparameters();
load([Setup.Datapath '\01_Z_Calibration_Holograms.mat']);

%Initialize sutter mechanical stage
[ Sutter ] = function_Sutter_Start( Setup );
%Preview substage camera
function_Basler_Preview(Setup, 5);

Sutter.Reference = getPosition(Sutter.obj);
smallUZ = linspace(-30,30,15);
dataUZ = zeros(size(smallUZ)); %linspace(-30,30,15); edited 2018 02 27
for i = 1:15
    position = Sutter.Reference;
    position(3) = position(3) + (smallUZ(i));
    moveTime=moveTo(Sutter.obj,position);
    pause(0.1);
    dummydata =  double(function_Basler_get_frames(Setup, 1 ));
    dataUZ(i) = sum(sum((dummydata)));
end
dataUZ=dataUZ-min(dataUZ);
ff = fit(smallUZ', dataUZ', 'gauss1');
position = Sutter.Reference;
position(3) = position(3) + ff.b1;
moveTime=moveTo(Sutter.obj,position);
Sutter.Reference = getPosition(Sutter.obj);
f = figure(1);
plot(smallUZ,dataUZ); hold on; plot(ff);  xlabel('Z \mum');
title(['new reference z = ' num2str(ff.b1) '\mu m']);
pause(2);
% Check you see a bell curve
% The purpose of this code is to make sure 0 is defined as the default
% depth for two photon imaging by lookign at the maximum fluorescence level
close(f);


% at this point in the code, zero is finely defined as the focal level for
% scanimage (focus mode)

disp(['ok, I think this is SLM to true....we will show ' num2str(numel(sequences{1}))]);
disp([' holograms and ask you to focus on the spot; it will auto read z position and do fine steps to localize true z centroid'])
disp('it will be helpful to be in divided mode so spot doesnt saturate');
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
CalibZ.ManualZ = linspace(0,0,CalibZ.N);
for i = 1:skips:CalibZ.N
    %Display the hologram
    [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequences{1}{i});  pause(0.02);
    %run preview
    function_Basler_Preview(Setup, 5);
    %Update with masured view
    xyz_um=getPosition(Sutter.obj)-Sutter.Reference;
    CalibZ.ManualZ(i) = xyz_um(3);
end
select = 1:skips:CalibZ.N;

f = figure(1)
scatter(CalibZ.ManualZ(select),CalibZ.Z(select),'blue','filled'); hold on;
CalibZ.ManualZ = interp1(CalibZ.Z(select),CalibZ.ManualZ(select),CalibZ.Z,'Linear','extrap');
scatter(CalibZ.ManualZ,CalibZ.Z,'red');
xlabel('Z [\mum]');
ylabel('Z [SLM coordinates]');
legend({'Manual recorded data' 'Extrapoolation'});
saveas(f, [Setup.Displaypath '\02_Z_Calibration.fig']);
waitforbuttonpress;
close(f)

x = input('Turn off all lasers to acquire baseline, then press enter...');
bl = function_Basler_get_frames(Setup, 10);
bl = mean(bl(:));
x = input('Done, Turn on stim laser, and hit enter to begin...');
[LX, LY ] = size(double(function_Basler_get_frames(Setup, 1 )));

position = Sutter.Reference;
position(3) = position(3) + CalibZ.ManualZ(1);
[ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequences{1}{1});  pause(0.12);
moveTime=moveTo(Sutter.obj,position); pause(0.1);
Refined.zeroImage =  double(function_Basler_get_frames(Setup, 1 ));
position(1) = position(1) + 50;
moveTime=moveTo(Sutter.obj,position); pause(0.1);
Refined.fiftymicronsImage =  double(function_Basler_get_frames(Setup, 1 ));
Refined.zeroImage = imgaussfilt(Refined.zeroImage,2);
Refined.fiftymicronsImage = imgaussfilt(Refined.fiftymicronsImage,2);
f = figure(1);
[ x,y ] =function_findcenter(Refined.zeroImage );
[ xx,yy ] =function_findcenter(Refined.fiftymicronsImage );
subplot(1,2,1); imagesc(Refined.zeroImage); hold on; scatter(y,x,'red')
subplot(1,2,2); imagesc(Refined.fiftymicronsImage); hold on; scatter(yy,xx,'red')
pause(1);
close(f);
Refined.micronsperpixel = 50/sqrt((yy-y)^2+(xx-x)^2);
%The purpose of this intermediate step is to measure the true dimensions of
%the data measured by the substage camera by recording two pictures with a
%50 micron displacement. The conversion data is in microns per pixel.


CalibZ.TrueZ = linspace(0,0,CalibZ.N);
for i = 1:CalibZ.N
    %      position = Sutter.Reference;
    %      position(3) = position(3) + CalibZ.ManualZ(i) + UZ(1);
    %      moveTime=moveTo(Sutter.obj,position);
    pause(0.1)
    [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequences{1}{i});  pause(0.02);
    pause(0.1)
    %     dummydata =  double(function_Basler_get_frames(Setup, 1 ));
    Imagedata = zeros(LX,LY,nnz);
    for j = 1:nnz
        position = Sutter.Reference;
        position(3) = position(3) + CalibZ.ManualZ(i) + UZ(j);
        moveTime=moveTo(Sutter.obj,position);
        if j == 1; pause(0.5) ; else pause(0.1); end;
        Imagedata(:,:,j) =  double(function_Basler_get_frames(Setup, 1 )-bl); %subtract baseline from each frame
    end
    
    imageaverage = (sum(Imagedata,3));
    %Refined.imageaverage{i} = imageaverage;
    [CX,CY] = function_findcenter(imageaverage);
    Refined.minivec{i} = Imagedata((CX-40):(CX+40), (CY-40):(CY+40),:);
    f = figure(1);clf
    subplot(1,2,1);
    imagesc((sum(Refined.minivec{i},3))); axis image; title(['Depth number : ' int2str(i)])
    mminivec = squeeze(sum(sum(Refined.minivec{i},1),2));
    subplot(1,2,2);
    plot(UZ,mminivec); xlabel('\mu m');pause(0.1);
    Refined.vectors{i} = mminivec;
    Refined.truedepths{i} = CalibZ.ManualZ(i)+UZ;
    hold on;
    ff = fit(UZ', mminivec, 'gauss1');
    plot(ff);
    title(['FWHM = ' num2str(ff.c1*Refined.micronsperpixel)]);
    hold off;
    legend('off')
end

position = Sutter.Reference; moveTime=moveTo(Sutter.obj,position);
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
function_close_sutter( Sutter );

Refined.SLMZ = CalibZ.Z;
Refined.TrueZ = zeros(size(CalibZ.Z));%CalibZ.Z-CalibZ.Z;
Refined.FWHMZ = zeros(size(CalibZ.Z));%CalibZ.Z-CalibZ.Z;
Refined.FWHMX = zeros(size(CalibZ.Z));%CalibZ.Z-CalibZ.Z;
Refined.FWHMY = zeros(size(CalibZ.Z));%CalibZ.Z-CalibZ.Z;


for i = 1:CalibZ.N
    stack = Refined.minivec{i};
    [LX,LY,LZ] = size(stack);
    for j = 1:LZ
        stack(:,:,j) = imgaussfilt(stack(:,:,j),2);
    end
    Refined.vectors{i}= squeeze(max(max(stack,[],1),[],2));
    f = fit(Refined.truedepths{i}', Refined.vectors{i}-min(Refined.vectors{i}), 'gauss1');
    Refined.TrueZ(i) = f.b1;
    Refined.FWHMZ(i) = 2*sqrt(log(2))*f.c1;
    f = fit(Refined.micronsperpixel*(1:LX)', max(max(stack,[],1),[],3)', 'gauss1');
    Refined.FWHMX(i) = 2*sqrt(log(2))*f.c1;
    f = fit(Refined.micronsperpixel*(1:LY)', max(max(stack,[],2),[],3), 'gauss1');
    Refined.FWHMY(i) = 2*sqrt(log(2))*f.c1;
end


COC.Polynomial.Z = [0; 1 ;2;3];             %Z spatial calibration model for C_Of_C between Optotune and true space
COC.Z_TRUE_SLM = polyfitn(Refined.TrueZ,Refined.SLMZ',COC.Polynomial.Z);
COC.Z_SLM_TRUE = polyfitn(Refined.SLMZ,Refined.TrueZ',COC.Polynomial.Z);
Guess.SLMFromUtrue = polyvaln(COC.Z_TRUE_SLM ,Refined.TrueZ);

%colors = [1:CalibZ.N;linspace(0,0,CalibZ.N);linspace(0,0,CalibZ.N)]'; colors =colors /max(colors(:));
colors = rand(CalibZ.N,3);


f = figure(1);
subplot(2,3,1)
scatter(Refined.TrueZ,Refined.FWHMX,[],colors,'filled');
xlabel('True Z [\mum]');
ylabel('FWHM X [\mum]');
axis([min(Refined.TrueZ) max(Refined.TrueZ) 0 30])
subplot(2,3,2)
scatter(Refined.TrueZ,Refined.FWHMY,[],colors,'filled');
xlabel('True Z [\mum]');
ylabel('FWHM Y [\mum]');
axis([min(Refined.TrueZ) max(Refined.TrueZ) 0 30])
subplot(2,3,3)
scatter(Refined.TrueZ,Refined.FWHMZ,[],colors,'filled');
xlabel('True Z [\mum]');
ylabel('FWHM Z [\mum]');
axis([min(Refined.TrueZ) max(Refined.TrueZ) 0 40])
subplot(2,3,4)
scatter(Refined.TrueZ,Refined.SLMZ,[],colors,'filled'); hold on
scatter(Refined.TrueZ,Guess.SLMFromUtrue,'red'); hold on
xlabel('True Z [\mum]');
ylabel('SLM Z [A.U.]');

subplot(2,3,[5 6])
for i = 1:CalibZ.N
    plot(Refined.truedepths{i}, Refined.vectors{i}, 'color', colors(i,:)); hold on
end
xlabel('True Z [\mu m]');
ylabel('Intenaity [A.U.]');
title('SLM - TRUE Z Calibration')
saveas(f,[Setup.Displaypath '\02_SLM_True_Z_Calibration.fig'])

save([Setup.Datapath '\02_Z_Calibration_Data.mat'],'Refined','COC')
