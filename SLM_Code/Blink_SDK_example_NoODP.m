% Example usage of Blink_SDK_C.dll
% Meadowlark Optics Spatial Light Modulators
% last updated: May 31 2017

% Load the DLL
% Blink_C_wrapper.dll, Blink_SDK.dll, FreeImage.dll and wdapi1021.dll
% should all be located in the same directory as the program referencing the
% library
if ~libisloaded('Blink_C_wrapper')
    loadlibrary('Blink_C_wrapper.dll', 'Blink_C_wrapper.h');
end

% Basic parameters for calling Create_SDK
bit_depth = 12;
num_boards_found = libpointer('uint32Ptr', 0);
constructed_okay = libpointer('int32Ptr', 0);
is_nematic_type = 1;
RAM_write_enable = 1;
use_GPU = 0;
max_transients = 10;
wait_For_Trigger = 0; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
external_Pulse = 0;
timeout_ms = 5000;

% OverDrive Plus Parameters (if used)
% For OverDrive, use 'lut_file' instead of a null pointer as the last parameter of Create_SDK
% Matlab automatically escapes backslashes (unlike most languages)
lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\linear.LUT';
reg_lut = libpointer('string');

% Blank calibration image
WFC = imread('..\Image Files\1920\1920black.bmp');
  
% Arrays for image data
ramp_0 = rot90(mod(imread('..\Image Files\1920\1920RampPer08.bmp') + WFC, 256), 3);
ramp_1 = rot90(mod(imread('..\Image Files\1920\1920RampPer08Reverse.bmp') + WFC, 256), 3);

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
    for n = 1:5
        calllib('Blink_C_wrapper', 'Write_image', 1, ramp_0, 1920*1152, wait_For_Trigger, external_Pulse, timeout_ms);
        pause(1.0) % This is in seconds
        calllib('Blink_C_wrapper', 'Write_image', 1, ramp_1, 1920*1152, wait_For_Trigger, external_Pulse, timeout_ms);
        pause(1.0) % This is in seconds
    end
    
    % Always call Delete_SDK before exiting
    calllib('Blink_C_wrapper', 'Delete_SDK');
end

if libisloaded('Blink_C_wrapper')
    unloadlibrary('Blink_C_wrapper');
end