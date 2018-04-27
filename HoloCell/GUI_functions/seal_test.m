function varargout = seal_test(varargin)
% SEAL_TEST MATLAB code for seal_test.fig
%      SEAL_TEST, by itself, creates a new SEAL_TEST or raises the existing
%      singleton*.
%
%      H = SEAL_TEST returns the handle to a new SEAL_TEST or the handle to
%      the existing singleton*.
%
%      SEAL_TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEAL_TEST.M with the given input arguments.
%
%      SEAL_TEST('Property','Value',...) creates a new SEAL_TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before seal_test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to seal_test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help seal_test

% Last Modified by GUIDE v2.5 05-Nov-2012 14:58:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seal_test_OpeningFcn, ...
                   'gui_OutputFcn',  @seal_test_OutputFcn, ...
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


% --- Executes just before seal_test is made visible.
function seal_test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seal_test (see VARARGIN)

% Choose default command line output for seal_test
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes seal_test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = seal_test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start_seal_test.
function start_seal_test_Callback(hObject, eventdata, handles)
% hObject    handle to start_seal_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sealTimer listener
listener.Enabled = false;
start(sealTimer)

% --- Executes on button press in stop_seal_test.
function stop_seal_test_Callback(hObject, eventdata, handles)
% hObject    handle to stop_seal_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sealTimer listener
stop(sealTimer)



function Seal_R1_Callback(hObject, eventdata, handles)
% hObject    handle to Seal_R1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Seal_R1
Seal_R1=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of Seal_R1 as text
%        str2double(get(hObject,'String')) returns contents of Seal_R1 as a double


% --- Executes during object creation, after setting all properties.
function Seal_R1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Seal_R1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global seal_R1
set(hObject,'String',num2str(seal_R1));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function access_R1_Callback(hObject, eventdata, handles)
% hObject    handle to access_R1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global access_R1
access_R1=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of access_R1 as text
%        str2double(get(hObject,'String')) returns contents of access_R1 as a double


% --- Executes during object creation, after setting all properties.
function access_R1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to access_R1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global access_R1
set(hObject,'String',num2str(access_R1));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Seal_R2_Callback(hObject, eventdata, handles)
% hObject    handle to Seal_R2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Seal_R2
Seal_R2=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of Seal_R2 as text
%        str2double(get(hObject,'String')) returns contents of Seal_R2 as a double


% --- Executes during object creation, after setting all properties.
function Seal_R2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Seal_R2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global seal_R2
set(hObject,'String',num2str(seal_R2));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function access_R2_Callback(hObject, eventdata, handles)
% hObject    handle to access_R2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global access_R2
access_R2=str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of access_R2 as text
%        str2double(get(hObject,'String')) returns contents of access_R2 as a double


% --- Executes during object creation, after setting all properties.
function access_R2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to access_R2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global access_R2
set(hObject,'String',num2str(access_R2));

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in close_seal_test.
function close_seal_test_Callback(hObject, eventdata, handles)
% hObject    handle to close_seal_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sealTimer listener
close(seal_test)
listener.Enabled = true;
stop(sealTimer)
