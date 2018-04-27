%% gets  zero order on SLM

try;
[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
end;
clear all; close all; clc;
[Setup ] = function_loadparameters(2);
Setup.CGHMethod=1;
sequences={};

cycleiterations =1; % Change this number to repeat the sequence N times instead of just once

%Overwrite delay duration
Setup.TimeToPickSequence = 0.05;    %second window to select sequence ID
Setup.SLM.timeout_ms = 2000;     %No more than 2000 ms until time out
calibID = 2;               

[Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
Setup.SLM.wait_For_Trigger= 1;
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
Function_shoot_sequences_due(Setup,sequences,cycleiterations);

disp('now run a trigger from the daq that sends next sequence, but no holograms');
disp('then press ctrl c');
%%
try; [Setup.SLM ] = Function_Stop_SLM( Setup.SLM ); end;
disp('now find zero order');
if ~exist('Setup'); [Setup ] = function_loadparameters(2); end;

function_Basler_Preview(Setup, 5);

try; function_close_sutter( Sutter ); end
[ Sutter ] = function_Sutter_Start( Setup );
Sutter.Reference = getPosition(Sutter.obj);
[LX, LY ] = size(double(function_Basler_get_frames(Setup, 1 )));

% Ministack is a ssmall stack around estimated target to refine data
nnz = 20;                       %Number of z steps PER ministack 
UZ = linspace(-45,45,nnz);     

 position = Sutter.Reference;
for i = 1;
%      position = Sutter.Reference;
%      position(3) = position(3) + CalibZ.ManualZ(i) + UZ(1);
%      moveTime=moveTo(Sutter.obj,position);
%     pause(0.1)
%     [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, sequences{1}{i});  pause(0.02);
%     pause(0.1)
%     dummydata =  double(function_Basler_get_frames(Setup, 1 ));
    Imagedata = zeros(LX,LY,nnz);
    for j = 1:nnz
        position = Sutter.Reference;
        position(3) = position(3) + UZ(j);
        moveTime=moveTo(Sutter.obj,position);
        if j == 1; pause(0.5) ; else pause(0.1); end;
        Imagedata(:,:,j) =  double(function_Basler_get_frames(Setup, 1 )); %subtract baseline from each frame
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
    plot(UZ,mminivec-min(mminivec)); xlabel('\mu m');pause(0.1); 
    Refined.vectors{i} = mminivec-min(mminivec);
    Refined.truedepths{i} = UZ;
    hold on;
    ff = fit(UZ', mminivec-min(mminivec), 'gauss1'); 
    plot(ff);
    title(['FWHM = ' num2str(ff.c1*2.355)]);
    hold off; 
    legend('off')
end

Refined.micronsperpixel=.35;

    f = fit(Refined.micronsperpixel*(1:81)', max(max(Refined.minivec{1},[],3),[],1)', 'gauss1');
    Refined.FWHMX(i) = 2*sqrt(log(2))*f.c1;
    disp(['X FWHM: ' num2str( Refined.FWHMX(i))])
    f = fit(Refined.micronsperpixel*(1:81)', max(max(Refined.minivec{1},[],3),[],2), 'gauss1');
    Refined.FWHMY(i) = 2*sqrt(log(2))*f.c1;
    disp(['Y FWHM: ' num2str( Refined.FWHMY(i))])
