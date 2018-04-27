function updateHoloRequest
global ExpStruct 
%getCurrentHolo
locations = FrankenScopeRigFile();
path=locations.HoloRequest_DAQ;


clear a

holoDir=dir(path);
holoDir(1:2)=[];  %delete the two dots
%get rid of other directories, leave only files
del=[];
i=1;
for k = 1:length(holoDir)
    if holoDir(k).isdir == 1;
        del(i)=k;
        i = i + 1;
    end;
end;
holoDir(del)=[];

if isfield(ExpStruct.Holo,'HoloFileCreateTime')==0;  % run this the first time the function runs

    if isempty(holoDir)==0;  % if there is a file in the directory
        ExpStruct.Holo.HoloFileCreateTime = holoDir(1).date;  %save the create Time      
        ExpStruct.Holo.holoRequestNumber=ExpStruct.Holo.holoRequestNumber+1; %incriment index
        
        %load the holoRequest file and ROIdata
        load([path 'HoloRequest.mat']);
        load([path 'ROIdata.mat'])
     
        %initialize the Holo Struct
        % setup holo struct
        
        ExpStruct.Holo.holoRequests{ExpStruct.Holo.holoRequestNumber}=holoRequest;
        ExpStruct.Holo.ROIdata = ROIdata;
        try
        ExpStruct.Holo.ImagesInfo = ImagesInfo; 
        catch
        ExpStruct.Holo.ImagesInfo = [];
        %if the dir is empty, then the holostruct is never initialized
        end
    end;
else % if the function has run before
    if  ~strcmp(holoDir(1).date,ExpStruct.Holo.HoloFileCreateTime) %if the file create date doesn't match the previous createion date
        ExpStruct.Holo.HoloFileCreateTime = holoDir(1).date;
        ExpStruct.Holo.holoRequestNumber=ExpStruct.Holo.holoRequestNumber+1;  %incriment the index
        load([path 'HoloRequest.mat']);
        load([path 'ROIdata.mat'])
     
        %save and load the file
        ExpStruct.Holo.holoRequests{ExpStruct.Holo.holoRequestNumber}=holoRequest;
        ExpStruct.Holo.ROIdata = ROIdata;
        ExpStruct.Holo.ImagesInfo = ImagesInfo; 
        
    
    end;
    % if the file is the same nothing happens
    
end;