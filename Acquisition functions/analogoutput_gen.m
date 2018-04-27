function [ AO0, AO1, AO2, AO3 ] = analogoutput_gen(~ )
% call globals
global cell1 cell2 LED Ramp ExpStruct Exp_Defaults h s sweeps

% assign local values
testpulse=ExpStruct.testpulse; LEDoutput1=ExpStruct.LEDoutput1;  
CCoutput1=ExpStruct.CCoutput1; CCoutput2=ExpStruct.CCoutput2;

% check for voltage clamp, current clamp, or LFP recording for each analog
% input channel from GUI
value1 = get(h.Cell1_type_popup,'Value');
value2 = get(h.Cell2_type_popup,'Value');

if (Exp_Defaults.NIDAQ_type==1) % if card = PCI-6036E only have two analog outputs
    
    if  value1==1 && value2==1 
       s.queueOutputData([testpulse LEDoutput1]);
    elseif value1==1 && value2==0
        s.queueOutputData([testpulse LEDoutput1]);
    elseif value1==0 && value2==1
        s.queueOutputData([CCoutput1 LEDoutput1]);
    elseif value1==0 && value2==0
     s.queueOutputData([CCoutput1 LEDoutput1]);
    end
    % otherwise card should have four analog outputs
else
    % set analog outputs to appropriate arrays based on values in Rig
    % Defaults set in setup_structs
    if (strcmp(Exp_Defaults.AO0,'wholecell')==1) % if whole cell1 on AO0
        if  value1==1 % if voltage clamp
            if get(h.ext_cmd_1_check,'Value')
            testpulse1 = makepulseoutputs(50,1, 50, -0.2, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
            else
            testpulse1 = makepulseoutputs(50,1, 50, 0, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration); 
            end
            AO0=testpulse1;
        else          % if currentclamp
            AO0=CCoutput1;
        end
    end
    
    if (strcmp(Exp_Defaults.AO0,'piezo')==1) % if whole cell1 on AO0
        AO0=piezooutput; 
    end
        
    if (strcmp(Exp_Defaults.AO1,'wholecell')==1) % if whole cell2 on AO0
        if  value2==1 % if voltage clamp
            if get(h.ext_cmd_2_check,'Value')
            testpulse2 = makepulseoutputs(50,1, 50, -0.2, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration);
            else
            testpulse2 = makepulseoutputs(50,1, 50, 0, 1, Exp_Defaults.Fs, Exp_Defaults.sweepduration); 
            end
            AO1=testpulse2;
        else          % if currentclamp
            AO1=CCoutput2;
        end
    end
    
    if (strcmp(Exp_Defaults.AO1,'LEDoutput1')==1)
        AO1=ExpStruct.LEDoutput1;
    end
    
    if (strcmp(Exp_Defaults.AO2,'LEDoutput1')==1)
        AO2=ExpStruct.LEDoutput1;
    end
    
    if (strcmp(Exp_Defaults.AO2,'motordir')==1)
        AO2=ExpStruct.motordir;
    end
    
    if (strcmp(Exp_Defaults.AO2,'LEDoutput2')==1)
        AO2=ExpStruct.LEDoutput2;
    end
    
    if (strcmp(Exp_Defaults.AO2,'EOM')==1)
        AO2=ExpStruct.StimLaserEOM;
    end
    
    
    if (strcmp(Exp_Defaults.AO3,'LEDoutput2')==1)
        AO3=ExpStruct.LEDoutput2;
    end
    
    if (strcmp(Exp_Defaults.AO2,'motorpulses')==1)
        AO2=ExpStruct.motorpulses;
    end
    
    if (strcmp(Exp_Defaults.AO3,'motordir')==1)
        AO3=ExpStruct.motordir;
    end
    
    if (strcmp(Exp_Defaults.AO3,'LED1')==1)
        AO3=ExpStruct.LEDoutput1;
    end
    
    
end