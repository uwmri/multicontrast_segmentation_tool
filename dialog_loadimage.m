function varargout = dialog_loadimage(varargin)
% DIALOG_LOADIMAGE MATLAB code for dialog_loadimage.fig
%      DIALOG_LOADIMAGE, by itself, creates a new DIALOG_LOADIMAGE or raises the existing
%      singleton*.
%
%      H = DIALOG_LOADIMAGE returns the handle to a new DIALOG_LOADIMAGE or the handle to
%      the existing singleton*.
%
%      DIALOG_LOADIMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOG_LOADIMAGE.M with the given input arguments.
%
%      DIALOG_LOADIMAGE('Property','Value',...) creates a new DIALOG_LOADIMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialog_loadimage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialog_loadimage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialog_loadimage

% Last Modified by GUIDE v2.5 04-Mar-2020 13:57:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialog_loadimage_OpeningFcn, ...
                   'gui_OutputFcn',  @dialog_loadimage_OutputFcn, ...
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


% --- Executes just before dialog_loadimage is made visible.
function dialog_loadimage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialog_loadimage (see VARARGIN)

% options.name = filename;
% options.prec{i} = handles.prec{i};
% options.xyzres = handles.xyzres;
% options.image_loaded = handles.image_loaded;
% options.flip_y = handles.flip_y;
% [name, prec, xyzres, flag] = dialog_loadimage('dummy',options);

options = varargin{2};

% set image name
[~,nameonly,~] = fileparts(options.name);
set(handles.edit_name,'String',nameonly);

% set image type
handles.prec = {'int16','uint16','int32','uint32','float','double'};
index = find(strcmp(handles.prec,options.prec));
set(handles.popup_type,'Value',index);

% set image resolution
set(handles.edit_xres,'String',num2str(options.xyzres(1)));
set(handles.edit_yres,'String',num2str(options.xyzres(2)));
set(handles.edit_zres,'String',num2str(options.xyzres(3)));

% set flip y
set(handles.chk_flip_y,'Value',options.flip_y);

% set 'Enable' property of image resolution 
if any(options.loaded)
    set(handles.edit_xres,'Enable','off');
    set(handles.edit_yres,'Enable','off');
    set(handles.edit_zres,'Enable','off');
    set(handles.chk_flip_y,'Enable','off');
end

% output fields: name,prec,xyzres,flip_y,flag
options.flag = false;
handles.output = options;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialog_loadimage wait for user response (see UIRESUME)
uiwait(handles.figure_loadimage);


% --- Outputs from this function are returned to the command line.
function varargout = dialog_loadimage_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;

delete(hObject);


% --- Executes on selection change in popup_type.
function popup_type_Callback(hObject, eventdata, handles)
% hObject    handle to popup_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_type


% --- Executes during object creation, after setting all properties.
function popup_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xres_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xres as text
%        str2double(get(hObject,'String')) returns contents of edit_xres as a double


% --- Executes during object creation, after setting all properties.
function edit_xres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_yres_Callback(hObject, eventdata, handles)
% hObject    handle to edit_yres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_yres as text
%        str2double(get(hObject,'String')) returns contents of edit_yres as a double


% --- Executes during object creation, after setting all properties.
function edit_yres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_yres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_zres_Callback(hObject, eventdata, handles)
% hObject    handle to edit_zres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_zres as text
%        str2double(get(hObject,'String')) returns contents of edit_zres as a double


% --- Executes during object creation, after setting all properties.
function edit_zres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_zres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_name_Callback(hObject, eventdata, handles)
% hObject    handle to edit_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_name as text
%        str2double(get(hObject,'String')) returns contents of edit_name as a double


% --- Executes during object creation, after setting all properties.
function edit_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_name (see GCBO)
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

% options.filename = filename;
% options.prec{i} = handles.prec{i};
% options.xyzres = handles.xyzres;
% options.image_loaded = handles.image_loaded;
% options.flip_y = handles.flip_y;
% s = dialog_loadimage('dummy',options);

xres = str2num(get(handles.edit_xres,'String'));
yres = str2num(get(handles.edit_yres,'String'));
zres = str2num(get(handles.edit_zres,'String'));

options = handles.output;
options.name = get(handles.edit_name,'String');
options.prec = handles.prec{get(handles.popup_type,'Value')};
options.xyzres = [xres yres zres];
options.flip_y = get(handles.chk_flip_y,'Value');
options.flag = true;
handles.output = options;

guidata(hObject, handles);
uiresume;



% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;
%delete(hObject);

% --- Executes when user attempts to close figure_loadimage.
function figure_loadimage_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_loadimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

uiresume;
%delete(hObject);


% --- Executes on button press in chk_flip_y.
function chk_flip_y_Callback(hObject, eventdata, handles)
% hObject    handle to chk_flip_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_flip_y
