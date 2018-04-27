function  openLumencor( ~ )
global ExpStruct

% test if COM part is in use from previous experiment and close it
newobjs=instrfind('Port','COM5');
if ~isempty(newobjs)
    fclose(newobjs);  % only close if port was open  
end

ExpStruct.M.Lumencor.s = serial('COM5'); %adjust com port as needed
fopen(ExpStruct.M.Lumencor.s);
% first control strings
fprintf(ExpStruct.M.Lumencor.s,'%s',char([hex2dec('57'), hex2dec('02'), hex2dec('FF'), hex2dec('50')]));
fprintf(ExpStruct.M.Lumencor.s,'%s',char([hex2dec('57'), hex2dec('03'), hex2dec('AB'), hex2dec('50')]));


end

