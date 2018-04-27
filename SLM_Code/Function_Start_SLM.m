function [ SLM ] = Function_Start_SLM( SLM )

if SLM.State == 1
    disp('SLM already loaded')
else
    
    if ~libisloaded('Blink_C_wrapper')
        loadlibrary('Blink_C_wrapper.dll', 'Blink_C_wrapper.h');
    end
    
    % Basic parameters for calling Create_SDK
    bit_depth = SLM.bit_depth;
    num_boards_found = SLM.num_boards_found;
    constructed_okay = SLM.constructed_okay;
    is_nematic_type = SLM.is_nematic_type;
    RAM_write_enable = SLM.RAM_write_enable;
    use_GPU = SLM.use_GPU;
    max_transients = SLM.max_transients;
    wait_For_Trigger = SLM.wait_For_Trigger ; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
    external_Pulse =SLM.external_Pulse;
    timeout_ms = SLM.timeout_ms;
    
    % OverDrive Plus Parameters (if used)
    % For OverDrive, use 'lut_file' instead of a null pointer as the last parameter of Create_SDK
    % Matlab automatically escapes backslashes (unlike most languages)
    lut_file = SLM.lut_file;
    reg_lut = libpointer('string');
    
    % Triggering mode is stored before creating the SDK
    calllib('Blink_C_wrapper', 'Preset_triggering_mode', wait_For_Trigger);
    calllib('Blink_C_wrapper', 'Create_SDK', bit_depth, num_boards_found, constructed_okay, is_nematic_type, RAM_write_enable, use_GPU, max_transients, reg_lut);
    
    if constructed_okay.value ~= 0  % Convention follows that of C function return values: 0 is success, nonzero integer is an error
        disp('Blink SDK was not successfully constructed');
        disp(calllib('Blink_C_wrapper', 'Get_last_error_message'));
        calllib('Blink_C_wrapper', 'Delete_SDK');
    else
        disp('Blink SDK was successfully constructed');
        fprintf('Found %u SLM controller(s)\n', num_boards_found.value);
        % A linear LUT must be loaded to the controller for OverDrive Plus
        calllib('Blink_C_wrapper', 'Load_LUT_file', 1, lut_file);
        
        % Loop between our ramp images
        % for n = 1:5
        %     calllib('Blink_C_wrapper', 'Write_image', 1, ramp_0, 1920*1152, wait_For_Trigger, external_Pulse, timeout_ms);
        %     pause(1.0) % This is in seconds
        %     calllib('Blink_C_wrapper', 'Write_image', 1, ramp_1, 1920*1152, wait_For_Trigger, external_Pulse, timeout_ms);
        %     pause(1.0) % This is in seconds
        % end
        
        
        if wait_For_Trigger == 1
            disp('Triggering active')
        else
            disp('Triggering not active')
        end
        disp('SLM ready to fire ! ')
        SLM.State = 1;
    end
end

end

