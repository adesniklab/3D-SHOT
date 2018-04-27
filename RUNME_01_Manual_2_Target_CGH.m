clear all
close all
clc

UseBasler = 0;

maxiN = 500; % set number of repetitions here !!
bigterminate = 0;
[Setup ] = function_loadparameters(); %Includes NIDAQ starting step



try
    load([Setup.Datapath '\AB_Locations.mat'])
catch
    locations = [0.4, 0.5,0.04, 0.001;0.6, 0.5, 0.04 0.001]; % XYZ position radius and power of target a
end

[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
while bigterminate == 0
    Setup.CGHMethod = 1;
    terminate = 0; c = 1;
    while terminate == 0
        disp(['Now editing target ' int2str(c)])
        disp('Arrows to move target, +/- to change z, m/l to adjust radius')
        disp('s to switch target,  p to preview q to quit')
        w = waitforbuttonpress;
        if w
            p = get(gcf, 'CurrentCharacter');
            %       disp(double(p))  %displays the ascii value of the character that was pressed
            switch double(p)
                case 30 %Arrows control x,y
                    locations(c,2) = locations(c,2)-0.01; disp(locations(c,:))
                case 31
                    locations(c,2) = locations(c,2)+0.01; disp(locations(c,:));
                case 28
                    locations(c,1) = locations(c,1)+0.01; disp(locations(c,:));
                case 29
                    locations(c,1) = locations(c,1)-0.01; disp(locations(c,:));
                case 43 %+ / - controls depth
                    locations(c,3) = locations(c,3)+0.005; disp(locations(c,:));
                case 45
                    locations(c,3) = locations(c,3)-0.005; disp(locations(c,:));
                case 109 %m/l controls radius
                    locations(c,4) = locations(c,4)+0.0001; disp(locations(c,:));
                case 108
                    locations(c,4) = locations(c,4)-0.0001; disp(locations(c,:)); 
                case 115 % s for selection
                    c = mod(c,2)+1; disp(['Now editing target ' int2str(c)])
                case 112 % p for preview
                    if UseBasler == 1; function_Basler_Preview(Setup, 10); end;
                case 113 % q to quit
                    terminate=1; disp(['quit']);
            end
            [ Hologram, Reconstruction ] = function_makeAB( locations(c,:), Setup );
            subplot(1,2,1);imagesc(Reconstruction)
            subplot(1,2,2);imagesc(Hologram)
            [ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, Hologram ,0);  pause(0.02);
        end
    end
    [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
    save([Setup.Datapath '\AB_Locations.mat'],'locations')
    
    %Setup.CGHMethod = 4;
    disp('Now compiling Nice NOVOCGH holograms at desired targets')
    [ HologramA, ReconstructionA ] = function_makeAB( locations(1,:), Setup );
    [ HologramB, ReconstructionB ] = function_makeAB( locations(2,:), Setup );
    
    sequences = {};
    for j = 1:1
        sequence = {};
        for i = 1:maxiN
            if mod(i,2) == 0
                sequence{i} = HologramA;
            else
                sequence{i} = HologramB;
            end
        end
        sequences{j} = sequence;
    end
    
    %sequences is a list of sequences
    %sequences{i} is a list of holograms to be displayed after a trigger is
    %received
    %Select sequence by selectin with square pulses pulses at 70 Hz, send too
    %many pulses to quit
    [Setup ] = function_loadparameters(1);
    [ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
    Function_shoot_sequences(Setup,sequences);
    [Setup.SLM ] = Function_Stop_SLM( Setup.SLM );
       
    %Here choose to quit or to return to alignment mode
    bigterminate = input('Enter 1 to quit, or 0 to return to manual selection mode');
end
