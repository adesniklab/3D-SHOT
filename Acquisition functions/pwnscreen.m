function pwnscreen(~)


filename = 'C:\Program Files (x86)\Texas Instruments-DLP\SampleApp64bit\lib\PortabilityLayer.dll';
headname ='C:\Program Files (x86)\Texas Instruments-DLP\SampleApp64bit\include\PortabilityLayer.h';

loadlibrary(filename, headname, 'alias', 'DMD');

% calllib('DMD','DLP_Source_SetDataSource',3);


% calllib('DMD','DLP_Trigger_SetExternalTriggerEdge',  1);
% calllib('DMD','DLP_Display_HorizontalFlip',  1);
% calllib('DMD','DLP_Display_VerticalFlip',  0);
% calllib('DMD','DLP_Display_SetDegammaEnable',  0);
% calllib('DMD','DLP_LED_SetLEDEnable',  0, 0);
% calllib('DMD','DLP_LED_SetLEDEnable', 1, 1);
% calllib('DMD','DLP_LED_SetLEDEnable',  2, 0);
% calllib('DMD','DLP_LED_SetLEDEnable',  3, 0);
% calllib('DMD','DLP_PWM_SetPeriod',  500 );
% calllib('DMD','DLP_PWM_SetDutyCycle',  0, 1023);
% calllib('DMD','DLP_PWM_SetDutyCycle',  2, 1023);
% calllib('DMD','DLP_PWM_SetDutyCycle',  1, 1023);
% calllib('DMD','DLP_PWM_SetDutyCycle',  3, 1023);
% calllib('DMD','WriteSYNC',  1, 1, 0, 0, 1);
% calllib('DMD','WriteSYNC',  2, 1, 0, 0, 1);
% calllib('DMD','WriteSYNC',  3, 1, 0, 0, 1);
calllib('DMD','DLP_Source_SetDataSource','SL_AUTO')
final = ones(98304,1)*255;
calllib('DMD','DLP_Img_DownloadBitplanePatternToExtMem',final,98304,0)
calllib('DMD','DLP_RegIO_WriteImageOrderLut',1, 0, 1);
calllib('DMD','DLP_Display_DisplayPatternAutoStepRepeatForMultiplePasses');
