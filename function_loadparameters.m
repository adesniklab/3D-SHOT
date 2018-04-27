function [Setup ] = function_loadparameters(varargin)
addpath('SLM_Code');
addpath('NOVOCGH_Code');
addpath('Basler');

if numel(varargin) == 1
    if varargin{1}==1
        disp('Preparing NIDAQ to receive sequence triggering')
        try clear('Setup.DAQ'); catch; end
        Setup.Holodaq.Name = 'Dev2' ;
        Setup.DAQ = daq.createSession('ni'); % initialize session
        Fs=10000;
        Setup.DAQ.Rate = Fs ;
        Setup.DAQ.DurationInSeconds = 2/Fs;
        addDigitalChannel(Setup.DAQ,Setup.Holodaq.Name,'port0/line2','InputOnly');
        Setup.Holodaq.DAQReady=1;
        
        Setup.TimeToPickSequence = 1; % This gives you about this amount of time to select your sequence ID by shooting pulses SLM starts right at the end
    elseif varargin{1}==2
        disp('Preparing Arduino to receive sequence triggering')
        try clear('Setup.DAQ'); catch; end
        Setup.Holodaq.Name = 'due' ;
        Setup.DAQ = arduino('COM8','Due','Trace',false); % initialize session
        %Fs=10000;
        %Setup.DAQ.Rate = Fs ;
       % Setup.DAQ.DurationInSeconds = 2/Fs;
        %addDigitalChannel(Setup.DAQ,Setup.Holodaq.Name,'port0/line2','InputOnly');
        Setup.Holodaq.DAQReady=1;
    else
        disp('invalid option, you neocon scallywag');
    end
    
    
else
    Setup.Holodaq.DAQReady=0;
end

Setup.BaslerCameraID =0;

Setup.CGHMethod = 3; % Select 1 for superoposition, 2 for GGS, 3 for novocgh, 4 for 2P NovoCGH

Setup.SLM.bit_depth = 12; %For the 512L bit depth is 16, for the small 512 bit depth is 8
Setup.SLM.num_boards_found = libpointer('uint32Ptr', 0);
Setup.SLM.constructed_okay = libpointer('int32Ptr', 0);
Setup.SLM.is_nematic_type = 1;
Setup.SLM.RAM_write_enable = 1;
Setup.SLM.use_GPU = 0;
Setup.SLM.max_transients = 10;
Setup.SLM.external_Pulse = 1;
Setup.SLM.timeout_ms = 5000;
% Setup.SLM.lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\slm4610_at1064_PCIe.lut';%was working but designed for different SLM(512)
% Setup.SLM.lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\linear.LUT'; %linear Lut
% Setup.SLM.lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive
% Plus\LUT Files\slm4610_FromNico_PCIe.lut';%2/26/18 Lut File Wasn't working
Setup.SLM.lut_file = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files\slm4610_DataFromNico_Ref0.lut';%2/26/18 improved


Setup.SLM.reg_lut = libpointer('string');
Setup.SLM.true_frames = 3;
Setup.SLM.pixelmax = 190;
Setup.SLM.Nx = 1920;
Setup.SLM.Ny = 1152;
Setup.SLM.wait_For_Trigger= 0; % Set to 1 before initialization as needed.
Hologram = zeros(Setup.SLM.Nx,Setup.SLM.Ny);
Setup.SLM.State =0;
[ Setup.SLM ] = Function_Start_SLM( Setup.SLM );
[ Setup.SLM ] = Function_Feed_SLM( Setup.SLM, Hologram);
Function_Stop_SLM( Setup.SLM );


% Specify system for computation of hologramsparameters here
Setup.verbose=1;           % 1 or 0    Set this value to 1 to display activity, 0 otherwise
Setup.lambda = 1.030e-6;   % meters    Wavelength of the light
Setup.focal_SLM = 0.2;     % meters    focal length of the telescope lens after slm.
Setup.psSLM = 9.2e-6;       % meters    SLM pixel dimensions
Setup.Nx = Setup.SLM.Nx;            % int       Number of pixels in X direction
Setup.Ny = Setup.SLM.Ny;            % int       Number of pixels in Y direction
Setup.useGPU = 0;          % 1 or 0    Use GPU to accelerate computation. Effective when Nx, Ny is large (e.g. 600*800).
Setup.maxiter = 50;        % int       Number of iterations (for all methods explored)
Setup.GSoffset = 0.01;     % float>0   Regularization constant to allow low light background in 3D Gerchberg Saxton algorithms

% Specify Low and High threshold for threshold-based cost functions
NormOptions.HighThreshold = 0.5;
NormOptions.LowThreshold = 0.1;

%Specify Illumination pattern at the SLM, Uniform here, but tunable in
%general.
Setup.intensity = 1;
Setup.source = sqrt(Setup.intensity)*(1/(Setup.Nx* Setup.Ny))*ones(Setup.Nx, Setup.Ny);

Setup.Datapath = 'Calib_Data';
Setup.Displaypath = 'Calib_Displays';

Setup.Sutterport = 'COM6';

Setup.Holorequestpath = '\\adesnik2.ist.berkeley.edu\inhibition\holography\FrankenRig\HoloRequest\';

end

