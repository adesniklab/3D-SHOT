function getCurrentHolo 
global ExpStruct 
locations = FrankenScopeRigFile();


path =locations.HoloRequest_DAQ_PrintedHolo;

d=dir(path);
if isempty(d)==1;
    ExpStruct.Holo.currentHolo=0;
else
   d(1:2)=[];
   if numel(d)>1;
       errordlg('Multiple Current Holo Files Detected.  Better go figure out who fucked up')
   else
       try
       data = load(strcat(path,d.name));
       
       ExpStruct.Holo.currentHolo =   data.currentHolo;
       ExpStruct.Holo.currentROIsON = data.ROIsON;
       end
   end;
end;
