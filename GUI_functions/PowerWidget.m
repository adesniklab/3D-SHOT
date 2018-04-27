function varargout = PowerWidget(varargin)
% POWERWIDGET MATLAB code for PowerWidget.fig
%      POWERWIDGET, by itself, creates a new POWERWIDGET or raises the existing
%      singleton*.
%
%      H = POWERWIDGET returns the handle to a new POWERWIDGET or the handle to
%      the existing singleton*.
%
%      POWERWIDGET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POWERWIDGET.M with the given input arguments.
%
%      POWERWIDGET('Property','Value',...) creates a new POWERWIDGET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PowerWidget_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PowerWidget_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PowerWidget

% Last Modified by GUIDE v2.5 19-Sep-2016 12:35:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PowerWidget_OpeningFcn, ...
                   'gui_OutputFcn',  @PowerWidget_OutputFcn, ...
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


% --- Executes just before PowerWidget is made visible.
function PowerWidget_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PowerWidget (see VARARGIN)
handles.locations = SatsumaRigFile();
handles.ROIData=load([handles.locations.HoloRequest_DAQ 'ROIdata.mat']);
handles.maxrois=numel(handles.ROIData.ROIdata.rois);
% Choose default command line output for PowerWidget
handles.output = hObject;
handles.objective = '20';
handles.roi_req=1;
handles.TF=0;
handles.power_request = 100;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PowerWidget wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PowerWidget_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function obj_Callback(hObject, eventdata, handles)
% hObject    handle to obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.objective = (get(hObject,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of obj as text
%        str2double(get(hObject,'String')) returns contents of obj as a double


% --- Executes during object creation, after setting all properties.
function obj_CreateFcn(hObject, eventdata, handles)
% hObject    handle to obj (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function power_ET_Callback(hObject, eventdata, handles)
% hObject    handle to power_ET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.power_request = str2double(get(hObject,'String'));
guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of power_ET as text
%        str2double(get(hObject,'String')) returns contents of power_ET as a double


% --- Executes during object creation, after setting all properties.
function power_ET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to power_ET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function voltage_Callback(hObject, eventdata, handles)
% hObject    handle to voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voltage as text
%        str2double(get(hObject,'String')) returns contents of voltage as a double


% --- Executes during object creation, after setting all properties.
function voltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function ROI_Callback(hObject, eventdata, handles)
% hObject    handle to ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 roi=get(hObject,'String');
 roi=str2num(roi);
 if roi<1;  
      errordlg('select an roi greater than 1');
 elseif roi>handles.maxrois;
      errordlg('roi greater than expected');
 else
     handles.roi_req=roi;
 end
 guidata(hObject,handles);
% Hints: get(hObject,'String') returns contents of ROI as text
%        str2double(get(hObject,'String')) returns contents of ROI as a double


% --- Executes during object creation, after setting all properties.
function ROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.TF
    load([handles.locations.CalibrationParams 'xyPowerInterp.mat']);
else
    load([handles.locations.CalibrationParams 'TFPowerMap.mat']);
end
load([handles.locations.CalibrationParams '20X_Objective_Zoom_2_XYZ_Calibration_Points.mat']);
load(handles.locations.PowerCalib,'LaserPower');




     roi= handles.ROIData.ROIdata.rois(handles.roi_req);
    Query=[ roi.centroid(1),roi.centroid(2),0];  %CHECK TO MAKE SURE ZLEVEL WORKS WELL
    
    [ Query_T ] = function_3DCofC(Query', XYZ_Points );
    if ~handles.TF
    ScaleFactor=xyPowerInterp(Query_T(1),Query_T(2)); 
    else
    ScaleFactor=TFPowerMap(Query_T(1),Query_T(2)); 
    end
    %disp(['Scalefactor = ' num2str(ScaleFactor)]);
    wattRequest=handles.power_request/1000;
    wattRequest=wattRequest/ScaleFactor;
        

    if  handles.TF
        handles.Volt = function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutputTF,wattRequest);
    else
        handles.Volt = function_EOMVoltage(LaserPower.EOMVoltage,LaserPower.PowerOutput,wattRequest);
    end
    
    set(handles.voltage,'string',num2str(handles.Volt));

 guidata(hObject,handles);


% --- Executes on button press in TFcb.
function TFcb_Callback(hObject, eventdata, handles)
% hObject    handle to TFcb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.TF= get(hObject,'Value');
 
 guidata(hObject,handles)
% Hint: get(hObject,'Value') returns toggle state of TFcb
