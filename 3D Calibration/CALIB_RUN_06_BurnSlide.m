try function_close_sutter( Sutter );     [Setup.SLM ] = Function_Stop_SLM( Setup.SLM ); end
clear all;close all;clc;
[Setup ] = function_loadparameters(2);

%Overwrite delay duration
Setup.TimeToPickSequence = 2;
Setup.SLM.timeout_ms = 10000;

%Align the calibration slide
[ Sutter ] = function_Sutter_Start( Setup );
Sutter.Reference = getPosition(Sutter.obj);

%Here, load a list of hologram...
load([Setup.Datapath '\05_XYZ_Alignment_Holograms.mat']); pause(0.1);
clc; disp('List of avaialble calibrations :')
for j = 1:numel(Calibrations.Zooms)
    fprintf(['Calib #' int2str(j) ', Optotune depths:' int2str(Calibrations.ODepths{j}) ', at Zoom : ' num2str(Calibrations.Zooms{j})]); disp(' ');
end
selectcalib = input('Enter the calibration number you want to record ; ->');
disp([' Please record data in subfolder "Calib_Data/' int2str(selectcalib) '/"'])
clc;
SLM = Calibrations.SLM{selectcalib};
[LZ, LP] = size(SLM.Hologram);
fprintf(['Selected Calib #' int2str(selectcalib) ', Optotune depths:' int2str(Calibrations.ODepths{selectcalib}) ', at Zoom : ' num2str(Calibrations.Zooms{selectcalib})]); disp(' ');
disp(['You have ' int2str( LZ) ' depth levels'])
disp(['You have ' int2str( LP) ' spots per depth level'])

counter = 1;
while counter <=LZ
    disp(['now engraving level ' int2str(counter)])
    disp(['True Z = ' int2str(SLM.Depths.True(counter)) ' microns'] )
    disp(['Set Optotune Zs to ' int2str(SLM.Depths.SI)] )
    %Move to the right depth
    position = Sutter.Reference;
    moveTime=moveTo(Sutter.obj,position);
    input('Find area thats OK Press enter when ready ');
    Sutter.Reference = getPosition(Sutter.obj);
    position = Sutter.Reference;
    position(3) = position(3) + SLM.Depths.True(counter);
    moveTime=moveTo(Sutter.obj,position);
    Setup.SLM.wait_For_Trigger= 1;
    [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
    [ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
    sequences = {};
    for i = 1:LP
        sequences{1}{i} = SLM.Hologram{counter,i};
    end
    Function_shoot_sequences_due(Setup,sequences,1);  
    [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
    h = input('Enter 1 to continue, 0 to redo ->');
    if h == 1;
        counter = counter+1;
    end
end

position = Sutter.Reference; moveTime=moveTo(Sutter.obj,position);
function_close_sutter( Sutter );

