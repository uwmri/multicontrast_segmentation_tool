function varargout = dialog_erodemask3d(varargin)
% DIALOG_ERODEMASK3D MATLAB code for dialog_erodemask3d.fig
%      DIALOG_ERODEMASK3D, by itself, creates a new DIALOG_ERODEMASK3D or raises the existing
%      singleton*.
%
%      H = DIALOG_ERODEMASK3D returns the handle to a new DIALOG_ERODEMASK3D or the handle to
%      the existing singleton*.
%
%      DIALOG_ERODEMASK3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOG_ERODEMASK3D.M with the given input arguments.
%
%      DIALOG_ERODEMASK3D('Property','Value',...) creates a new DIALOG_ERODEMASK3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialog_erodemask3d_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialog_erodemask3d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialog_erodemask3d

% Last Modified by GUIDE v2.5 21-Nov-2017 16:27:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialog_erodemask3d_OpeningFcn, ...
                   'gui_OutputFcn',  @dialog_erodemask3d_OutputFcn, ...
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


% --- Executes just before dialog_erodemask3d is made visible.
function dialog_erodemask3d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialog_erodemask3d (see VARARGIN)

% dialog_erodemask3d(dummy_variable, handles.loaded_mask, handles.cMaskName)
loaded = varargin{2};
cMaskName = varargin{3};

set(handles.popup_mask,'String',cMaskName(loaded));

% Output{1} = (mask choice value), output{2} = (radius)
% Output{1} = 0 means user cancelled dialog.
handles.output = cell(1,2);
handles.output{1} = 0; 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialog_savemask wait for user response (see UIRESUME)
uiwait(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = dialog_erodemask3d_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output{1};
varargout{2} = handles.output{2};

delete(hObject);


% --- Executes on selection change in popup_mask.
function popup_mask_Callback(hObject, eventdata, handles)
% hObject    handle to popup_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_mask contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_mask


% --- Executes during object creation, after setting all properties.
function popup_mask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_radius_Callback(hObject, eventdata, handles)
% hObject    handle to edit_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_radius as text
%        str2double(get(hObject,'String')) returns contents of edit_radius as a double


% --- Executes during object creation, after setting all properties.
function edit_radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_ok.
function push_ok_Callback(hObject, eventdata, handles)
% hObject    handle to push_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

radius = str2num(get(handles.edit_radius,'String'));

if radius < 2
    h = errordlg('Erosion radius must be at least 2');
else
    handles.output{1} = get(handles.popup_mask,'Value');
    handles.output{2} = radius;
    
    guidata(hObject, handles);
    uiresume;
end


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;


% --- Executes when user attempts to close figure_erodemask3d.
function figure_erodemask3d_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_erodemask3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume;
