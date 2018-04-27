function [ Voltageout ] = function_EOMVoltage(Voltage,Power,PowerRequest)
maxpow = max(Power);
if PowerRequest<=0
    disp('WARNING : Negative power requested, will return 0W')
    Voltageout  = 0;
elseif  PowerRequest> maxpow
    disp(strcat('WARNING : Requested power :',num2str(PowerRequest),' W. Unable. Actual power will be  :', num2str(maxpow),' W'));
    Voltageout  = max(Voltage);
else   
    try
        Voltageout  = interp1(Power,Voltage,PowerRequest);
    catch
        disp(['Error in conversion...'])
        Voltageout = 0;
    end
end

end

