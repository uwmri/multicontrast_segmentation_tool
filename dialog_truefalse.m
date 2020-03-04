function varargout = dialog_truefalse(varargin)
% DIALOG_TRUEFALSE MATLAB code for dialog_truefalse.fig
%      DIALOG_TRUEFALSE, by itself, creates a new DIALOG_TRUEFALSE or raises the existing
%      singleton*.
%
%      H = DIALOG_TRUEFALSE returns the handle to a new DIALOG_TRUEFALSE or the handle to
%      the existing singleton*.
%
%      DIALOG_TRUEFALSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOG_TRUEFALSE.M with the given input arguments.
%
%      DIALOG_TRUEFALSE('Property','Value',...) creates a new DIALOG_TRUEFALSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialog_truefalse_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialog_truefalse_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialog_truefalse

% Last Modified by GUIDE v2.5 11-May-2018 11:49:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialog_truefalse_OpeningFcn, ...
                   'gui_OutputFcn',  @dialog_truefalse_OutputFcn, ...
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


% --- Executes just before dialog_truefalse is made visible.
function dialog_truefalse_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialog_truefalse (see VARARGIN)

% INPUT: dialog_arithmetics('dummy', handles.mask_loaded, handles.mask_name);
loaded = varargin{2};
mask_name = varargin{3};

maskindex_all = 1:length(loaded); % [1 2 3 4 5]
maskindex_valid = maskindex_all(loaded);

str_oper = {'TP','TN','T','FP','FN','F'};

set(handles.popup_mask,'String',mask_name(loaded),'UserData',maskindex_valid);
set(handles.popup_gt,'String',mask_name(loaded),'UserData',maskindex_valid);
set(handles.popup_oper,'UserData',str_oper);

% OUTPUT: [flag, mask, gt, oper] = dialog_arithmetics....
handles.output = cell(1,4);
handles.output{1} = 0;

% Choose default command line output for dialog_truefalse
%handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialog_truefalse wait for user response (see UIRESUME)
uiwait(handles.figure_dialog_truefalse);


% --- Outputs from this function are returned to the command line.
function varargout = dialog_truefalse_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on selection change in popup_gt.
function popup_gt_Callback(hObject, eventdata, handles)
% hObject    handle to popup_gt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_gt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_gt


% --- Executes during object creation, after setting all properties.
function popup_gt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_gt (see GCBO)
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
    set(handles.popup_gt,'Enable','off');
else
    set(handles.popup_gt,'Enable','on');
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
mask_list = get(handles.popup_mask,'UserData');
gt_list = get(handles.popup_gt,'UserData');
oper_list = get(handles.popup_oper,'UserData');
mask_val = get(handles.popup_mask,'Value');
gt_val = get(handles.popup_gt,'Value');
oper_val = get(handles.popup_oper,'Value');

handles.output{1} = 1;
handles.output{2} = mask_list(mask_val);
handles.output{3} = gt_list(gt_val);
handles.output{4} = oper_list{oper_val};

guidata(hObject, handles);
uiresume;

% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;
