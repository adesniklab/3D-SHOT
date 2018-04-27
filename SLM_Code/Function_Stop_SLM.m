function [SLM ] = Function_Stop_SLM( SLM )
try if SLM.State == 1;
  calllib('Blink_C_wrapper', 'Delete_SDK');
  disp('SLM OFF')
    else
         disp('SLM is already off')
    end
catch
  disp('SLM is already off')
end

SLM.State = 0;
if libisloaded('Blink_C_wrapper')
    unloadlibrary('Blink_C_wrapper');
end

end

