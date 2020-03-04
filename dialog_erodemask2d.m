function varargout = dialog_erodemask2d(varargin)
% DIALOG_ERODEMASK2D MATLAB code for dialog_erodemask2d.fig
%      DIALOG_ERODEMASK2D, by itself, creates a new DIALOG_ERODEMASK2D or raises the existing
%      singleton*.
%
%      H = DIALOG_ERODEMASK2D returns the handle to a new DIALOG_ERODEMASK2D or the handle to
%      the existing singleton*.
%
%      DIALOG_ERODEMASK2D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOG_ERODEMASK2D.M with the given input arguments.
%
%      DIALOG_ERODEMASK2D('Property','Value',...) creates a new DIALOG_ERODEMASK2D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialog_erodemask2d_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialog_erodemask2d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialog_erodemask2d

% Last Modified by GUIDE v2.5 21-Nov-2017 16:27:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialog_erodemask2d_OpeningFcn, ...
                   'gui_OutputFcn',  @dialog_erodemask2d_OutputFcn, ...
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


% --- Executes just before dialog_erodemask2d is made visible.
function dialog_erodemask2d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialog_erodemask2d (see VARARGIN)

% INPUT: dialog_erodemask2d('dummy', handles.loaded_mask, handles.cMaskName, handles.xyzres);
loaded = varargin{2};
cMaskName = varargin{3};
handles.xyzres = varargin{4};

set(handles.popup_mask,'String',cMaskName(loaded));
set(handles.edit_rangelow,'String','1');
set(handles.edit_rangehigh,'String',num2str(handles.xyzres(3)));

% OUTPUT: [i, radius, range]
handles.output = cell(1,3);
handles.output{1} = 0; 

if sum(loaded) == 5
    set(handles.maxmaskerror,'Visible','on');
	set(handles.push_ok,'Enable','off');
end
 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialog_savemask wait for user response (see UIRESUME)
uiwait(hObject);


% --- Outputs from this function are returned to the command line.
function varargout = dialog_erodemask2d_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output{1};
varargout{2} = handles.output{2};
varargout{3} = handles.output{3};

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
low = str2num(get(handles.edit_rangelow,'String'));
high = str2num(get(handles.edit_rangehigh,'String'));

if radius < 1
    h = errordlg('2D Erosion radius must be at least 1');
elseif low < 1
    h = errordlg('Starting slice cannot be less than 1.');
elseif high > handles.xyzres(3)
    h = errordlg('Ending slice cannot exceed axial dimension.');
else
    handles.output{1} = get(handles.popup_mask,'Value');
    handles.output{2} = radius;
    handles.output{3} = [low high];
    
    guidata(hObject, handles);
    uiresume;
end


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;


% --- Executes when user attempts to close figure_erodemask2d.
function figure_erodemask2d_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_erodemask2d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume;



function edit_rangelow_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rangelow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rangelow as text
%        str2double(get(hObject,'String')) returns contents of edit_rangelow as a double


% --- Executes during object creation, after setting all properties.
function edit_rangelow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rangelow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rangehigh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rangehigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rangehigh as text
%        str2double(get(hObject,'String')) returns contents of edit_rangehigh as a double


% --- Executes during object creation, after setting all properties.
function edit_rangehigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rangehigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
