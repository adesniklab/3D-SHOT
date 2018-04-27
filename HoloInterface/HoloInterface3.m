function varargout = HoloInterface3(varargin)
% HOLOINTERFACE3 MATLAB code for HoloInterface3.fig
%      HOLOINTERFACE3, by itself, creates a new HOLOINTERFACE3 or raises the existing
%      singleton*.
%
%      H = HOLOINTERFACE3 returns the handle to a new HOLOINTERFACE3 or the handle to
%      the existing singleton*.
%
%      HOLOINTERFACE3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HOLOINTERFACE3.M with the given input arguments.
%
%      HOLOINTERFACE3('Property','Value',...) creates a new HOLOINTERFACE3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HoloInterface3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HoloInterface3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HoloInterface3

% Last Modified by GUIDE v2.5 04-Jan-2017 13:17:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HoloInterface3_OpeningFcn, ...
    'gui_OutputFcn',  @HoloInterface3_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before HoloInterface3 is made visible.
function HoloInterface3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HoloInterface3 (see VARARGIN)
locations = FrankenScopeRigFile();
% Choose default command line output for HoloInterface3
handles.output = hObject;
handles.selectAllROIs=0;
handles.generateGrid=0;
handles.generateXYZ=0;
handles.objective = 20;
handles.xoffset = 0;
handles.yoffset = 0;
handles.zoffset = 0;
handles.hologram_config = 'DLS';
handles.sphereDiameter = 20;
handles.reload  = 0;
handles.xPoints = 5;
handles.yPoints = 5;
handles.zPoints = 10;
handles.xSpacing = 5;
handles.ySpacing = 5;
handles.zSpacing = 10;
handles.randomizelist = 0;
handles.excludeROIs=0;
handles.save=0;
handles.cycleSequence = 0;
handles.iii = 1;
handles.makeSeq=0;
handles.correctPower = 1;
% Update handles structure
handles.ROIdata=load([locations.HoloRequest 'ROIdata.mat']);
handles.zoom = handles.ROIdata.ImagesInfo.zoomFactor;  %errordlg - set string in text box to equal this when you're not being lazy
set(handles.zoomET,'String',num2str(handles.zoom));
% set(handles.zoomET,handles.zoom)
guidata(hObject, handles);

% UIWAIT makes HoloInterface3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HoloInterface3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in genGridCB.
function genGridCB_Callback(hObject, eventdata, handles)
% hObject    handle to genGridCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.generateGrid=1;
else
    handles.generateGrid=0;
end

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of genGridCB



function objectiveET_Callback(hObject, eventdata, handles)
% hObject    handle to objectiveET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.objective =  str2double(get(hObject,'String'));
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of objectiveET as text
%        str2double(get(hObject,'String')) returns contents of objectiveET as a double


% --- Executes during object creation, after setting all properties.
function objectiveET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to objectiveET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.objective =  str2double(get(hObject,'String'));
guidata(hObject, handles);



function zoomET_Callback(hObject, eventdata, handles)
% hObject    handle to zoomET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.zoom =  str2double(get(hObject,'String'));
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of zoomET as text
%        str2double(get(hObject,'String')) returns contents of zoomET as a double


% --- Executes during object creation, after setting all properties.
function zoomET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoomET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.zoom =  str2double(get(hObject,'String'));
guidata(hObject, handles);


function ROIsET_Callback(hObject, eventdata, handles)
% hObject    handle to ROIsET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x=get(hObject,'String');
rois=HI3Parse(x)
handles.rois = rois;


guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of ROIsET as text
%        str2double(get(hObject,'String')) returns contents of ROIsET as a double


% --- Executes during object creation, after setting all properties.
function ROIsET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIsET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xoffET_Callback(hObject, eventdata, handles)
% hObject    handle to xoffET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xoffset =  str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of xoffET as text
%        str2double(get(hObject,'String')) returns contents of xoffET as a double


% --- Executes during object creation, after setting all properties.
function xoffET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xoffET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.xoffset =  str2double(get(hObject,'String'));
guidata(hObject, handles);


function yoffET_Callback(hObject, eventdata, handles)
% hObject    handle to yoffET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.yoffset =  str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of yoffET as text
%        str2double(get(hObject,'String')) returns contents of yoffET as a double


% --- Executes during object creation, after setting all properties.
function yoffET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yoffET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.yoffset =  str2double(get(hObject,'String'));
guidata(hObject, handles);


function zoffET_Callback(hObject, eventdata, handles)
% hObject    handle to zoffET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.zoffset =  str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of zoffET as text
%        str2double(get(hObject,'String')) returns contents of zoffET as a double


% --- Executes during object creation, after setting all properties.
function zoffET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zoffET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.zoffset =  str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes on button press in generateXYZ_CB.
function generateXYZ_CB_Callback(hObject, eventdata, handles)
% hObject    handle to generateXYZ_CB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.generateXYZ=1;
else
    handles.generateXYZ=0;
end

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of generateXYZ_CB


% --- Executes on button press in selectAllROIs_CB.
function selectAllROIs_CB_Callback(hObject, eventdata, handles)
% hObject    handle to selectAllROIs_CB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.selectAllROIs=1;
else
    handles.selectAllROIs=0;
end

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of selectAllROIs_CB


% --- Executes on button press in DLS_RB.
function DLS_RB_Callback(hObject, eventdata, handles)
% hObject    handle to DLS_RB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DLS_RB


% --- Executes on button press in centroidSphere_RB.
function centroidSphere_RB_Callback(hObject, eventdata, handles)
% hObject    handle to centroidSphere_RB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of centroidSphere_RB



function sphereDiameterET_Callback(hObject, eventdata, handles)
% hObject    handle to sphereDiameterET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.sphereDiameter=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of sphereDiameterET as text
%        str2double(get(hObject,'String')) returns contents of sphereDiameterET as a double


% --- Executes during object creation, after setting all properties.
function sphereDiameterET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sphereDiameterET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.sphereDiameter=str2double(get(hObject,'String'));
guidata(hObject, handles);

function donutFactor_ET_Callback(hObject, eventdata, handles)
% hObject    handle to donutFactor_ET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of donutFactor_ET as text
%        str2double(get(hObject,'String')) returns contents of donutFactor_ET as a double
handles.donutFactor=str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function donutFactor_ET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to donutFactor_ET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.donutFactor=str2double(get(hObject,'String'));
guidata(hObject, handles);


function shrinkingFactor_ET_Callback(hObject, eventdata, handles)
% hObject    handle to shrinkingFactor_ET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.shrinkingFactor=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of shrinkingFactor_ET as text
%        str2double(get(hObject,'String')) returns contents of shrinkingFactor_ET as a double


% --- Executes during object creation, after setting all properties.
function shrinkingFactor_ET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shrinkingFactor_ET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.shrinkingFactor=str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'DLS_RB'
        handles.hologram_config = 'DLS';
        %  display('dls')
    case 'filledCircle_RB'
        handles.hologram_config = 'filledCircle';
        %   display('filled circle')
    case 'edgeOnly_RB'
        handles.hologram_config = 'edge';
        %    display('edge')
    case 'customShape_RB'
        handles.hologram_config = 'custom';
        %    display('custom')
    case 'paramSpace_RB'
        handles.hologram_config = 'paramaterSpace';
        %    display('param')
end

guidata(hObject, handles);

% --- Executes on button press in reload.
function reload_Callback(hObject, eventdata, handles)
% hObject    handle to reload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.reload=1;
else
    handles.reload=0;
end

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of reload


% --- Executes on button press in enterPB.
function enterPB_Callback(hObject, eventdata, handles)
% hObject    handle to enterPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning = 0;

%% error checks

% if you have a wrong number for the objective...
if isempty(intersect(handles.objective,[4 20 40])) == 1;
    errordlg('Objective Must be equal to 4, 20, or 40');
    warning = 1;
end;

%if you didnt specify a zoom....
if isempty('handles.zoom') == 1;
    errordlg('set zoom');
    warning = 1;
end;

%if you didnt select all ROIs and you didnt specify any ROIs....
if handles.selectAllROIs == 0;
    if isfield(handles,'rois') == 0;
        errordlg('select at least one ROI')
        warning = 1;
    end;
end;

% if you selected all ROIs, set ROIS to[]
if handles.selectAllROIs == 1;
    handles.rois = [];
end;

% if you selected both generate grid and generate XYZ
if handles.generateGrid == 1 && handles.generateXYZ ==1;
    errordlg('select either grid OR XYZ')
    warning = 1;
end;

% if you selected a grid, you have to only have one ROI
if handles.generateGrid == 1;
    if numel(handles.rois)>1;
        errordlg('select only 1 ROI from which to make a grid');
        warning = 1;
    end;
end;

% if you generate an XYZ sequence, you have to have only one ROI
if handles.generateXYZ == 1;
    if numel(handles.rois)>1;
        errordlg('select only 1 ROI from which to make a XYZ map');
        warning = 1;
    end;
end;

%if randomize, then save
%if (handles.randomizelist == 1) && (handles.save == 0);
%  errordlg('if you randomize, you better save the file, bro');
%    warning =1;
%end;

if isfield(handles,'rois');
    if (isempty(strmatch(handles.hologram_config,'paramaterSpace'))==0) && (numel(handles.rois)>1);
        errordlg('if you want to cycle through paramater space, select only one holo');
        warning = 1;
    end;
end;

if numel(strmatch(handles.hologram_config,'paramaterSpace'))>0 && ( (handles.generateGrid ==1) || (handles.generateXYZ ==1));
    errordlg('if you want to cycle through paramater space, then you cant generate a grid or xyz matrix');
    warning = 1;
end;


if numel(strmatch(handles.hologram_config,'paramaterSpace'))>0;
    
    paramConfig=csvread([locations.customHolo 'CustomHologram.csv'],1);
    holoRequest.ParamaterSpace_Params = paramConfig;
    
end;







if handles.selectAllROIs == 1 && handles.excludeROIs == 1
    errordlg('make up you mind, either select all or exclude!')
    warning = 1;
end;

if isfield(handles,'rois') == 1  ;
    if handles.excludeROIs == 1 && numel(handles.rois)==0;
        errordlg('select at least one ROI')
        warning = 1;
    end;
elseif isfield(handles,'rois') == 0 && handles.excludeROIs == 1
    errordlg('select at least one ROI.')
    warning = 1;
    
end;


if numel(strmatch(handles.hologram_config,'custom'))>0
    if (handles.donutFactor > 1) || (handles.donutFactor < 0);
        
        errordlg('donut factor should be between 0 and 1')
        warning = 1;
    end;
    
    if (handles.shrinkingFactor > 1) || (handles.shrinkingFactor < 0);
        
        errordlg('shrinking factor should be between 0 and 1')
        warning = 1;
    end;
    
end;


elements =[];
if isfield(handles,'rois')==1
    for n=1:numel(handles.rois);
        elements=cat(2,elements,handles.rois{n});
    end;
else
    errordlg('select an roi!')
end;

if max(elements)>numel(handles.ROIdata.ROIdata.rois);
    errordlg('ROI requested that does not exist in ROIdata');
    warning = 1;
end;

if min(elements)<1;
    errordlg('ROI requested that does not exist in ROIdata');
    warning = 1;
end;

%% convert XYZ offset to microns

if (handles.objective == 20) && handles.zoom == 1
    lx=800;
    ly=800;
elseif (handles.objective == 20) && handles.zoom == 2
    lx= 400;
    ly= 400;
elseif (handles.objective == 20) && handles.zoom == 3;
    lx=260;
    ly=260;
elseif (handles.objective == 20) && handles.zoom == 1.5
    lx= 600;
    ly= 600;
elseif (handles.objective == 20) && handles.zoom == 4
    lx= 200;
    ly= 200;
elseif (handles.objective == 20) && handles.zoom == 8
    lx=95;
    ly=104;
else
    errordlg('window size unavialable for selected obj/zoom - xy offset unavailable')
    warning = 1;
end



    if ~isnan(handles.sphereDiameter);
        %disp(['resizing all ROIs to be a disc of ' num2str(handles.sphereDiameter) ' um around centroid']);
        
        locations = FrankenScopeRigFile();
        load([locations.HoloRequest 'ROIdata.mat']);
        
        for j = 1:numel(ROIdata.rois);
       
            ROIdata.rois(j).vertices=[];

                        
            r=handles.sphereDiameter/2;
            x=ROIdata.rois(j).centroid(1);
            y=ROIdata.rois(j).centroid(2);
            
            th = 0:pi/10:2*pi;
            xunit = r * cos(th) + x;
            yunit = r * sin(th) + y;
            
            ROIdata.rois(j).vertices(:,1)=xunit;
            ROIdata.rois(j).vertices(:,2)=yunit;
            
            
        end
        
        
        save([locations.HoloRequest 'ROIdata.mat'],'ROIdata','-mat')
        save([locations.HoloRequest 'ROIdata.mat'],'ImagesInfo','-append')
        save([locations.HoloRequest_DAQ 'ROIdata.mat'],'ROIdata','-mat')
        save([locations.HoloRequest_DAQ 'ROIdata.mat'],'ImagesInfo','-append')
        disp('ROIs adjusted and uploaded to holoRequest servers')
  
    end;
    
    if handles.correctPower
    disp('Power Correction with old interpolant currently disabled')
    holoRequest.PowerAttenuation=ones(numel(ROIdata.rois),1);
    else
        holoRequest.PowerAttenuation=ones(numel(ROIdata.rois),1);
    end

%%

if warning == 0;
    
    %convert microns to nico units
    MODxoffset = (handles.xoffset/lx)*512;
    MODyoffset = (handles.yoffset/ly)*512;
    MODxSpacing = (handles.xSpacing/lx)*512;
    MODySpacing = (handles.ySpacing/ly)*512;
    
   holoRequest.specialGrid = 0;
     
    %generate output file
    holoRequest.reload = handles.reload;
    holoRequest.objective=handles.objective;
    holoRequest.zoom=handles.zoom;
    
    if handles.selectAllROIs ==1;
        handles.rois={[1:numel(handles.ROIdata.ROIdata.rois(:))]};
    end

    iiv=1; toDel=[];
    for u = 1:numel(handles.rois);
        if isempty(handles.rois{u})
            toDel(iiv)=u;
            iiv=iiv+1;
        end
    end
    
    handles.rois(toDel)=[];
    
    [listOfPossibleHolos convertedSequence] = convertSequence(handles.rois);
    holoRequest.rois=listOfPossibleHolos;
    holoRequest.Sequence = {convertedSequence};
    
    % if we are scaling factor
    if ~isempty(holoRequest.PowerAttenuation)
        disp('line 711 power correction disabled- old functionality')
%         for j = 1:numel(holoRequest.rois);
%             clear Scaled toScale;
%             thisHolo=holoRequest.rois{j};
%             for k = 1:numel(thisHolo);
%                 toScale(k)=holoRequest.PowerAttenuation(thisHolo(k));
%             end
%             
%              Scaled=1./toScale;
%             holoRequest.roisLambda{j}=toScale/sum(toScale);
%             holoRequest.roisScale{j}=toScale;
%            toScale=1./toScale;
%              holoRequest.powerMultiplier{j}= toScale/(mean(toScale));
%        end
    end
    
    %note - on daq feedback, multiply sum(toScale) * reqWatts
    holoRequest.zoom=ImagesInfo.zoomFactor;
    holoRequest.OptotuneDepths=ImagesInfo.OptotuneDepths;
    holoRequest.xoffset=MODxoffset;
    holoRequest.yoffset=MODyoffset;
    holoRequest.zoffset=handles.zoffset;
    holoRequest.grid=handles.generateGrid;
    holoRequest.xyz_map=handles.generateXYZ;
    holoRequest.hologram_config=handles.hologram_config;
    holoRequest.spacing.x=MODxSpacing;
    holoRequest.spacing.y=MODySpacing;
    holoRequest.spacing.z=handles.zSpacing;
    holoRequest.points.x=handles.xPoints;
    holoRequest.points.y=handles.yPoints;
    holoRequest.points.z=handles.zPoints;
    holoRequest.randomizelist = handles.randomizelist;
    holoRequest.excludeROIs = handles.excludeROIs;
    holoRequest.cycleSequence = handles.cycleSequence;
    
    
    %% generate random list
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    NXYZ = [holoRequest.points.x,holoRequest.points.y,holoRequest.points.z];
    LXYZ = [holoRequest.spacing.x,holoRequest.spacing.y,holoRequest.spacing.z];
    UX = linspace(-NXYZ(1)*LXYZ(1),NXYZ(1)*LXYZ(1),2*NXYZ(1)+1);
    UY = linspace(-NXYZ(2)*LXYZ(2),NXYZ(2)*LXYZ(2),2*NXYZ(2)+1);
    UZ = linspace(-NXYZ(3)*LXYZ(3),NXYZ(3)*LXYZ(3),2*NXYZ(3)+1);
    
    
    UMySpacing =(handles.ySpacing/MODySpacing)*UY;
    UMxSpacing =(handles.xSpacing/MODySpacing)*UX;
    
    GridPosition = zeros(3,prod(2*NXYZ+1));
    llcounter = 1;
    for lli = 1:(2*NXYZ(1)+1)
        for llj = 1:(2*NXYZ(2)+1)
            for llk = 1:(2*NXYZ(3)+1)
                GridPosition(1,llcounter) =  UX(lli);
                GridPosition(2,llcounter) =  UY(llj);
                GridPosition(3,llcounter) =  UZ(llk);
                llcounter = llcounter +1;
            end
        end
    end
    
    umMapPosition = zeros(3,(2*sum(NXYZ)+3));
    MapPosition = zeros(3,(2*sum(NXYZ)+3));
    llcounter = 1;
    for lli = 1:(2*NXYZ(1)+1)
        MapPosition(1,llcounter) = UX(lli);
        umMapPosition(1,llcounter) = UMxSpacing(lli);
        llcounter = llcounter +1;
    end
    for llj = 1:(2*NXYZ(2)+1)
        MapPosition(2,llcounter) = UY(llj);
        umMapPosition(2,llcounter) =  UMySpacing(llj);
        llcounter = llcounter +1;
    end
    for llk = 1:(2*NXYZ(3)+1)
        MapPosition(3,llcounter) = UZ(llk);
        umMapPosition(3,llcounter) = UZ(llk);
        llcounter = llcounter +1;
    end
    holoRequest.XYZMapPosition_Microns = umMapPosition;
    holoRequest.XYZMapPosition = MapPosition;
    holoRequest.GridPosition   = GridPosition;
    MapPosition = MapPosition(:,randperm(2*sum(NXYZ)+3));
    GridPosition = GridPosition(:,randperm(prod(2*NXYZ+1)));
    holoRequest.RandXYZMapPosition = MapPosition;
    holoRequest.RandGridPosition   = GridPosition;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    locations=FrankenScopeRigFile();
    save([locations.HoloRequest 'HoloRequest.mat'],'holoRequest');
    save([locations.HoloRequest_DAQ 'HoloRequest.mat'],'holoRequest');
    
    if handles.save == 1;
        save(strcat(handles.saveDir,'holoRequest_',date,'_',num2str(handles.iii)),'holoRequest');
        handles.iii = handles.iii + 1;
    end;
    
end;


guidata(hObject, handles);

function YSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to YSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ySpacing=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of YSpacing as text
%        str2double(get(hObject,'String')) returns contents of YSpacing as a double


% --- Executes during object creation, after setting all properties.
function YSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.ySpacing=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zspacing_Callback(hObject, eventdata, handles)
% hObject    handle to Zspacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.zSpacing=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of Zspacing as text
%        str2double(get(hObject,'String')) returns contents of Zspacing as a double


% --- Executes during object creation, after setting all properties.
function Zspacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zspacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xPoints_Callback(hObject, eventdata, handles)
% hObject    handle to xPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xPoints=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of xPoints as text
%        str2double(get(hObject,'String')) returns contents of xPoints as a double


% --- Executes during object creation, after setting all properties.
function xPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.xPoints=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yPoints_Callback(hObject, eventdata, handles)
% hObject    handle to yPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.yPoints=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of yPoints as text
%        str2double(get(hObject,'String')) returns contents of yPoints as a double


% --- Executes during object creation, after setting all properties.
function yPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zPoints_Callback(hObject, eventdata, handles)
% hObject    handle to zPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.zPoints=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of zPoints as text
%        str2double(get(hObject,'String')) returns contents of zPoints as a double


% --- Executes during object creation, after setting all properties.
function zPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xSpacing_Callback(hObject, eventdata, handles)
% hObject    handle to xSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xSpacing=str2double(get(hObject,'String'));
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of xSpacing as text
%        str2double(get(hObject,'String')) returns contents of xSpacing as a double


% --- Executes during object creation, after setting all properties.
function xSpacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in randomize.
function randomize_Callback(hObject, eventdata, handles)
% hObject    handle to randomize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.randomizelist=1;
else
    handles.randomizelist=0;
end

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of randomize



function saveDIR_et_Callback(hObject, eventdata, handles)
% hObject    handle to saveDIR_et (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.saveDir = get(hObject,'String');
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of saveDIR_et as text
%        str2double(get(hObject,'String')) returns contents of saveDIR_et as a double





% --- Executes on button press in saveCB.
function saveCB_Callback(hObject, eventdata, handles)
% hObject    handle to saveCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.save=1;
else
    handles.save=0;
end

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of saveCB


% --- Executes on button press in excludeROIs_CB.
function excludeROIs_CB_Callback(hObject, ~, handles)
% hObject    handle to excludeROIs_CB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.excludeROIs=1;
else
    handles.excludeROIs=0;
end

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of excludeROIs_CB


% --- Executes on button press in cycleCB.
function cycleCB_Callback(hObject, eventdata, handles)
% hObject    handle to cycleCB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.cycleSequence=1;
else
    handles.cycleSequence=0;
end

guidata(hObject, handles);



% --- Executes on button press in seq.
function seq_Callback(hObject, eventdata, handles)
% hObject    handle to seq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v = get(hObject,'Value');
if v == 1
    handles.makeSeq=1;
else
    handles.makeSeq=0;
end;
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of seq



% --- Executes on button press in powerBox.
function powerBox_Callback(hObject, eventdata, handles)
% hObject    handle to powerBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.correctPower = get(hObject,'Value');
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of powerBox
