function [ Corcoeff ] = function_Power_Adjust( SLMPts, COC )
%SIPts format : n by 3, for n pts

Corcoeff = polyvaln(COC.PowerAdjust,SLMPts);



%This returns the multiplying factors


end

