function varargout = dialog_mask_hist(varargin)
% DIALOG_MASK_HIST MATLAB code for dialog_mask_hist.fig
%      DIALOG_MASK_HIST, by itself, creates a new DIALOG_MASK_HIST or raises the existing
%      singleton*.
%
%      H = DIALOG_MASK_HIST returns the handle to a new DIALOG_MASK_HIST or the handle to
%      the existing singleton*.
%
%      DIALOG_MASK_HIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOG_MASK_HIST.M with the given input arguments.
%
%      DIALOG_MASK_HIST('Property','Value',...) creates a new DIALOG_MASK_HIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialog_mask_hist_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialog_mask_hist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialog_mask_hist

% Last Modified by GUIDE v2.5 11-May-2018 12:11:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialog_mask_hist_OpeningFcn, ...
                   'gui_OutputFcn',  @dialog_mask_hist_OutputFcn, ...
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


% --- Executes just before dialog_mask_hist is made visible.
function dialog_mask_hist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialog_mask_hist (see VARARGIN)

%INPUT:
% dialog_mask_hist('dummy', handles.mask_loaded, handles.mask_name, handles.mask_data...
%         handles.image_loaded handles.image_name, handles.image_data);

handles.mask_loaded = varargin{2};
handles.mask_name = varargin{3};
handles.mask_data = varargin{4};
handles.image_loaded = varargin{5};
handles.image_name = varargin{6};
handles.image_data = varargin{7};

index_mask_all = 1:length(handles.mask_loaded);
index_image_all = 1:length(handles.image_loaded);

strmask = {'Choose a Mask', handles.mask_name{handles.mask_loaded}};
strimg = {'Choose a Image', handles.image_name{handles.image_loaded}};

set(handles.popup_mask,'String',strmask,'UserData', [0 index_mask_all(handles.mask_loaded)]);
set(handles.popup_image,'String',strimg,'UserData', [0 index_image_all(handles.image_loaded)]);

% Choose default command line output for dialog_mask_hist
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialog_mask_hist wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dialog_mask_hist_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popup_mask.
function popup_mask_Callback(hObject, eventdata, handles)
% hObject    handle to popup_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_mask contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_mask

check_plot_condition(handles);


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


% --- Executes on selection change in popup_image.
function popup_image_Callback(hObject, eventdata, handles)
% hObject    handle to popup_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_image contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_image

check_plot_condition(handles);

% --- Executes during object creation, after setting all properties.
function popup_image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_saveimg.
function push_saveimg_Callback(hObject, eventdata, handles)
% hObject    handle to push_saveimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_exportdata.
function push_exportdata_Callback(hObject, eventdata, handles)
% hObject    handle to push_exportdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_holdon.
function push_holdon_Callback(hObject, eventdata, handles)
% hObject    handle to push_holdon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hold(handles.axes1,'on')

% --- Executes on button press in push_holdoff.
function push_holdoff_Callback(hObject, eventdata, handles)
% hObject    handle to push_holdoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hold(handles.axes1,'off')

% --- Executes on button press in push_clear.
function push_clear_Callback(hObject, eventdata, handles)
% hObject    handle to push_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes1);

function check_plot_condition(handles)

popup_mask_userdata = get(handles.popup_mask,'UserData');
popup_image_userdata = get(handles.popup_image,'UserData');

mask_index = popup_mask_userdata(get(handles.popup_mask,'Value'));
image_index = popup_image_userdata(get(handles.popup_image,'Value'));

if mask_index > 0 && image_index >0
    mask = logical(handles.mask_data{mask_index});
    image = handles.image_data{image_index};
    values = image(mask);
    histogram(handles.axes1,values);
end
