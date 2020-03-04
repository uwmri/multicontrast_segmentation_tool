function varargout = dialog_savemask(varargin)
% DIALOG_SAVEMASK MATLAB code for dialog_savemask.fig
%      DIALOG_SAVEMASK, by itself, creates a new DIALOG_SAVEMASK or raises the existing
%      singleton*.
%
%      H = DIALOG_SAVEMASK returns the handle to a new DIALOG_SAVEMASK or the handle to
%      the existing singleton*.
%
%      DIALOG_SAVEMASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOG_SAVEMASK.M with the given input arguments.
%
%      DIALOG_SAVEMASK('Property','Value',...) creates a new DIALOG_SAVEMASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialog_savemask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialog_savemask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialog_savemask

% Last Modified by GUIDE v2.5 01-Mar-2018 13:21:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialog_savemask_OpeningFcn, ...
                   'gui_OutputFcn',  @dialog_savemask_OutputFcn, ...
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


% --- Executes just before dialog_savemask is made visible.
function dialog_savemask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialog_savemask (see VARARGIN)

% dialog_loadimage(dummy_variable, handles.loaded_mask, handles.cMaskName)
loaded = varargin{2};
maskname = varargin{3};

% Set up listbox 
mask_number_valid = find(loaded);
mask_name_valid = maskname(loaded);
mask_string_valid = concatenate_mask_number_string(mask_number_valid, mask_name_valid);
set(handles.listbox_avail,'String',mask_string_valid,'UserData',mask_number_valid);
set(handles.listbox_avail,'Min',0,'Max',sum(loaded));
set(handles.listbox_cart,'String',{});

% Output is 1x2 cell
%handles.output{1}: An array of mask numbers to export.
%                   A value of 0 means figure closed without choice
%handles.output{2}: String specifying export format.
handles.output = cell(1,2);
handles.output{1} = 0; 

% Set up format popup menu.
format_string = {'Mat-file','Multi-mask Mat-file','Raw (float)'};
format_id = {'mat','multi','float'};
set(handles.popup_format,'String',format_string,'UserData',format_id,'Value',2);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialog_savemask wait for user response (see UIRESUME)
uiwait(handles.figure_savemask);


% --- Outputs from this function are returned to the command line.
function varargout = dialog_savemask_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on selection change in popup_format.
function popup_format_Callback(hObject, eventdata, handles)
% hObject    handle to popup_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_format


% --- Executes during object creation, after setting all properties.
function popup_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_format (see GCBO)
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

mask_cart = get(handles.listbox_cart,'UserData');
format_val = get(handles.popup_format,'Value');
format_ids = get(handles.popup_format,'UserData');
format_id = format_ids{format_val};

handles.output{1} = mask_cart
handles.output{2} = format_id

guidata(hObject, handles);
uiresume;

% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;


% --- Executes when user attempts to close figure_savemask.
function figure_savemask_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_savemask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume;


% --- Executes on selection change in listbox_avail.
function listbox_avail_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_avail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_avail contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_avail


% --- Executes during object creation, after setting all properties.
function listbox_avail_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_avail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox_cart.
function listbox_cart_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_cart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_cart contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_cart


% --- Executes during object creation, after setting all properties.
function listbox_cart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_cart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in push_add.
function push_add_Callback(hObject, eventdata, handles)
% hObject    handle to push_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%clc

val_select = get(handles.listbox_avail, 'Value');
mask_avail = get(handles.listbox_avail, 'UserData');
str_avail = get(handles.listbox_avail, 'String');

mask_cart = get(handles.listbox_cart,'UserData');

for i = 1:length(val_select)
    incart = logical(sum(mask_cart==val_select(i)));
    if ~incart
        % If selected mask is not in cart, add.
        %disp('add')
        %val_select(i)
        str_cart = get(handles.listbox_cart,'String');
        mask_cart_now = get(handles.listbox_cart,'UserData');
        str_cart_new = cat(1,str_cart,str_avail{val_select(i)});
        mask_cart_new = [mask_cart_now,mask_avail(val_select(i))];
        set(handles.listbox_cart,'String',str_cart_new);
        set(handles.listbox_cart,'UserData',mask_cart_new);
        set(handles.listbox_cart,'Value',length(mask_cart_new));
    end
end
%handles.listbox_cart.String
%handles.listbox_cart.UserData
%handles.listbox_cart.Value

% --- Executes on button press in push_remove.
function push_remove_Callback(hObject, eventdata, handles)
% hObject    handle to push_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val_cart = get(handles.listbox_cart,'Value');
str_cart = get(handles.listbox_cart,'String');
mask_cart = get(handles.listbox_cart,'UserData');

str_cart(val_cart) = []
mask_cart(val_cart) = []

set(handles.listbox_cart,'String',str_cart);
set(handles.listbox_cart,'UserData',mask_cart);
set(handles.listbox_cart,'Value',1);


% --- Executes on button press in push_up.
function push_up_Callback(hObject, eventdata, handles)
% hObject    handle to push_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val_cart = get(handles.listbox_cart,'Value');
mask_cart = get(handles.listbox_cart,'UserData');
str_cart = get(handles.listbox_cart,'String');
index = 1:length(mask_cart);

if val_cart ~= 1
    temp = index(val_cart-1);
    index(val_cart-1) = index(val_cart);
    index(val_cart) = temp;
    
    set(handles.listbox_cart,'String',str_cart(index));
    set(handles.listbox_cart,'UserData',mask_cart(index));
    set(handles.listbox_cart,'Value',val_cart - 1);
end

% --- Executes on button press in push_down.
function push_down_Callback(hObject, eventdata, handles)
% hObject    handle to push_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val_cart = get(handles.listbox_cart,'Value');
mask_cart = get(handles.listbox_cart,'UserData');
str_cart = get(handles.listbox_cart,'String');
index = 1:length(mask_cart);

if val_cart ~= length(mask_cart)
    temp = index(val_cart+1);
    index(val_cart+1) = index(val_cart);
    index(val_cart) = temp;
    
    set(handles.listbox_cart,'String',str_cart(index));
    set(handles.listbox_cart,'UserData',mask_cart(index));
    set(handles.listbox_cart,'Value',val_cart + 1);
end

function str = concatenate_mask_number_string(mask_number, mask_name)

for i = 1:length(mask_number)
    str{i} = [num2str(mask_number(i)),'. ',mask_name{i}];
end
