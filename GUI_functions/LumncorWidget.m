function varargout = LumncorWidget(varargin)
% LUMNCORWIDGET MATLAB code for LumncorWidget.fig
%      LUMNCORWIDGET, by itself, creates a new LUMNCORWIDGET or raises the existing
%      singleton*.
%
%      H = LUMNCORWIDGET returns the handle to a new LUMNCORWIDGET or the handle to
%      the existing singleton*.
%
%      LUMNCORWIDGET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LUMNCORWIDGET.M with the given input arguments.
%
%      LUMNCORWIDGET('Property','Value',...) creates a new LUMNCORWIDGET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LumncorWidget_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LumncorWidget_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LumncorWidget

% Last Modified by GUIDE v2.5 24-Jul-2015 15:33:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LumncorWidget_OpeningFcn, ...
                   'gui_OutputFcn',  @LumncorWidget_OutputFcn, ...
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


% --- Executes just before LumncorWidget is made visible.
function LumncorWidget_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LumncorWidget (see VARARGIN)

% Choose default command line output for LumncorWidget
handles.output = hObject;
if exist('L','var')
    fclose(L);
    clear L
end;
% Update handles structure
handles.cyanIntensity = 0;
handles.greenIntensity = 0;
handles.greenState = 0;
handles.cyanState = 0;
handles.connected = 0;

guidata(hObject, handles);

% UIWAIT makes LumncorWidget wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LumncorWidget_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function cInt_Callback(hObject, eventdata, handles)
% hObject    handle to cInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cyanIntensity  = str2double(get(hObject,'String'));

if handles.cyanIntensity > 100 || handles.cyanIntensity < 0;
    errordlg('Please enter a value between 0 and 100, asshole');
elseif ischar(handles.cyanIntensity)
    errordlg('dont put a string into a number field.  if you do it again I will murder your family')
else
    if handles.connected == 1;
        lumen(handles.cyanIntensity,'c');
    end;
    guidata(hObject,handles);
end;

% Hints: get(hObject,'String') returns contents of cInt as text
%        str2double(get(hObject,'String')) returns contents of cInt as a double


% --- Executes during object creation, after setting all properties.
function cInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gInt_Callback(hObject, eventdata, handles)
% hObject    handle to gInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.greenIntensity  = str2double(get(hObject,'String'));

if handles.greenIntensity > 100 || handles.greenIntensity < 0;
    errordlg('Please enter a value between 0 and 100, asshole');
elseif ischar(handles.greenIntensity)
    errdlg('dont put a string into a number field you mouse brain')
else
    if handles.connected == 1;
        lumen(handles.greenIntensity,'g');
    end;
    guidata(hObject,handles);
end;
% Hints: get(hObject,'String') returns contents of gInt as text
%        str2double(get(hObject,'String')) returns contents of gInt as a double


% --- Executes during object creation, after setting all properties.
function gInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cOnOff.
function cOnOff_Callback(hObject, eventdata, handles)
% hObject    handle to cOnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

v =  get(hObject,'Value');

v2 =  get(handles.gOnOff,'Value');
if v2 
    errordlg('green is already on')
    set(hObject,'Value',0);
elseif (handles.connected == 1) 
    if v == 1;
        lumen(handles.cyanIntensity,'c')
    else
        lumen(0,'c')
    end;
else
    errordlg('please connect to lumencor, buttwipe')
end
% Hint: get(hObject,'Value') returns toggle state of cOnOff


% --- Executes on button press in gOnOff.
function gOnOff_Callback(hObject, eventdata, handles)
% hObject    handle to gOnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v = get(hObject,'Value');
v2 =  get(handles.cOnOff,'Value');

if v2
    errordlg('cyan is already on')
    set(hObject,'Value',0);
elseif handles.connected == 1;
    
    if v == 1;
        lumen(handles.greenIntensity,'g')
    else
        lumen(0,'c')
    end;
    
else
    errordlg('please connect to lumencor, buttwipe')
end;
% Hint: get(hObject,'Value') returns toggle state of gOnOff


% --- Executes on button press in connect.
function connect_Callback(hObject, eventdata, handles)
% hObject    handle to connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global L

v=get(hObject,'Value');
if v == 1;
    L = serial('COM14'); %adjust com port as needed
    fopen(L);
    lumen(0,'c')
    lumen(0,'g')
    handles.connected = 1;
else
    lumen(0,'c');
    lumen(0,'g');
    fclose(L);
    delete(L);
    clear L;
    handles.connected = 0;
end;
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of connect


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global L 
lumen(0,'c');
lumen(0,'g');
    fclose(L);
    delete(L);
    clear L;
    handles.connected = 0;
% Hint: delete(hObject) closes the figure
delete(hObject);
