function varargout = dialog_arithmetics(varargin)
% DIALOG_ARITHMETICS MATLAB code for dialog_arithmetics.fig
%      DIALOG_ARITHMETICS, by itself, creates a new DIALOG_ARITHMETICS or raises the existing
%      singleton*.
%
%      H = DIALOG_ARITHMETICS returns the handle to a new DIALOG_ARITHMETICS or the handle to
%      the existing singleton*.
%
%      DIALOG_ARITHMETICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOG_ARITHMETICS.M with the given input arguments.
%
%      DIALOG_ARITHMETICS('Property','Value',...) creates a new DIALOG_ARITHMETICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialog_arithmetics_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialog_arithmetics_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialog_arithmetics

% Last Modified by GUIDE v2.5 11-May-2018 11:50:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialog_arithmetics_OpeningFcn, ...
                   'gui_OutputFcn',  @dialog_arithmetics_OutputFcn, ...
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


% --- Executes just before dialog_arithmetics is made visible.
function dialog_arithmetics_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialog_arithmetics (see VARARGIN)

% INPUT: dialog_erodemask2d('dummy', handles.loaded_mask, handles.cMaskName);
loaded = varargin{2};
cMaskName = varargin{3};

ind_allmask = 1:length(loaded); % [1 2 3 4 5]
ind_mask = ind_allmask(loaded);

str_oper = {'and','or','subtract','xor','not'};

set(handles.popup_maskA,'String',cMaskName(loaded),'UserData',ind_mask);
set(handles.popup_maskB,'String',cMaskName(loaded),'UserData',ind_mask);
set(handles.popup_oper,'UserData',str_oper);

% OUTPUT: [flag, maskA, maskB, oper]
handles.output = cell(1,4);
handles.output{1} = 0;

% Choose default command line output for dialog_arithmetics
%handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialog_arithmetics wait for user response (see UIRESUME)
uiwait(handles.figure_dialog_arithmetics);


% --- Outputs from this function are returned to the command line.
function varargout = dialog_arithmetics_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output{1};
varargout{2} = handles.output{2};
varargout{3} = handles.output{3};
varargout{4} = handles.output{4};
delete(hObject);

% --- Executes on selection change in popup_maskA.
function popup_maskA_Callback(hObject, eventdata, handles)
% hObject    handle to popup_maskA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_maskA contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_maskA


% --- Executes during object creation, after setting all properties.
function popup_maskA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_maskA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_maskB.
function popup_maskB_Callback(hObject, eventdata, handles)
% hObject    handle to popup_maskB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_maskB contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_maskB


% --- Executes during object creation, after setting all properties.
function popup_maskB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_maskB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_oper.
function popup_oper_Callback(hObject, eventdata, handles)
% hObject    handle to popup_oper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_oper contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_oper

if get(hObject,'Value') == 5
    set(handles.popup_maskB,'Enable','off');
else
    set(handles.popup_maskB,'Enable','on');
end


% --- Executes during object creation, after setting all properties.
function popup_oper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_oper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_ok.
function push_ok_Callback(hObject, eventdata, handles)
% hObject    handle to push_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maskA_list = get(handles.popup_maskA,'UserData');
maskB_list = get(handles.popup_maskB,'UserData');
oper_list = get(handles.popup_oper,'UserData');
maskA_val = get(handles.popup_maskA,'Value');
maskB_val = get(handles.popup_maskB,'Value');
oper_val = get(handles.popup_oper,'Value');

handles.output{1} = 1;
handles.output{2} = maskA_list(maskA_val);
handles.output{3} = maskB_list(maskB_val);
handles.output{4} = oper_list{oper_val};

guidata(hObject, handles);
uiresume;

% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;
