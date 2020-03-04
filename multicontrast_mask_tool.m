function varargout = multicontrast_mask_tool(varargin)
% MULTICONTRAST_MASK_TOOL MATLAB code for multicontrast_mask_tool.fig
%      MULTICONTRAST_MASK_TOOL, by itself, creates a new MULTICONTRAST_MASK_TOOL or raises the existing
%      singleton*.
%
%      H = MULTICONTRAST_MASK_TOOL returns the handle to a new MULTICONTRAST_MASK_TOOL or the handle to
%      the existing singleton*.
%
%      MULTICONTRAST_MASK_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTICONTRAST_MASK_TOOL.M with the given input arguments.
%
%      MULTICONTRAST_MASK_TOOL('Property','Value',...) creates a new MULTICONTRAST_MASK_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before multicontrast_mask_tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to multicontrast_mask_tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help multicontrast_mask_tool

% Last Modified by GUIDE v2.5 17-May-2019 10:26:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @multicontrast_mask_tool_OpeningFcn, ...
                   'gui_OutputFcn',  @multicontrast_mask_tool_OutputFcn, ...
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


% --- Executes just before multicontrast_mask_tool is made visible.
function multicontrast_mask_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to multicontrast_mask_tool (see VARARGIN)

% Set up array of handles for future use
handles.hObject0 = hObject;
handles.hSliceInfo = [handles.text_SliceTitle, handles.text_SliceDirection, handles.text_SliceValue];
% Image Axes related
handles.hImageAxes = [handles.axes_image1 handles.axes_image2 handles.axes_image3];
handles.hLoadButton = [handles.uipush_im1_load, handles.uipush_im2_load, handles.uipush_im3_load];
handles.hDisplayOption = [handles.uipopup_view1, handles.uipopup_view2, handles.uipopup_view3];
handles.hMIPRadius = [handles.edit_radius1, handles.edit_radius2, handles.edit_radius3];
handles.hAdjustContrast = [handles.uipush_adjust_contrast1, handles.uipush_adjust_contrast2, ...
    handles.uipush_adjust_contrast3];
handles.hContrastPanel = [handles.uipanel_im1range, handles.uipanel_im2range, handles.uipanel_im3range];
handles.hImageName = [handles.text_ImageName1, handles.text_ImageName2, handles.text_ImageName3];
% Mask panel related
handles.hMaskMenus = [handles.menu_mask_volume, handles.menu_math, handles.menu_mask_stats, ...
    handles.menu_export, handles.uitoggle_allmask, handles.uitoggle_brush, handles.toggle_localthreshold];
% Data handles
handles.image_pathname = cell(1,3);
handles.image_filename = cell(1,3);
handles.image_name = cell(1,3);
handles.image_handle = gobjects(1,3);
handles.image_data = cell(1,3);

handles.mask_data = cell(1,100);
handles.mask_name = cell(1,100);
handles.mask_note = cell(1,100);
handles.mask_alpha = 0.5*ones(1,100);
handles.mask_handle = repmat({gobjects(1,3)},100,1); % 100x1 cell array, each cell having 1x3 graphical object array

% Mask Colors
colorlist = {[1 1 0],[1 0 0],[0 1 0],[1 0 1],[0 1 1]};
handles.mask_color = repmat(colorlist,1,20);

% Undo
handles.undoMax = 100;
handles.undoCurrent = 0; %Set to 0 here. At first edit, increases to 1.
handles.undoLastEdit = 0;
handles.undoDmask = cell(1,handles.undoMax);
% Local Threshold Tool
handles.lastMaskChoice = -1; 
handles.brightblood = true(1,3); 

[handles.hContrastSlider, handles.hContrastContainer] = createImageContrastJavaSliders(handles);
[handles.hThreshSlider, handles.hThreshContainer] = createNewMaskThresholdJavaSliders(handles);
[handles.hLocalSlider, handles.hLocalContainer] = createLocalThresholdToolJavaSliders(handles);

% Load configuration file
p = mfilename('fullpath');
[path,name,ext] = fileparts(p);
filename = fullfile(path,[name,'.cfg']);
if exist(filename) == 2
    % Configuration file exists
    s= load(filename,'-mat');
    handles.xyzres = s.xyzres;
    handles.pwd = s.pwd;
    handles.prec = s.prec;
    handles.flip_y = s.flip_y;
else
    % Configuration file does not exist
    handles.xyzres = [384 384 384];
    handles.pwd = pwd;
    handles.prec = cell(1,3);
    handles.prec{1} = 'float';
    handles.prec{2} = 'float';
    handles.prec{3} = 'float';
    handles.flip_y = 1;
end

% Set up internal status variables
handles.image_loaded = false(1,3);
handles.mask_loaded = false(1,100);
handles.loaded_nm = false;
handles.viewplane = 'axial';
handles.brush_size = 5;

% Set mask list table empty
set(handles.uitable_mask,'Data',[]);

set(handles.panel_createmask, 'Visible', 'off');
update_addmaskpushbutton(handles)
linkaxes(handles.hImageAxes,'xy');

data = struct('ButtonDown',false,'AddMaskPanelOpen',false, ...
            'BrushOn',false, 'ConnectivityOn',false, ...
            'LocalThreshPanelOpen',false,'LocalThreshToolOn',false, ...
            'FillOn',false,'RectMaskOn',false);
set(hObject,'UserData',data);

% Choose default command line output for multicontrast_mask_tool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes multicontrast_mask_tool wait for user response (see UIRESUME)
% uiwait(handles.figure_masktool_main);


% --- Outputs from this function are returned to the command line.
function varargout = multicontrast_mask_tool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in uipush_im1_load.
function uipush_im1_load_Callback(hObject, eventdata, handles)
% hObject    handle to uipush_im1_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

execute_image_load_callback(hObject, 1, handles);


% --- Executes on button press in uipush_im2_load.
function uipush_im2_load_Callback(hObject, eventdata, handles)
% hObject    handle to uipush_im2_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

execute_image_load_callback(hObject, 2, handles);

% --- Executes on button press in uipush_im3_load.
function uipush_im3_load_Callback(hObject, eventdata, handles)
% hObject    handle to uipush_im3_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

execute_image_load_callback(hObject, 3, handles);



function image = load_image(pathname, filename, xyzres, prec)
fileID = fopen(fullfile(pathname,filename),'r');
image = single(fread(fileID, prod(xyzres), prec));
%image = flip(reshape(image,xyzres),1);
image = reshape(image,xyzres);
fclose(fileID);


function [Hjslider, Hjcontainer] = createImageContrastJavaSliders(handles)
hObject = handles.figure_masktool_main;
jslider1 = com.jidesoft.swing.RangeSlider(0,100,20,70); % min,max,low,high
jslider2 = com.jidesoft.swing.RangeSlider(0,100,20,70); % min,max,low,high
jslider3 = com.jidesoft.swing.RangeSlider(0,100,20,70); % min,max,low,high
[jslider1, jcontainer1] = javacomponent(jslider1, [14,6,600,44], handles.hContrastPanel(1));
[jslider2, jcontainer2] = javacomponent(jslider2, [14,6,600,44], handles.hContrastPanel(2));
[jslider3, jcontainer3] = javacomponent(jslider3, [14,6,600,44], handles.hContrastPanel(3));
set(jslider1, 'PaintTicks',true, 'PaintLabels',true, ...
     'MouseReleasedCallback',@(x,y) updateImageContrast(hObject,1,guidata(hObject)));
set(jslider2, 'PaintTicks',true, 'PaintLabels',true, ...
     'MouseReleasedCallback',@(x,y) updateImageContrast(hObject,2,guidata(hObject)));
set(jslider3, 'PaintTicks',true, 'PaintLabels',true, ...
     'MouseReleasedCallback',@(x,y) updateImageContrast(hObject,3,guidata(hObject)));
Hjslider = [jslider1, jslider2, jslider3];
Hjcontainer = [jcontainer1, jcontainer2, jcontainer3];

function updateImageContrast(hObject, axes_no, handles)
lowval = get(handles.hContrastSlider(axes_no),'Low');
highval = get(handles.hContrastSlider(axes_no),'High');
set(handles.hImageAxes(axes_no), 'CLim', [lowval highval]);


function [jslider_mask, jcontainer_mask] = createNewMaskThresholdJavaSliders(handles)
hObject = handles.figure_masktool_main;
jslider_mask = com.jidesoft.swing.RangeSlider(0,100,20,70); % min,max,low,high
[jslider_mask, jcontainer_mask] = javacomponent(jslider_mask, [154,167,420,30], handles.panel_createmask);
set(jslider_mask, 'PaintTicks',true, ...
     'MouseReleasedCallback',@(x,y) execute_addmask_slider_callback(hObject,[],guidata(hObject)));
% 'PaintTicks',true, 'PaintLabels',true, 

%--- Carries out actual image loading job, displays image, and returns 
%--- updated handle
function handles = execute_image_load_callback(hObject, i, handles)

[filename,pathname] = uigetfile(fullfile(handles.pwd,'*.*'));

if ischar(filename) && ischar(pathname)
    
    % dialog_loadimage(dummy_variable_name, filename,prec,xyzres,loaded)
    % output structure: {name,prec,xyzres,flag}
    options.name = filename;
    options.prec = handles.prec{i};
    options.xyzres = handles.xyzres;
    options.loaded = handles.image_loaded;
    options.flip_y = handles.flip_y;
    s = dialog_loadimage('dummy',options);
    %[name, prec, xyzres, flag] = dialog_loadimage('dummy',filename,handles.prec{i},handles.xyzres,handles.image_loaded);
    
    if s.flag
        % Flag is true ('Load Image' dialog terminated with user clicking ok)
        handles.image_name{i} = s.name;
        handles.prec{i} = s.prec;
        handles.xyzres = s.xyzres;
        handles.flip_y = s.flip_y;
        
        image = load_image(pathname, filename, handles.xyzres, handles.prec{i});
        if s.flip_y
            image = flip(image,1);
        end
        image = (image/max(abs(image(:))))*10000;
        handles.pwd = pathname;
        
        if ~any(handles.image_loaded)
            handles.slice = round(handles.xyzres(3)/2);
            set(handles.hSliceInfo,'Enable','on');
            set_slice_info(handles);
        end
        
        val_min = min(image(:));
        val_max = max(image(:));
        %val_max = convert_per_val(99.9, sort(image(:)));
        range = val_max - val_min;
        set(handles.hContrastSlider(i),'Minimum',val_min,'Maximum',val_max, ...
            'Low', val_min, 'High', val_max, 'MajorTickSpacing', range);
       
        blank_image = zeros(handles.xyzres([1 2]));
        handles.image_handle(i) = imshow(blank_image, ...
            'DisplayRange', [val_min val_max], 'Parent', handles.hImageAxes(i));
        
        handles.image_data{i} = image;
        
        % Update internal status variables and graphics objects
        handles.image_loaded(i) = 1;
        handles.image_pathname{i} = pathname;
        handles.image_filename{i} = filename;
        set(handles.hImageName(i),'String',handles.image_name{i});
        set(handles.hAdjustContrast(i), 'Enable', 'on');
        set(handles.hDisplayOption(i),'Enable', 'on');
        set(handles.hMIPRadius(i),'Enable', 'on');
        set(handles.hLoadButton(i),'String','Loaded','Enable','off');
        update_addmaskpushbutton(handles);
        update_image_CData(handles);
        
        guidata(hObject, handles);
    
    end
    
end

function update_image_CData(handles)

loaded = find(handles.image_loaded);

for i = loaded
    CData = generate_image_CData(i, handles);
    set(handles.image_handle(i),'CData',CData);
end


function CData = generate_image_CData(img_no, handles)

option = get(handles.hDisplayOption(img_no),'Value');
slice = handles.slice;

switch option
    case 1
        % Simple slice view
        CData = generate_slices('image',img_no,slice,handles);
    case 2
        % Total MIP
        CData = max(generate_slices('image',img_no,'all',handles),[],3);
    case 3
        % Total MinIP
        CData = min(generate_slices('image',img_no,'all',handles),[],3);
    case 4
        % Limited MIP
        radius = str2num(get(handles.hMIPRadius(img_no),'String'));
        min_slice = slice-radius;
        max_slice = slice+radius;
        end_slice = end_slice_for_view(handles);
        if min_slice < 1
            min_slice = 1;
        end
        if max_slice > end_slice
            max_slice = end_slice;
        end
        CData = max(generate_slices('image',img_no,min_slice:max_slice,handles),[],3);
    case 5
        % Limited MinIP
        radius = str2num(get(handles.hMIPRadius(img_no),'String'));
        min_slice = slice-radius;
        max_slice = slice+radius;
        end_slice = end_slice_for_view(handles);
        if min_slice < 1
            min_slice = 1;
        end
        if max_slice > end_slice
            max_slice = end_slice;
        end
        CData = min(generate_slices('image',img_no,min_slice:max_slice,handles),[],3);        
end


function CData = generate_mask_AData(msk_no, img_no, handles)

option = get(handles.hDisplayOption(img_no),'Value');
slice = handles.slice;

switch option
    case 1
        % Simple slice view
        CData = generate_slices('mask',msk_no,slice,handles);
    case {2,3}
        % Total MIP or MinIP
        proj = sum(generate_slices('mask',msk_no,'all',handles),3);
        CData = (proj>0);
    case {4,5}
        % Limited MIP or MinIP
        radius = str2num(get(handles.hMIPRadius(img_no),'String'));
        min_slice = slice-radius;
        max_slice = slice+radius;
        end_slice = end_slice_for_view(handles);
        if min_slice < 1
            min_slice = 1;
        end
        if max_slice > end_slice
            max_slice = end_slice;
        end
        proj = sum(generate_slices('mask',msk_no,min_slice:max_slice,handles),3);
        CData = (proj>0);
end

%--- Returns 2D image of the image or mask specified by num
%--- in correct viewing orientation, for slices specified by slice_no, 
%--- which can be numeric arrays specifying specific slices or string 'all'
function slices = generate_slices(type, num, slice_no, handles)

if strcmp(type,'image')
    image = handles.image_data{num};
elseif strcmp(type,'mask')
    image = handles.mask_data{num};
end

if ischar(slice_no) && strcmp(slice_no,'all')
    slice_no = 1:handles.xyzres(3);
end

%Axial view
slices = image(:,:,slice_no);


%--- Returns the maximum slice number for current viewing orientation
%--- based on the image resolution
function end_slice = end_slice_for_view(handles)
% Axial view
end_slice = handles.xyzres(3);

%--- Adds a layer for a new mask in all axes where image is loaded.
%--- Takes a uniform RGB layer of the mask as an input.
%--- Returns a 1x3 array containing handles for each mask layer image.
function Hmask = add_mask_layer(masklayer, handles)

Hmask = gobjects(1,3);

% Set up mask background in image axes
hold_axes('on',[1 2 3],handles);
for i = 1:length(handles.image_loaded)
    if handles.image_loaded(i)
        Hmask(i) = imshow(masklayer,'Parent',handles.hImageAxes(i));
    end
end
hold_axes('off',[1 2 3],handles);


%--- Generates RGB layer of specified color for displaying mask
function masklayer = generate_masklayer(color, handles)
color
r = color(1)*ones(handles.xyzres(1:2));
g = color(2)*ones(handles.xyzres(1:2));
b = color(3)*ones(handles.xyzres(1:2));
masklayer = cat(3,r,g,b);

function Hmask = execute_adding_mask_on_axes(color, mask, handles)

Hmask = gobjects(1,3);

% Generate RGB layer for mask
r = color(1)*ones(handles.xyzres(1:2));
g = color(2)*ones(handles.xyzres(1:2));
b = color(3)*ones(handles.xyzres(1:2));
masklayer = cat(3,r,g,b);

% Display flat RGB layer on all axes
hold_axes('on',[1 2 3],handles);
for i = 1:length(handles.image_loaded)
    if handles.image_loaded(i)
        Hmask(i) = imshow(masklayer,'Parent',handles.hImageAxes(i));
    end
end
hold_axes('off',[1 2 3],handles);



% --- Updates transparency AND data of specified mask
% --- Set mask_no 'all' to update for all masks
function update_mask_alphadata(mask_no, handles)


if ischar(mask_no) && strcmp(mask_no,'all')
    n = find(handles.mask_loaded,1,'last');
    mask_no = 1:n;
end

% Loop through mask
for i = mask_no
   % Loop through image axis
        for j = 1:numel(handles.image_loaded)
            % valid mask i, image j
            if handles.mask_loaded(i) && handles.image_loaded(j)
                alpha = handles.mask_alpha(i);
                AData = generate_mask_AData(i,j,handles);
                set(handles.mask_handle{i}(j), 'AlphaData', alpha*AData);
             end
        end
end


           
function mask = load_mask(pathname,filename, handles)

str_mask = load(fullfile(pathname,filename));
mask = logical(str_mask.mask);

if size(mask) ~= handles.xyzres
    error('Mask dimensions are not same as image dimensions.');
end
    

%--- Turns on/off hold on specified image axes, if loaded
function hold_axes(flag, axes_array, handles)

for i = 1:length(axes_array)
    if handles.image_loaded(i)
        hold(handles.hImageAxes(axes_array(i)),flag)
    end
end

%--- Execute the actual work of turning on/off mask 
function update_mask_visibility(mask_no, handles)

if ischar(mask_no) && strcmp(mask_no,'all')
    n_mask = length(handles.mask_loaded);
    mask_all = 1:n_mask;
    mask_no = mask_all(handles.mask_loaded);
end

image_all = [1 2 3];
image_valid = image_all(handles.image_loaded);

for n = mask_no
    
    tabledata = get(handles.uitable_mask,'Data');
    showval = tabledata{n,3};
    
    if showval
        % 'Show' checked
        set(handles.mask_handle{n}(image_valid),'Visible','on');
    else
        % 'Show' unchecked
        set(handles.mask_handle{n}(image_valid),'Visible','off');
    end
end

function source_img = prepare_mask_source(handles)

if get(handles.uiradio_add_existing, 'Value') == 1
    % An existing loaded image was chosen
    popupval = get(handles.popup_create_imgsel, 'Value');
    img_no = handles.imgchoice(popupval);
    source_img = handles.image_data{img_no};
elseif get(handles.uiradio_add_newfile, 'Value') == 1
    % An external file was chosen
    try
        filepath = get(handles.uiedit_add_newfilepath, 'String');
        
        if strcmp(filepath(end-2:end),'mat')
            % Mask mat file was chosen
            source_img = load_mask(filepath, [], handles);
        else
            % Raw image flie was chosen
            source_img = load_image(filepath, [], handles.xyzres, 'float');
        end
    catch
        error('There was an error loading the image');
    end
end


function str = generateMaskName(handles)
if get(handles.uiradio_add_existing,'Value') == 1
    img_choice_str = get(handles.popup_create_imgsel,'String');
    img_choice_val = get(handles.popup_create_imgsel,'Value');
    str = img_choice_str{img_choice_val};
elseif get(handles.uiradio_add_newfile,'Value') == 1
    fullfilepath = get(handles.uiedit_add_newfilepath,'String');
    [filepath,name,ext] = fileparts(fullfilepath);
    str = name;
end


function threshold = calc_thresh(image, mask, method, percentile)

image = image(mask);
image = sort(image);

if strcmp(method,'top')
    index = length(image) * (1 - percentile/100);
elseif strcmp(method,'bottom')
    index = length(image) * (percentile/100);
end

threshold = image(round(index));



function uiedit_debug_Callback(hObject, eventdata, handles)
% hObject    handle to uiedit_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uiedit_debug as text
%        str2double(get(hObject,'String')) returns contents of uiedit_debug as a double


% --- Executes during object creation, after setting all properties.
function uiedit_debug_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiedit_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uipush_debug.
function uipush_debug_Callback(hObject, eventdata, handles)
% hObject    handle to uipush_debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval(get(handles.uiedit_debug,'String'))



% --- Executes during object creation, after setting all properties.
function uiedit_add_color_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uiedit_add_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in uichk_show_nm.
function uichk_show_nm_Callback(hObject, eventdata, handles)
% hObject    handle to uichk_show_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of uichk_show_nm
update_mask_visibility(6, handles)

% --- Executes on button press in chk_create_usebm.
function chk_create_usebm_Callback(hObject, eventdata, handles)
% hObject    handle to chk_create_usebm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chk_create_usebm

% Change 'Enable' property of brain mask choice popup menu
if get(handles.chk_create_usebm,'Value') == 1
    % Use brain mask
    set(handles.popup_bmchoice,'Enable','on');
    % Call popup menu callback to get new brain mask based on its choice.
    % This callback saves the new brain mask, then calls slider callback
    % to display new mask.
    popup_bmchoice_Callback(hObject, eventdata, handles)
    
elseif get(handles.chk_create_usebm,'Value') == 0
    % Do not use brain mask
    set(handles.popup_bmchoice,'Enable','off');
    handles.newmask_bm = true(handles.xyzres);
    % Set brain mask to uniform true, just update mask display
    execute_addmask_slider_callback(hObject, [], handles);
end

% Call pop-up menu callback, which in turn updates brain mask based on
% the choice, saves handle, updates mask display


% --- Executes on scroll wheel click while the figure is in focus.
function figure_masktool_main_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure_masktool_main (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

userdata = get(hObject,'UserData');
modifiers = get(gcf,'currentModifier');
isCtrlOn = ismember('control',modifiers);

if ~isCtrlOn && sum(handles.image_loaded)
    handles.slice = handles.slice + eventdata.VerticalScrollCount;
    if handles.slice >= 1 && handles.slice <= handles.xyzres(3)
        set(handles.text_SliceValue,'String',num2str(handles.slice));
        update_image_CData(handles);
        update_mask_alphadata('all', handles);
        guidata(hObject, handles);
    end
elseif isCtrlOn && userdata.BrushOn
    handles.brush_size = handles.brush_size - eventdata.VerticalScrollCount;
    if handles.brush_size < 1
        handles.brush_size = 1;
    end
    deleteCircles(handles);
    [handles.hCircle, handles.hCircLines] = createCircles(handles.brush_size,handles);
    set(handles.edit_brushsize,'String',num2str(handles.brush_size));
    guidata(hObject, handles);
end


% --- Executes on button press in uipush_adjust_contrast1.
function uipush_adjust_contrast1_Callback(hObject, eventdata, handles)
% hObject    handle to uipush_adjust_contrast1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
execute_adjust_contrast_callback(1,handles);

% --- Executes on button press in uipush_adjust_contrast2.
function uipush_adjust_contrast2_Callback(hObject, eventdata, handles)
% hObject    handle to uipush_adjust_contrast2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
execute_adjust_contrast_callback(2,handles);

% --- Executes on button press in uipush_adjust_contrast3.
function uipush_adjust_contrast3_Callback(hObject, eventdata, handles)
% hObject    handle to uipush_adjust_contrast3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
execute_adjust_contrast_callback(3,handles);

function execute_adjust_contrast_callback(i,handles)
%imcontrast(handles.image_handle(i));
%handles.hImageAxes(axes_no)

hPanel = handles.hContrastPanel(i);
visible = strcmp('on',get(hPanel,'Visible'));
if visible
    set(hPanel,'Visible','off');
else
    set(hPanel,'Visible','on');
end



% --------------------------------------------------------------------
function menu_mask_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_export_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[mask_no, format] = dialog_savemask('dummy', handles.mask_loaded, handles.mask_name);

if mask_no > 0
    switch format
        case 'mat'
            [filename, pathname] = uiputfile(fullfile(handles.pwd,'*.mat'));
            if ischar(filename) && ischar(pathname)
                mask = logical(handles.mask_data{mask_no});
                if handles.flip_y
                    mask = flip(mask,1);
                end
                name = handles.mask_name{mask_no};
                note = handles.mask_note{mask_no};
                save(fullfile(pathname,filename),'mask','name','note');
            end
        case 'multi'
            [filename, pathname] = uiputfile(fullfile(handles.pwd,'*.mat'));
            if ischar(filename) && ischar(pathname)
                for i = 1:length(mask_no)
                    mask{i} = logical(handles.mask_data{mask_no(i)});
                    if handles.flip_y
                        mask{i} = flip(mask{i},1);
                    end
                    name{i} = handles.mask_name{mask_no(i)};
                    note{i} = handles.mask_note{mask_no(i)};
                end
                save(fullfile(pathname,filename),'mask','name','note','-v7.3');
            end
        case 'float'
            [filename, pathname] = uiputfile(fullfile(handles.pwd,'*.*'));
            if ischar(filename) && ischar(pathname)
                mask = double(flip(handles.mask_data{mask_no},1));
                fileID = fopen(fullfile(pathname,filename),'w');
                fwrite(fileID,mask,'float');
                fclose(fileID);
            end
    end
end


% --- Executes on selection change in uipopup_view2.
function uipopup_view2_Callback(hObject, eventdata, handles)
% hObject    handle to uipopup_view2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns uipopup_view2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uipopup_view2
execute_viewchange_callback(handles);


% --- Executes during object creation, after setting all properties.
function uipopup_view2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipopup_view2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in uipopup_view3.
function uipopup_view3_Callback(hObject, eventdata, handles)
% hObject    handle to uipopup_view3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns uipopup_view3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uipopup_view3
execute_viewchange_callback(handles);

% --- Executes during object creation, after setting all properties.
function uipopup_view3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipopup_view3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in uipopup_view1.
function uipopup_view1_Callback(hObject, eventdata, handles)
% hObject    handle to uipopup_view1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns uipopup_view1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uipopup_view1
execute_viewchange_callback(handles);


% --- Executes during object creation, after setting all properties.
function uipopup_view1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipopup_view1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function execute_viewchange_callback(handles)
update_image_CData(handles);
update_mask_alphadata('all', handles);

function execute_radiuschange_callback(handles)
robot = java.awt.Robot;
robot.keyPress    (java.awt.event.KeyEvent.VK_ENTER);
robot.keyRelease  (java.awt.event.KeyEvent.VK_ENTER);
execute_viewchange_callback(handles);

function edit_radius1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_radius1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_radius1 as text
%        str2double(get(hObject,'String')) returns contents of edit_radius1 as a double


% --- Executes during object creation, after setting all properties.
function edit_radius1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_radius1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_radius2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_radius2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_radius2 as text
%        str2double(get(hObject,'String')) returns contents of edit_radius2 as a double


% --- Executes during object creation, after setting all properties.
function edit_radius2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_radius2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_radius3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_radius3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_radius3 as text
%        str2double(get(hObject,'String')) returns contents of edit_radius3 as a double


% --- Executes during object creation, after setting all properties.
function edit_radius3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_radius3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on edit_radius1 and none of its controls.
function edit_radius1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit_radius1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
execute_radiuschange_callback(handles);


% --- Executes on key press with focus on edit_radius2 and none of its controls.
function edit_radius2_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit_radius2 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
execute_radiuschange_callback(handles);


% --- Executes on key press with focus on edit_radius3 and none of its controls.
function edit_radius3_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit_radius3 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
execute_radiuschange_callback(handles);


% --------------------------------------------------------------------
function panel_createmask_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to panel_createmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure_masktool_main_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure_masktool_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(hObject,'UserData');
data.ButtonDown = true;
% Get the axes number in which mouse was pressed.
axesnow = whichAxes(handles);

if data.AddMaskPanelOpen && inPanel(handles)
    data.LastMousePosition = get(hObject, 'CurrentPoint');
    data.LastPanelPosition = get(handles.panel_createmask, 'Position');
end

if data.BrushOn && data.ButtonDown && (axesnow>0) && handles.image_loaded(axesnow)
    % Save the mask for undo
    handles = save_mask_history(handles);
    % If mouse is pressed inside valid axes while brush is on, update mask.
    execute_brush_pressed(hObject,handles);
end

if data.ConnectivityOn && (axesnow>0) && handles.image_loaded(axesnow)
    % Get current mouse position [x,y] within the axes
    axesMousePos = get(handles.hImageAxes(axesnow),'CurrentPoint');
    x = axesMousePos(1,1);
    y = axesMousePos(1,2);
    % Save the current mask for undo
    handles = save_mask_history(handles);
    execute_connectivity_pressed(hObject, [x y], handles)
end

if data.FillOn && (axesnow>0) && handles.image_loaded(axesnow)
    % Get current mouse position [x,y] within the axes
    axesMousePos = get(handles.hImageAxes(axesnow),'CurrentPoint');
    x = axesMousePos(1,1);
    y = axesMousePos(1,2);
    % Save the current mask for undo
    handles = save_mask_history(handles);
    execute_fill_pressed(hObject, [x y], handles)
end

set(hObject,'UserData',data);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure_masktool_main_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure_masktool_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(hObject,'UserData');
data.ButtonDown = false;
set(hObject,'UserData',data);

       
        

function value = inPanel(handles)
hPanel = handles.panel_createmask;
hFigure = handles.figure_masktool_main;
pos_panel = get(hPanel, 'Position');
pos_mouse = get(hFigure, 'CurrentPoint');
x0 = pos_panel(1);    x1 = pos_panel(1)+pos_panel(3);
y0 = pos_panel(2);    y1 = pos_panel(2)+pos_panel(4);
xc = pos_mouse(1);    yc = pos_mouse(2);
value = (xc >= x0) & (xc <= x1) & (yc >= y0) & (yc <= y1);


% --- Executes on button press in radio_MultiContrastView.
function radio_MultiContrastView_Callback(hObject, eventdata, handles)
% hObject    handle to radio_MultiContrastView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_MultiContrastView


% --- Executes on button press in radio_MultiPlaneView.
function radio_MultiPlaneView_Callback(hObject, eventdata, handles)
% hObject    handle to radio_MultiPlaneView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_MultiPlaneView




% --- Executes on mouse press over figure background.
function figure_masktool_main_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure_masktool_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function uiedit_add_color_Callback(hObject, eventdata, handles)
% hObject    handle to uiedit_add_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uiedit_add_color as text
%        str2double(get(hObject,'String')) returns contents of uiedit_add_color as a double

function set_slice_info(handles)
set(handles.text_SliceValue,'String',num2str(handles.slice));
switch handles.viewplane
    case 'axial'
        str = 'Axial';
    case 'coronal'
        str = 'Coronal';
    case 'sagittal'
        str = 'Sagittal';
end
set(handles.text_SliceDirection,'String',str);



% --- Executes when user attempts to close figure_masktool_main.
function figure_masktool_main_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_masktool_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%save('handles.xyzres = [384 384 384];
p = mfilename('fullpath');
[path,name,ext] = fileparts(p);
filename = fullfile(path,[name,'.cfg']);
save(filename,'-struct','handles','pwd','prec','xyzres','flip_y');
% Hint: delete(hObject) closes the figure
delete(hObject);



% --------------------------------------------------------------------
function uitoggle_brush_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggle_brush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject0 = handles.figure_masktool_main;
data = get(hObject0,'UserData');
data.BrushOn = false;
set(hObject0,'UserData',data);

% Make Brush Options panel visible
set(handles.panel_brush,'Visible','off');

deleteCircles(handles);
guidata(hObject,handles);

% --------------------------------------------------------------------
function uitoggle_brush_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggle_brush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set BrusnOn to true
hObject0 = handles.figure_masktool_main;
data = get(hObject0,'UserData');
data.BrushOn = true;
set(hObject0,'UserData',data);

% Make Brush Options panel visible
set(handles.panel_brush,'Visible','on');

% Display brush size in edit box
set(handles.edit_brushsize,'String',num2str(handles.brush_size));

% Populate pop-up menu with valid masks
populate_masks_in_popupmenu(handles.popup_brush_mask, handles);

% Create circles in axes
[handles.hCircle, handles.hCircLines] = createCircles(handles.brush_size,handles);
guidata(hObject,handles);

%--- Populates popup menu with valid existing masks
function populate_masks_in_popupmenu(popup_handle, handles)
ind_allmask = 1:length(handles.mask_loaded); % [1 2 3 4 5]
str_masks = cat(2,{'Choose a mask'}, handles.mask_name(handles.mask_loaded));
ind_masks = [0 ind_allmask(handles.mask_loaded)];
set(popup_handle,'String',str_masks,'UserData',ind_masks);


% --- Executes on mouse motion over figure - except title and menu.
function figure_masktool_main_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure_masktool_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

userdata = get(hObject,'UserData');

% Current axes number that mouse is in. 0 if none.
axesnow = whichAxes(handles);

if userdata.AddMaskPanelOpen && userdata.ButtonDown && inPanel(handles)
    % Mouse dragging 'New Mask' panel while open.
        CurrentMousePosition = get(hObject, 'CurrentPoint');
        ChangeMousePosition = CurrentMousePosition - userdata.LastMousePosition;
        
        NewPanelPosition = userdata.LastPanelPosition + [ChangeMousePosition 0 0];
        set(handles.panel_createmask,'Position',NewPanelPosition);
end

% Execute if Local Threshold Tool is on
if userdata.LocalThreshToolOn && ~userdata.LocalThreshPanelOpen
    roiOn = handles.toggle_localthreshold.UserData;
    if axesnow && handles.image_loaded(axesnow)
        % If on a valid axes,
        if ~roiOn
            % and ROI is off, activate ROI.
            handles.toggle_localthreshold.UserData = true;
            disp('Active ROI')
            handles.hROI = imrect(handles.hImageAxes(axesnow));
            % Once imrect is activated, the process stops at imrect until
            % ROI is completed. Process proceeds once ROI is made.
            % If imrect process is terminated by ESC keypress,
            % the rest of the code is executed without hROI created.
            if isvalid(handles.hROI)
                disp('activate panel')
                activate_local_threshold_panel(axesnow, handles);
            end
        end
    else
        % If outside valid axes,
        if roiOn
            % and ROI is on, deactivate ROI.
            handles.toggle_localthreshold.UserData = false;
            disp('Deactivate ROI')
            robot = java.awt.Robot;
            robot.keyPress    (java.awt.event.KeyEvent.VK_ESCAPE);
            robot.keyRelease  (java.awt.event.KeyEvent.VK_ESCAPE);
        end
    end
end

% Execute if Paint Brush is on
if userdata.BrushOn
    if (axesnow > 0) && handles.image_loaded(axesnow)
        % Update circle positions, if mouse is inside axes.
            % Make mouse pointer crosshair
            set(hObject,'Pointer','crosshair');
            % Get current mouse position [x,y] within the axes
            axesMousePos = get(handles.hImageAxes(axesnow),'CurrentPoint');
            x = axesMousePos(1,1);
            y = axesMousePos(1,2);

            % Translate the original line data by [x,y]
            userdata0 = get(handles.hCircle(axesnow),'UserData');
            XData1 = userdata0.XData1 + x;
            XData2 = userdata0.XData2 + x;
            YData1 = userdata0.YData1 + y;
            YData2 = userdata0.YData2 + y;

            % Update new line data
            other_loaded_image = handles.image_loaded;
            other_loaded_image(axesnow) = false;
            
            set(handles.hCircle(axesnow),'Visible','on');
            set(handles.hCircle(other_loaded_image),'Visible','off');
            set(handles.hCircLines{axesnow}(1),'XData',XData1,'YData',YData1);
            set(handles.hCircLines{axesnow}(2),'XData',XData2,'YData',YData2);
        % If mouse is clicked, update the mask too.
            if userdata.ButtonDown
                execute_brush_pressed(hObject,handles);
            end
    else
        % Set mouse pointer to arrow
        set(hObject,'Pointer','arrow');
        % Turn off circle visibility, if mouse outside axes
        set(handles.hCircle(handles.image_loaded),'Visible','off');
    end
end

% Execute if connectivity or fill tool is on
if userdata.ConnectivityOn || userdata.FillOn
    if (axesnow > 0) && handles.image_loaded(axesnow)
        % Set mouse pointer to crosshair
        set(hObject,'Pointer','crosshair');
    else
        % Set mouse pointer to arrow
        set(hObject,'Pointer','arrow');
    end
end




function execute_brush_pressed(hObject, handles)

% Get current mouse position
axesnow = whichAxes(handles);
axesMousePos = get(handles.hImageAxes(axesnow),'CurrentPoint');
xc = axesMousePos(1,1);
yc = axesMousePos(1,2);
% Create a mask of painted area
[row, col] = return_display_dimension(handles);
[x, y] = meshgrid(1:col,1:row);
painted = (sqrt((x-xc).^2 + (y-yc).^2) <= handles.brush_size);
% Mask to paint
ind_allmask = get(handles.popup_brush_mask,'UserData');
ind_mask = ind_allmask(get(handles.popup_brush_mask,'Value'));

if ind_mask ~= 0
    % Update mask data
    if strcmp(handles.viewplane,'axial')
        % Axial view
        if get(handles.radio_paint_add,'Value') == 1
            % Draw mode
            size(painted)
            handles.mask_data{ind_mask}(:,:,handles.slice) = ...
                logical(handles.mask_data{ind_mask}(:,:,handles.slice) + painted);
        elseif get(handles.radio_paint_erase,'Value') == 1
            % Erase mode
            handles.mask_data{ind_mask}(:,:,handles.slice) = ...
                logical((handles.mask_data{ind_mask}(:,:,handles.slice) - painted)>0);
        end
    end
    % Update mask display
    update_mask_alphadata(ind_mask,handles);
    guidata(hObject, handles);
end
 

function [row, col] = return_display_dimension(handles)
if strcmp(handles.viewplane,'axial')
    row = handles.xyzres(1);
    col = handles.xyzres(2);
end

%--- Creates circles of specified radius in all loaded axes, at [0,0].
%--- Returns the handles for each circle, and its two children lines.
%--- Saves the initial XData, YData of the lines in property 'UserData' of
%--- the circle handle.
function [hCircle, hCircLines] = createCircles(radius, handles)

%  Set default radius if 'default'
%if ischar(radius) && strcmp(radius,'default')
%    radius = 5;
%end

hCircle = gobjects(1,3);
hCircLines = cell(1,3);

for i = find(handles.image_loaded)
    
    axesnow = whichAxes(handles);
    if axesnow
        % If mouse is within axes, create new circle around mouse point.
        axesMousePos = get(handles.hImageAxes(axesnow),'CurrentPoint');
        x = axesMousePos(1,1);
        y = axesMousePos(1,2);
        hCircle(i) = viscircles(handles.hImageAxes(i), [x y], radius, 'LineWidth', 1);
        set(hCircle(i),'Visible','on');
        hCircLines{i} = allchild(hCircle(i));
        userdata.XData1 = hCircLines{i}(1).XData-x;
        userdata.YData1 = hCircLines{i}(1).YData-y;
        userdata.XData2 = hCircLines{i}(2).XData-x;
        userdata.YData2 = hCircLines{i}(2).YData-y;
        set(hCircle(i),'UserData',userdata);
    else
        % If mouse is off axes, create new circle around [0 0].
        hCircle(i) = viscircles(handles.hImageAxes(i), [0 0], radius, 'LineWidth', 1);
        set(hCircle(i),'Visible','off');
        hCircLines{i} = allchild(hCircle(i));
        userdata.XData1 = hCircLines{i}(1).XData;
        userdata.YData1 = hCircLines{i}(1).YData;
        userdata.XData2 = hCircLines{i}(2).XData;
        userdata.YData2 = hCircLines{i}(2).YData;
        set(hCircle(i),'UserData',userdata);
    end
end

function deleteCircles(handles)
for i = find(handles.image_loaded)
    delete(handles.hCircle(i));
end

% Returns the axes number with mouse on, or 0 if none.
function axes_no = whichAxes(handles)
hObject0 = handles.figure_masktool_main;
% Current mouse position
xcyc = get(hObject0, 'CurrentPoint');
% 3x4 array of Position values
xywh = cell2mat(get(handles.hImageAxes,'Position'));
result = ((xywh(:,1)<xcyc(1)) & (xywh(:,2)<xcyc(2)) & ...
    (xywh(:,1)+xywh(:,3))>xcyc(1) & ...
    (xywh(:,2)+xywh(:,4))>xcyc(2));
if result(1)
    axes_no = 1;
elseif result(2)
    axes_no = 2;
elseif result(3)
    axes_no = 3;
else
    axes_no = 0;
end



function edit_brushsize_Callback(hObject, eventdata, handles)
% hObject    handle to edit_brushsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_brushsize as text
%        str2double(get(hObject,'String')) returns contents of edit_brushsize as a double


% --- Executes during object creation, after setting all properties.
function edit_brushsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_brushsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function uitoggle_allmask_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggle_allmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%{
n_mask = length(handles.mask_loaded);

image_all = [1 2 3];
image_valid = image_all(handles.image_loaded);

mask_all = 1:n_mask;
mask_valid = mask_all(handles.mask_loaded);

handles.showValSaved = cell2mat(get(handles.Huichk_mask_show,'Value'));


for i = mask_valid
    set(handles.Huichk_mask_show(i),'Value',0);
    set(handles.Huichk_mask_show(i),'Enable','off');
    set(handles.mask_handle{i}(image_valid),'Visible','off');
end
%update_mask_alphadata('all',handles);
guidata(hObject, handles);
%}

% --------------------------------------------------------------------
function uitoggle_allmask_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggle_allmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%{
n_mask = length(handles.mask_loaded);

image_all = [1 2 3];
image_valid = image_all(handles.image_loaded);

mask_all = 1:n_mask;
mask_show = transpose(logical(handles.showValSaved));
mask_valid = mask_all(handles.mask_loaded);

for i = mask_valid
    set(handles.Huichk_mask_show(i),'Enable','on');
    set(handles.Huichk_mask_show(i),'Value',handles.showValSaved(i));
    if handles.showValSaved(i)
        set(handles.mask_handle{i}(image_valid),'Visible','on');
    else
        set(handles.mask_handle{i}(image_valid),'Visible','off');
    end
end
%update_mask_alphadata('all',handles);
%guidata(hObject, handles);
%}

% --- Executes on key press with focus on figure_masktool_main or any of its controls.
function figure_masktool_main_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure_masktool_main (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

%{
if any(handles.image_loaded)
    if strcmp(eventdata.Key,'m')
        if strcmp(get(handles.uitoggle_allmask,'State'),'off')
            % on callback
            set(handles.uitoggle_allmask,'State','on');
        elseif strcmp(get(handles.uitoggle_allmask,'State'),'on')
            % off callback
            set(handles.uitoggle_allmask,'State','off');
        end
    end
end
%}




% --------------------------------------------------------------------
function menu_math_Callback(hObject, eventdata, handles)
% hObject    handle to menu_math (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_mask_volume_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_volume_3Derosion_Callback(hObject, eventdata, handles)
% hObject    handle to menu_volume_3Derosion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[i, radius] = dialog_erodemask3d('dummy', handles.mask_loaded, handles.mask_name);
% i is the mask number

if i > 0
    % Carry out erosion
    newmask = imerode(handles.mask_data{i}, strel('cube',radius));
    % Add mask
    options.name = [handles.mask_name{i},'_eroded'];
    execute_add_newmask(newmask, options, handles);
end


% --------------------------------------------------------------------
function menu_volume_2Derosion_Callback(hObject, eventdata, handles)
% hObject    handle to menu_volume_2Derosion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function varargout = execute_add_newmask(mask, options, handles)

% Get the next available mask number
n = find(~handles.mask_loaded,1,'first');

% Determine name
if isstruct(options) && isfield(options,'name')
    name = options.name;
else
    name = ['Mask ',num2str(n)];
end
% Determine note
if isstruct(options) && isfield(options,'note')
    note = options.note;
else
    note = {''};
end

% Use default color.
color = handles.mask_color{n};

% Update internal variables
hObject = handles.figure_masktool_main;
handles.mask_loaded(n) = true;
handles.mask_data{n} = logical(mask);
handles.mask_name{n} = name;
handles.mask_note{n} = note;

% Add mask on table
spacing = repmat('&nbsp',1,10);
colortext = ['<html><body bgcolor="',rgb2hex(color),'">',spacing,'</body></html>'];
tabledata = get(handles.uitable_mask,'Data');
tabledata = cat(1,tabledata,{name, colortext, true});
set(handles.uitable_mask,'Data',tabledata);

% Add mask on all axes
handles.mask_handle{n} = execute_adding_mask_on_axes(color, mask, handles);
% Update mask, both data and transparency
update_mask_alphadata(n, handles);

% Check whether mask menus should be enabled or not
set_maskmenus_enable(handles);

% Save handle or output handle
if nargout == 0
    guidata(hObject, handles);
else
    varargout{1} = handles;
end

function hexcolor = rgb2hex(rgbcolor)
rgbcolor = round(255*rgbcolor);
R = dec2hex(rgbcolor(1),2);
G = dec2hex(rgbcolor(2),2);
B = dec2hex(rgbcolor(3),2);
hexcolor = ['#',R,G,B];


function varargout = update_maskinfo(n,options,handles)

if isfield(options,'name')
    handles.mask_name{n} = options.name;
    
    tabledata = get(handles.uitable_mask,'Data');
    tabledata{n,1} = options.name;
    set(handles.uitable_mask,'Data',tabledata);
end
if isfield(options,'note')
    handles.mask_note{n} = options.note;
end

if isfield(options,'appendnote')
    handles.mask_note{n} = cat(1,handles.mask_note{n},options.appendnote);
end

if isfield(options,'alpha')
    handles.mask_alpha(n) = options.alpha;
    update_mask_alphadata(n, handles);
end

% Save handle or output handle
if nargout == 0
    guidata(handles.hObject0, handles);
else
    varargout{1} = handles;
end

function varargout = delete_mask(n, handles)

% Delete entry from table
tabledata = get(handles.uitable_mask,'Data');
tabledata(n,:) = [];
set(handles.uitable_mask,'Data',tabledata);

% Delete mask handle
delete(handles.mask_handle{n});

% Update internal variable
handles.mask_loaded(n) = false;

% Save handle or output handle
if nargout == 0
    guidata(handles.hObject0, handles);
else
    varargout{1} = handles;
end



function set_maskmenus_enable(handles)
if sum(handles.mask_loaded) == 0
    set(handles.hMaskMenus,'Enable','off');
else
    set(handles.hMaskMenus,'Enable','on');
end


% --------------------------------------------------------------------
function menu_2Derode_slice_Callback(hObject, eventdata, handles)
% hObject    handle to menu_2Derode_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Find which masks are visible
tabledata = get(handles.uitable_mask,'Data');
mask = find([tabledata{:,3}]);

if ~any(mask)
    h = errordlg('You must show a mask for this operation');
else
    % Save the current mask for undo
    handles = save_mask_history(handles);
    
    se = strel('disk',1);
    
    for i = mask
        handles.mask_data{i}(:,:,handles.slice) = imerode(handles.mask_data{i}(:,:,handles.slice), se);
        update_mask_alphadata(i,handles);
    end
    guidata(hObject,handles);    
end


% --------------------------------------------------------------------
function menu_2Derosion_Callback(hObject, eventdata, handles)
% hObject    handle to menu_2Derosion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[i, radius, range] = dialog_erodemask2d('dummy', handles.mask_loaded, handles.mask_name, handles.xyzres);
% i is the mask number

if i > 0
    % Carry out erosion
    newmask = handles.mask_data{i};
    se = strel('disk',radius);
    for slice = range(1):range(2)
        newmask(:,:,slice) = imerode(newmask(:,:,slice), se);
    end
    
    options.name = [handles.mask_name{i},'_eroded'];
    
    execute_add_newmask(newmask, options, handles);
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_debug_show_Callback(hObject, eventdata, handles)
% hObject    handle to menu_debug_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_mask_stats_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_mask_hist_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_hist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dialog_mask_hist('dummy', handles.mask_loaded, handles.mask_name, handles.mask_data, ...
    handles.image_loaded, handles.image_name, handles.image_data);


% --------------------------------------------------------------------
function menu_debug_color_Callback(hObject, eventdata, handles)
% hObject    handle to menu_debug_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_connectivity_Callback(hObject, eventdata, handles)
% hObject    handle to menu_connectivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update UserData to indicate Connectivity Panel is open
hObject0 = handles.figure_masktool_main;
UserData = get(hObject0,'UserData');
UserData.ConnectivityOn = true;
set(hObject0,'UserData',UserData);

% Open and initialize Connectivity Panel
set(handles.panel_connectivity,'Visible','on');
set(handles.radio_conn_add,'Value',1);
popup_conn_dim_Callback(handles.popup_conn_dim, [], handles);
set(handles.chk_conn_showtarget,'Value',1);
update_conn_popup_string(handles);
set(handles.popup_conn_source,'Value',1);
set(handles.popup_conn_target,'Value',1);
% Set all masks invisible.
%set(handles.Huichk_mask_show,'Value',0);
update_mask_visibility('all',handles);

guidata(hObject, handles);

% --- Executes on button press in push_conn_close.
function push_conn_close_Callback(hObject, eventdata, handles)
% hObject    handle to push_conn_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update UserData to indicate Connectivity Panel is open
hObject0 = handles.figure_masktool_main;
UserData = get(hObject0,'UserData');
UserData.ConnectivityOn = false;
set(hObject0,'UserData',UserData);

set(handles.panel_connectivity,'Visible','off');

% Set mouse pointer to arrow
set(handles.figure_masktool_main,'Pointer','arrow');

% --- Executes on button press in radio_conn_remove.
function radio_conn_remove_Callback(hObject, eventdata, handles)
% hObject    handle to radio_conn_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radio_conn_remove
update_conn_popup_string(handles);

% --- Executes on button press in radio_conn_add.
function radio_conn_add_Callback(hObject, eventdata, handles)
% hObject    handle to radio_conn_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radio_conn_add
update_conn_popup_string(handles);

function update_conn_popup_string(handles)

ind_allmask = 1:length(handles.mask_loaded); % [1 2 3 4 5]

if get(handles.radio_conn_add,'Value') == 1
    % Get the next available mask number
    n = find(~handles.mask_loaded(1:5),1,'first');
    if isempty(n)
        % Mask full
        str_target = cat(2,{'Choose a mask'}, handles.mask_name(handles.mask_loaded));
        ind_target = [0 ind_allmask(handles.mask_loaded)];
    else
        % Mask not full
        str_target = cat(2,{'Add as a new Mask'}, handles.mask_name(handles.mask_loaded));
        ind_target = [0 ind_allmask(handles.mask_loaded)];
    end
elseif get(handles.radio_conn_remove,'Value') == 1
        % Only existing masks
        str_target = cat(2,{'Choose a mask'}, handles.mask_name(handles.mask_loaded));
        ind_target = [0 ind_allmask(handles.mask_loaded)];
end

str_source = cat(2,{'Choose a mask'}, handles.mask_name(handles.mask_loaded));
ind_source = [0 ind_allmask(handles.mask_loaded)];

set(handles.popup_conn_source,'String',str_source,'UserData',ind_source);
set(handles.popup_conn_target,'String',str_target,'UserData',ind_target);


% --- Executes on selection change in popup_conn_source.
function popup_conn_source_Callback(hObject, eventdata, handles)
% hObject    handle to popup_conn_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_conn_source contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_conn_source
update_conn_mask_visibility(handles);

function update_conn_mask_visibility(handles)

n_mask = length(handles.mask_loaded);
bool_allmask = false(1,n_mask); % [0 0 0 0 0]

ind_allsource = get(handles.popup_conn_source, 'UserData');
ind_alltarget = get(handles.popup_conn_target, 'UserData');
val_source = get(handles.popup_conn_source, 'Value');
val_target = get(handles.popup_conn_target, 'Value');
ind_source = ind_allsource(val_source);
ind_target = ind_alltarget(val_target);

if ind_source ~= 0  
    bool_allmask(ind_source) = true;
end
if ind_target ~=0
    bool_allmask(ind_target) = true;
end

%{
for i = 1:n_mask
    set(handles.Huichk_mask_show(i), 'Value', bool_allmask(i));
end
%}
%update_mask_visibility('all', handles)

% --- Executes during object creation, after setting all properties.
function popup_conn_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_conn_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_conn_val.
function popup_conn_val_Callback(hObject, eventdata, handles)
% hObject    handle to popup_conn_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_conn_val contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_conn_val


% --- Executes during object creation, after setting all properties.
function popup_conn_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_conn_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_conn_target.
function popup_conn_target_Callback(hObject, eventdata, handles)
% hObject    handle to popup_conn_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_conn_target contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_conn_target


% --- Executes during object creation, after setting all properties.
function popup_conn_target_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_conn_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_conn_dim.
function popup_conn_dim_Callback(hObject, eventdata, handles)
% hObject    handle to popup_conn_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_conn_dim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_conn_dim
contents = cellstr(get(hObject,'String'));
dimension = contents{get(hObject,'Value')};
choice2d = [4 8];
choice3d = [6 18 26];
if strcmp(dimension,'2D')
    set(handles.popup_conn_val,'String',num2cell(choice2d),'UserData',choice2d,'Value',2);
    set(handles.chk_conn_diffslice,'Value',0);
    set(handles.chk_conn_diffslice,'Enable','on');
    set(handles.edit_conn_diffslice,'Enable','off');
    set(handles.edit_conn_diffslice,'String',num2str(handles.slice));
elseif strcmp(dimension,'3D')
    set(handles.popup_conn_val,'String',num2cell(choice3d),'UserData',choice3d,'Value',3);
    set(handles.chk_conn_diffslice,'Enable','off');
    set(handles.edit_conn_diffslice,'Enable','off');
end
  

% --- Executes during object creation, after setting all properties.
function popup_conn_dim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_conn_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_conn_showtarget.
function chk_conn_showtarget_Callback(hObject, eventdata, handles)
% hObject    handle to chk_conn_showtarget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_conn_showtarget

function execute_connectivity_pressed(hObject, eventdata, handles)
% hObject    handle to figure_
% eventdata  coordinate [x y] of mouse press within axes
x = round(eventdata(1));
y = round(eventdata(2));
val_source = get(handles.popup_conn_source,'Value');
val_target = get(handles.popup_conn_target,'Value');
indlist_source = get(handles.popup_conn_source,'UserData');
indlist_target = get(handles.popup_conn_target,'UserData');
ind_source = indlist_source(val_source);
ind_target = indlist_target(val_target);
dim_contents = cellstr(get(handles.popup_conn_dim,'String'));
dimension = dim_contents{get(handles.popup_conn_dim,'Value')};
conn_contents = cellstr(get(handles.popup_conn_val,'String'));
conn_val = str2num(conn_contents{get(handles.popup_conn_val,'Value')});

val_xy = handles.mask_data{ind_source}(y,x,handles.slice);

if val_xy == true
    
    if strcmp(dimension,'2D')
        %2D connectivity
        if get(handles.chk_conn_diffslice,'Value') == 0
            mask0 = handles.mask_data{ind_source}(:,:,handles.slice); % Generalize later
            mask_labeled = bwlabeln(mask0, conn_val);
            label = mask_labeled(y,x); % Generalize later
            mask_slice = (mask_labeled == label);
            mask  = false(handles.xyzres);
            mask(:,:,handles.slice) = mask_slice; % Generalize later
        elseif get(handles.chk_conn_diffslice,'Value') == 1
            target_slice = str2num(get(handles.edit_conn_diffslice,'String'));
            mask0 = handles.mask_data{ind_source}(:,:,handles.slice); % Generalize later
            mask_labeled = bwlabeln(mask0, conn_val);
            label = mask_labeled(y,x); % Generalize later
            mask_slice = (mask_labeled == label);
            mask  = false(handles.xyzres);
            mask(:,:,target_slice) = mask_slice; % Generalize later
        end
        

    elseif strcmp(dimension,'3D')
        %3D connectivity
        mask0 = handles.mask_data{ind_source}; % Generalize later
        mask_labeled = bwlabeln(mask0, conn_val);
        label = mask_labeled(y,x, handles.slice); % Generalize later
        mask = (mask_labeled == label);
    end
    
    if ind_target == 0
        % Radiobutton : 'Add to mask'
        % Popupmenu: 'Add as a new mask'
        i = ind_source;
        options.name = [handles.mask_name{i},'_connectivity'];
        handles = execute_add_newmask(mask, options, handles);
    else
        % Radiobutton: 'Add to mask' or 'Remove from mask'
        % Popupmenu: choice of an existing mask
        if get(handles.radio_conn_add,'Value') == 1
            % Radibutton: 'Add to mask'
            handles.mask_data{ind_target} = (handles.mask_data{ind_target} | mask);
        elseif get(handles.radio_conn_remove,'Value') == 1
            % Radibutton: 'Remove from mask'
            handles.mask_data{ind_target} = ((handles.mask_data{ind_target} - mask)>0);
        end
    end
    
    guidata(hObject, handles);
    update_mask_alphadata('all',handles);
    update_conn_popup_string(handles);
    
end



function handles = save_mask_history(handles)

if handles.undoCurrent == handles.undoMax
    handles.undoCurrent = 1;
    handles.undoLastEdit = 1;
else
    handles.undoCurrent = handles.undoCurrent + 1;
    handles.undoLastEdit = handles.undoCurrent;
end

handles.undoDmask{handles.undoCurrent} = handles.mask_data;

disp(['Current:',num2str(handles.undoCurrent)])
disp(['LastEdit:',num2str(handles.undoLastEdit)])

% --------------------------------------------------------------------
function menu_mask_undo_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp(['Current:',num2str(handles.undoCurrent)])
disp(['LastEdit:',num2str(handles.undoLastEdit)])

if handles.undoLastEdit == (handles.undoCurrent - 1)
    beep;
    h = errordlg('You reached the end of saved mask history.');
else
    if (handles.undoCurrent == 1) && ~(handles.undoLastEdit == 1)
        handles.undoCurrent = 100;
    else
        handles.undoCurrent = handles.undoCurrent - 1;
    end
    handles.mask_data = handles.undoDmask{handles.undoCurrent};
    update_mask_alphadata('all',handles);
    guidata(hObject, handles);
end


% --- Executes on selection change in popup_local_source.
function popup_local_source_Callback(hObject, eventdata, handles)
% hObject    handle to popup_local_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_local_source contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_local_source
hObject = handles.popup_local_source;
ind_source = get(hObject,'UserData');
val_source = get(hObject,'Value');
image_no = ind_source(val_source);

% Set all java sliders invisible, except for image of choice.
set(handles.hLocalContainer,'Visible','off');
set(handles.hLocalContainer(image_no),'Visible','on');

% Set initial slider values
initialize_localthreshold_javasliders(image_no, handles);

% Execute slider callback
hObject0 = handles.figure_masktool_main;
execute_localthresh_slider_callback(hObject0,image_no,guidata(hObject0))

function execute_localthresh_slider_callback(hObject, image_no, handles)
userdata = get(handles.panel_localthreshold,'UserData');
slice = userdata.slice{image_no};

low = get(handles.hLocalSlider(image_no),'Low');
high = get(handles.hLocalSlider(image_no),'High');

mask = (slice >= low) & (slice <= high);

for i = find(handles.image_loaded)
    set(userdata.hMask(i),'AlphaData',mask);
end

disp(['Max:',num2str(max(slice(:)))]);
disp(['Low:',num2str(low)]);
disp(['High:',num2str(high)]);
disp(['Min:',num2str(get(handles.hLocalSlider(image_no),'Minimum'))]);
disp(['Max:',num2str(get(handles.hLocalSlider(image_no),'Maximum'))]);

set(handles.text_local_N,'String',['N=',num2str(sum(mask(:)))]);



function initialize_localthreshold_javasliders(image_no, handles)
userdata = get(handles.panel_localthreshold,'UserData');
slice = userdata.slice{image_no};
minval = min(slice(:));
maxval = ceil(max(slice(:)));
if handles.brightblood(image_no)
    % If brightblood image, set both thresholds at max
    lowval = maxval;
    highval = maxval;
else
    % If darkblood image, set both thresholds at min
    lowval = minval;
    highval = minval;
end
set(handles.hLocalSlider(image_no),'Minimum',minval,'Maximum',maxval, ...
        'Low', lowval, 'High', highval);

    
% --- Executes during object creation, after setting all properties.
function popup_local_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_local_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_local_target.
function popup_local_target_Callback(hObject, eventdata, handles)
% hObject    handle to popup_local_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_local_target contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_local_target
if get(handles.popup_local_target,'Value') == 1
    set(handles.push_local_ok,'Enable','off');
else
    set(handles.push_local_ok,'Enable','on');
end

% --- Executes during object creation, after setting all properties.
function popup_local_target_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_local_target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function toggle_localthreshold_OnCallback(hObject, eventdata, handles)
% hObject    handle to toggle_localthreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Turn on the panel
hObject0 = handles.figure_masktool_main;
userdata = get(hObject0,'UserData');
userdata.LocalThreshToolOn = true;
set(hObject0,'UserData',userdata);

% Local Threshold tool uses UserData of the the Local Threshold Tool toggle
% button as a boolian indicator of whether interactive ROI (imreact) is on.
% Initialize ROI indicator to 'false'.
handles.toggle_localthreshold.UserData = false;


% --------------------------------------------------------------------
function toggle_localthreshold_OffCallback(hObject, eventdata, handles)
% hObject    handle to toggle_localthreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Turn off LocalToolOn indicator, turn off panel if open.
hObject0 = handles.figure_masktool_main;
userdata = get(hObject0,'UserData');
if userdata.LocalThreshPanelOpen
    push_local_cancel_Callback(hObject, eventdata, handles)
end
userdata.LocalThreshToolOn = false;
set(hObject0,'UserData',userdata);

function activate_local_threshold_panel(axes_no, handles)
% handles.hROI  handle to imrect ROI selection
% axes_no       axes number indicating which image ROI was drawn

% Calculate ROI dimensions
xywh = getPosition(handles.hROI);
x0 = ceil(xywh(1));
y0 = ceil(xywh(2));
x1 = x0 + floor(xywh(3));
y1 = y0 + floor(xywh(4));
xres = x1 - x0 + 1;
yres = y1 - y0 + 1;

% Prepare handles and variables to be saved
userdata.xlim = [x0 x1];
userdata.ylim = [y0 y1];
userdata.res = [yres xres];
userdata.slice = cell(1,3);
userdata.hImages = gobjects(1,3);
userdata.hMask = gobjects(1,3);
userdata.hAxes = [handles.axes_local_image1, handles.axes_local_image2, handles.axes_local_image3];

% Display image and mask on axes
for i = find(handles.image_loaded)
    % Crop image
    slice = generate_slices('image', i, handles.slice, handles);
    userdata.slice{i} = slice(y0:y1,x0:x1);
    % Display image
    CLim = get(handles.hImageAxes(i), 'CLim');
    userdata.hImages(i) = imshow(userdata.slice{i}, ...
        'DisplayRange', CLim, 'Parent', userdata.hAxes(i));
    hold(userdata.hAxes(i),'on');
    % Display mask
    color = [1 1 0];
    r = color(1)*ones(userdata.res);
    g = color(2)*ones(userdata.res);
    b = color(3)*ones(userdata.res);
    masklayer = cat(3,r,g,b);
    userdata.hMask(i) = imshow(masklayer,'Parent',userdata.hAxes(i));
    hold(userdata.hAxes(i),'off');
end

% Populate popup menus
image_all = 1:length(handles.image_loaded);
image_valid = image_all(handles.image_loaded);
mask_all = 1:length(handles.mask_loaded);
mask_valid = mask_all(handles.mask_loaded);
str_source = handles.image_name(handles.image_loaded);
ind_source = [image_valid];
str_target = cat(2,{'Choose a Mask'},handles.mask_name(handles.mask_loaded));
ind_target = [0 mask_valid];
source_val = find(ind_source == axes_no);
target_val = find(ind_target==handles.lastMaskChoice);

if isempty(target_val)
    % Program initializes with lastMaskChoice = -1.
    % If lastMaskChoice has not been used yet, target_val is empty.
    target_val = 1;
end
set(handles.popup_local_source,'String',str_source, ...
    'Value',source_val,'UserData',ind_source);
set(handles.popup_local_target,'String',str_target, ...
    'Value',target_val,'UserData',ind_target);

% Save UserData to Local Threshold Tool panel
set(handles.panel_localthreshold,'UserData',userdata);

% Call source image popupmenu callback. This callback sets proper
% javaslider visibility, initializes javaslider values, and calls
% javaslider range update callback, which in turn updates mask.
hObject0 = handles.popup_local_source;
popup_local_source_Callback(hObject0, [], handles);
hObject1 = handles.popup_local_target;
popup_local_target_Callback(hObject1, [], handles);
% Delete ROI handle
delete(handles.hROI);
% Make Local Threshold Tool panel visible
set(handles.panel_localthreshold,'Visible','on');
% Flag the panel as open
hObject0 = handles.figure_masktool_main;
userdata0 = get(hObject0,'UserData');
userdata0.LocalThreshPanelOpen = true;
set(hObject0,'UserData',userdata0);
% Reset N string
set(handles.text_local_N,'String','');

% Turn off ROI indicator in toggle button so ROI can start again in
% ButtonMotion callback
handles.toggle_localthreshold.UserData = false;


% --- Executes on button press in push_local_ok.
function push_local_ok_Callback(hObject, eventdata, handles)
% hObject    handle to push_local_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get image number and mask number
userdata = get(handles.panel_localthreshold,'UserData');
source_val = get(handles.popup_local_source,'Value');
source_list = get(handles.popup_local_source,'UserData');
target_val = get(handles.popup_local_target,'Value');
target_list = get(handles.popup_local_target,'UserData');
image_no = source_list(source_val);
mask_no = target_list(target_val);

% Determine mask
slice = userdata.slice{image_no};
low = get(handles.hLocalSlider(image_no),'Low');
high = get(handles.hLocalSlider(image_no),'High');
mask = (slice >= low) & (slice <= high);

% Update mask
xlims = userdata.xlim;
ylims = userdata.ylim;
oldmask = handles.mask_data{mask_no}(ylims(1):ylims(2),xlims(1):xlims(2),handles.slice);
if get(handles.radio_local_replace,'Value') == 1
    % Replace
    newmask = mask;
elseif get(handles.radio_local_add,'Value') == 1
    % Add
    newmask = (oldmask | mask);
elseif get(handles.radio_local_remove,'Value') == 1
    % Remove
    newmask = ((oldmask - mask) > 0);
end
handles.mask_data{mask_no}(ylims(1):ylims(2),xlims(1):xlims(2),handles.slice) = newmask;

% Save handle
handles.lastMaskChoice = mask_no;
guidata(hObject,handles);
% Update mask
update_mask_alphadata(mask_no, handles);

% Call cancel callback for jobs described there.
push_local_cancel_Callback(hObject, eventdata, handles);
    

% --- Executes on button press in push_local_cancel.
function push_local_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_local_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Delete images and masks created in the panel.
userdata = get(handles.panel_localthreshold,'UserData');
delete(userdata.hMask);
delete(userdata.hImages);

% Turn off Local Threshold Tool panel and its UserData indicator 
set(handles.panel_localthreshold,'Visible','off');
hObject0 = handles.figure_masktool_main;
userdata0 = get(hObject0,'UserData');
userdata0.LocalThreshPanelOpen = false;
set(hObject0,'UserData',userdata0);

% Turn off ROI indicator in toggle button so ROI can start again in
% ButtonMotion callback
handles.toggle_localthreshold.UserData = false;

function [jslider_local, jcontainer_local] = createLocalThresholdToolJavaSliders(handles)
hObject = handles.figure_masktool_main;

jslider1 = com.jidesoft.swing.RangeSlider(0,100,20,70); % min,max,low,high
jslider2 = com.jidesoft.swing.RangeSlider(0,100,20,70); % min,max,low,high
jslider3 = com.jidesoft.swing.RangeSlider(0,100,20,70); % min,max,low,high
[jslider1, jcontainer1] = javacomponent(jslider1, [231,20,222,30], handles.panel_localthreshold);
[jslider2, jcontainer2] = javacomponent(jslider2, [470,20,222,30], handles.panel_localthreshold);
[jslider3, jcontainer3] = javacomponent(jslider3, [709,20,222,30], handles.panel_localthreshold);
set(jslider1, 'PaintTicks',true, ...
     'MouseReleasedCallback',@(x,y) execute_localthresh_slider_callback(hObject,1,guidata(hObject)));
set(jslider2, 'PaintTicks',true, ...
     'MouseReleasedCallback',@(x,y) execute_localthresh_slider_callback(hObject,2,guidata(hObject)));
set(jslider3, 'PaintTicks',true, ...
     'MouseReleasedCallback',@(x,y) execute_localthresh_slider_callback(hObject,3,guidata(hObject)));
% 'PaintTicks',true, 'PaintLabels',true, 
jslider_local = [jslider1 jslider2 jslider3];
jcontainer_local = [jcontainer1 jcontainer2 jcontainer3];


% --- Executes on selection change in popup_brush_mask.
function popup_brush_mask_Callback(hObject, eventdata, handles)
% hObject    handle to popup_brush_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_brush_mask contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_brush_mask


% --- Executes during object creation, after setting all properties.
function popup_brush_mask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_brush_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_fill_Callback(hObject, eventdata, handles)
% hObject    handle to menu_fill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update UserData to indicate Connectivity Panel is open
hObject0 = handles.figure_masktool_main;
UserData = get(hObject0,'UserData');
UserData.FillOn = true;
set(hObject0,'UserData',UserData);

% Open and initialize Connectivity Panel
set(handles.panel_fill,'Visible','on');
populate_masks_in_popupmenu(handles.popup_fill, handles);

% Set all masks invisible.
set(handles.Huichk_mask_show,'Value',0);
update_mask_visibility('all',handles);


% --- Executes on selection change in popup_fill.
function popup_fill_Callback(hObject, eventdata, handles)
% hObject    handle to popup_fill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_fill contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_fill

% Make the chosen mask visible
index_allmask = get(handles.popup_fill,'UserData');
index_mask = index_allmask(get(hObject,'Value'));
set(handles.Huichk_mask_show(index_mask),'Value',1);
update_mask_visibility('all',handles);


% --- Executes during object creation, after setting all properties.
function popup_fill_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_fill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_fill_close.
function push_fill_close_Callback(hObject, eventdata, handles)
% hObject    handle to push_fill_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update UserData to indicate Connectivity Panel is open
hObject0 = handles.figure_masktool_main;
UserData = get(hObject0,'UserData');
UserData.FillOn = false;
set(hObject0,'UserData',UserData);
% Make Fill panel invisible
set(handles.panel_fill,'Visible','off');



function execute_fill_pressed(hObject, eventdata, handles)
x = round(eventdata(1));
y = round(eventdata(2));
index_allmask = get(handles.popup_fill,'UserData');
index_mask = index_allmask(get(handles.popup_fill,'Value'));
val_xy = handles.mask_data{index_mask}(y,x,handles.slice);

if val_xy == true
    %2D connectivity
    conn_val = 8;
    mask_orig = handles.mask_data{index_mask}(:,:,handles.slice); % Generalize later
    mask_labeled = bwlabeln(mask_orig, conn_val);
    label = mask_labeled(y,x); % Generalize later
    mask_unfilled = (mask_labeled == label);
    mask_filled = imfill(mask_unfilled, 'holes');
    mask = false(handles.xyzres);
    mask(:,:,handles.slice) = mask_filled; % Generalize later
    
    handles.mask_data{index_mask} = (handles.mask_data{index_mask} | mask);
    guidata(hObject, handles);
    update_mask_alphadata('all',handles);
end



function edit_rect_x0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rect_x0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rect_x0 as text
%        str2double(get(hObject,'String')) returns contents of edit_rect_x0 as a double


% --- Executes during object creation, after setting all properties.
function edit_rect_x0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rect_x0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rect_x1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rect_x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rect_x1 as text
%        str2double(get(hObject,'String')) returns contents of edit_rect_x1 as a double


% --- Executes during object creation, after setting all properties.
function edit_rect_x1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rect_x1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rect_y0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rect_y0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rect_y0 as text
%        str2double(get(hObject,'String')) returns contents of edit_rect_y0 as a double


% --- Executes during object creation, after setting all properties.
function edit_rect_y0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rect_y0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rect_y1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rect_y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rect_y1 as text
%        str2double(get(hObject,'String')) returns contents of edit_rect_y1 as a double


% --- Executes during object creation, after setting all properties.
function edit_rect_y1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rect_y1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rect_z0_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rect_z0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rect_z0 as text
%        str2double(get(hObject,'String')) returns contents of edit_rect_z0 as a double


% --- Executes during object creation, after setting all properties.
function edit_rect_z0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rect_z0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rect_z1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rect_z1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rect_z1 as text
%        str2double(get(hObject,'String')) returns contents of edit_rect_z1 as a double


% --- Executes during object creation, after setting all properties.
function edit_rect_z1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rect_z1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function menu_mask_new_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_mask_empty_mask_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_empty_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mask = false(handles.xyzres);
execute_add_newmask(mask, [], handles);



% --------------------------------------------------------------------
function menu_mask_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Turn on the panel
hObject0 = handles.figure_masktool_main;
set(handles.panel_createmask, 'Visible', 'on');
userdata0 = get(hObject0,'UserData');
userdata0.AddMaskPanelOpen = true;
set(hObject0,'UserData',userdata0);

% Group handles for easy enable on/off
hObject1 = handles.panel_createmask;
userdata1.hThreshText = [handles.text_slidermin handles.text_slidermax ...
                handles.text_sliderlow handles.text_sliderhigh];
userdata1.hManual = [handles.popup_bmchoice userdata1.hThreshText ...
                handles.text_create21 handles.push_create_zoomin handles.push_create_reset];
userdata1.hAuto = [handles.text_create31 handles.text_create32 handles.text_create33 ...
            handles.popup_create_method handles.popup_create_gt handles.popup_create_domain ...
            handles.text_create34 handles.popup_create_dir handles.push_create_calc ...
            handles.text_create35 handles.popup_create_autobm handles.text_autothresh];
set(hObject1,'UserData',userdata1);

% Set strings for 'Choose Image' pop-up menu
string_all = cat(2,'Choose Image',handles.image_name);
index_all = [0 1 2 3]; 
bool_valid = logical([1 handles.image_loaded]);
string_valid = string_all(bool_valid);
index_valid = index_all(bool_valid);
set(handles.popup_create_imgsel, 'String', string_valid, 'UserData', index_valid);

% Set strings for 'Brain Mask' pop-up menu
string_all = cat(2,'Entire Image Volume', handles.mask_name);
index_all = [0 1:100];
bool_valid = logical([1 handles.mask_loaded]);
string_valid = string_all(bool_valid);
index_valid = index_all(bool_valid);
set(handles.popup_bmchoice,'String',string_valid,'UserData',index_valid);

% Set strings for pop-up menus in automatic section
method_string = {'Choose a Method','Maximize DSC','Maximize DSC based on MIP'};
method_userdata = {'','DSC','DSC_MIP'};
direction_userdata = {'above','below'};
[valid_mask_string valid_mask_index] = generate_masklist('Choose a Mask',handles);
[valid_domain_string valid_domain_index] = generate_masklist('Entire Image Volume',handles);
set(handles.popup_create_method,'String',method_string,'UserData',method_userdata);
set(handles.popup_create_gt,'String',valid_mask_string,'UserData',valid_mask_index);
set(handles.popup_create_domain,'String',valid_domain_string,'UserData',valid_domain_index);
set(handles.popup_create_autobm,'String',valid_domain_string,'UserData',valid_domain_index);
set(handles.popup_create_dir,'UserData',direction_userdata);

% Set default options and 'Enable' properties
set(handles.popup_create_imgsel,'Value',1);
set(handles.popup_bmchoice,'Value',1);
set(handles.popup_create_method,'Value',1);
set(handles.popup_create_gt,'Value',1);
set(handles.popup_create_domain,'Value',1);
set(handles.hThreshSlider,'Enable',0);
set(userdata1.hThreshText,'String','');
set(handles.text_autothresh,'String','');
set(userdata1.hManual,'Enable','off');
set(userdata1.hAuto,'Enable','off');
set(handles.radio_create_manual,'Enable','off','Value',1);
set(handles.radio_create_auto,'Enable','off','Value',0);
set(handles.push_create_ok,'Enable','off');

% Create an empty mask
n = find(~handles.mask_loaded,1,'first');
handles.temp_mask_index = n;
mask = false(handles.xyzres);
execute_add_newmask(mask,[],handles); %This callback saves handle


% --- Executes on selection change in popup_create_imgsel.
function popup_create_imgsel_Callback(hObject, eventdata, handles)
% hObject    handle to popup_create_imgsel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_create_imgsel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_create_imgsel

hObject1 = handles.panel_createmask;
userdata1 = get(hObject1,'UserData');

if get(hObject,'Value') == 1
    % No Image Selected. Disable all radio and components.
    set(handles.radio_create_manual,'Enable','off');
    set(handles.radio_create_auto,'Enable','off');
    set(userdata1.hManual,'Enable','off');
    set(userdata1.hAuto,'Enable','off');
    % Enable OK button
    set(handles.push_create_ok,'Enable','off');
    % Empty mask and update display
    n = handles.temp_mask_index;
    mask = false(handles.xyzres);
    update_mask(n, mask, handles);
else
    % Valid image selected. Execute callback for chosen radio.
    set(handles.radio_create_manual,'Enable','on');
    set(handles.radio_create_auto,'Enable','on');
    if get(handles.radio_create_manual,'Value') == 1
        hObject0 = handles.radio_create_manual;
        radio_create_manual_Callback(hObject0, [], handles)
    elseif get(handles.radio_create_auto,'Value') == 1
        hObject0 = handles.radio_create_auto;
        radio_create_auto_Callback(hObject0, [], handles)
    end
end


% --- Executes on button press in radio_create_manual.
function radio_create_manual_Callback(hObject, eventdata, handles)
% hObject    handle to radio_create_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radio_create_manual

set(handles.radio_create_auto,'Value',0);
% Turn on 'Manual' components, and off 'Auto' components
hObject1 = handles.panel_createmask;
userdata1 = get(hObject1,'UserData');
set(handles.hThreshSlider,'Enable',1);
set(userdata1.hManual,'Enable','on');
set(userdata1.hAuto,'Enable','off');
% Enable OK button
set(handles.push_create_ok,'Enable','on');
% Execute 'Brain Mask' pop-up callback to sort image intensities,
% which in turn calls slider callback to update mask
hObject0 = handles.popup_bmchoice;
popup_bmchoice_Callback(hObject0, eventdata, handles)



% --- Executes on button press in radio_create_auto.
function radio_create_auto_Callback(hObject, eventdata, handles)
% hObject    handle to radio_create_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radio_create_auto

set(handles.radio_create_manual,'Value',0);
% Empty mask and update display
n = handles.temp_mask_index;
mask = false(handles.xyzres);
handles = update_mask(n, mask, handles);
guidata(hObject,handles);
% Turn off 'Manual' components, and on 'Auto' components
hObject1 = handles.panel_createmask;
userdata1 = get(hObject1,'UserData');
set(handles.hThreshSlider,'Enable',0);
set(userdata1.hManual,'Enable','off');
set(userdata1.hAuto,'Enable','on');
% Disable OK button first, and let execute_auto_threshold decide
set(handles.push_create_ok,'Enable','off');
% Execute auto threshold callback
check_autocalc_enable(handles);


% --- Executes during object creation, after setting all properties.
function popup_create_imgsel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_create_imgsel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popup_bmchoice.
function popup_bmchoice_Callback(hObject, eventdata, handles)
% hObject    handle to popup_bmchoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_bmchoice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_bmchoice

% Get image and mask of choice
maskindex_valid = get(handles.popup_bmchoice,'UserData');
maskpopup_value = get(handles.popup_bmchoice,'Value');
maskindex_choice = maskindex_valid(maskpopup_value);
imageindex_valid = get(handles.popup_create_imgsel,'UserData');
imagepopup_value = get(handles.popup_create_imgsel,'Value');
imageindex_choice = imageindex_valid(imagepopup_value);
image_choice = handles.image_data{imageindex_choice};

if maskpopup_value == 1
    handles.brainmask = true(handles.xyzres);
else
    handles.brainmask = handles.mask_data{maskindex_choice};
end

handles.img_sorted = sort(image_choice(logical(handles.brainmask)));
minval = handles.img_sorted(1);
maxval = handles.img_sorted(end);
lowval = convert_per_val(98,  handles.img_sorted);
highval = maxval;

% Execute callback for range reset button to update slider labels
push_create_reset_Callback(handles.push_create_reset, eventdata, handles);
% Initialize slider settings
set(handles.hThreshSlider, 'Enabled', 1);
set(handles.hThreshSlider,'Minimum',minval,'Maximum',maxval, ...
        'Low', lowval, 'High', highval);
set_jslider_range(minval,maxval,handles);

guidata(hObject,handles);

% Call threshold slider callback
execute_addmask_slider_callback(hObject, [], handles);



% --- Executes during object creation, after setting all properties.
function popup_bmchoice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_bmchoice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popup_create_dir.
function popup_create_dir_Callback(hObject, eventdata, handles)
% hObject    handle to popup_create_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_create_dir contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_create_dir

check_autocalc_enable(handles);

% --- Executes during object creation, after setting all properties.
function popup_create_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_create_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%--- Executes upon change of threshold slider in 'Add New Mask' Panel
function execute_addmask_slider_callback(hObject, eventdata, handles)
% Generate new mask and update mask array Dmask

% Get new threshold
low = get(handles.hThreshSlider,'Low');
high = get(handles.hThreshSlider,'High');

% Display new range
lowper = convert_val_per(low, handles.img_sorted);
highper = convert_val_per(high, handles.img_sorted);
str_low = ['Low: ',num2str(low),'(',sprintf('%0.1f',lowper),'%)'];
str_high = ['High: ',num2str(high),'(',sprintf('%0.1f',highper),'%)'];
set(handles.text_sliderlow,'String',str_low);
set(handles.text_sliderhigh,'String',str_high);

% Compute new mask
hObject1 = handles.popup_create_imgsel;
imageindex_valid = get(hObject1,'UserData');
imagepopup_sel = get(hObject1,'Value');
imageindex_sel = imageindex_valid(imagepopup_sel);
image = handles.image_data{imageindex_sel};
mask = ((image >= low) & (image <= high)) & handles.brainmask;

% Update mask
n = handles.temp_mask_index;
update_mask(n, logical(mask), handles)

function varargout = update_mask(n, mask, handles)
% Update mask data
handles.mask_data{n} = mask;
% Update maks display
update_mask_alphadata(n, handles);
% Save or return handle
if nargout == 0
    guidata(handles.hObject0, handles);
else
    varargout{1} = handles;
end

% --- Executes on button press in push_create_zoomin.
function push_create_zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to push_create_zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lowval = get(handles.hThreshSlider, 'Low');
highval = get(handles.hThreshSlider, 'High');
range = highval - lowval;
set(handles.hThreshSlider,'Minimum',lowval,'Maximum',highval, ...
        'Low', lowval, 'High', highval, 'MajorTickSpacing', range);
set_jslider_range(lowval, highval, handles);

% --- Executes on button press in push_create_reset.
function push_create_reset_Callback(hObject, eventdata, handles)
% hObject    handle to push_create_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
minval = handles.img_sorted(1);
maxval = handles.img_sorted(end);
range = maxval - minval;
set(handles.hThreshSlider,'Minimum',minval,'Maximum',maxval, ...
    'MajorTickSpacing', range);
set_jslider_range(minval, maxval, handles);

function set_jslider_range(min, max, handles)
if isnumeric(min)
    min = num2str(min);
end
if isnumeric(max)
    max = num2str(max);
end
set(handles.text_slidermin,'String',min);
set(handles.text_slidermax,'String',max);

function value = convert_per_val(per, sorted_val)
n = length(sorted_val);
ind = round((per/100)*(n-1));
value = sorted_val(ind+1);

function per = convert_val_per(val, sorted_val)
n = length(sorted_val);
per = (sum(sorted_val<=val)/n)*100;

function check_autocalc_enable(handles)
% Check if conditions are met to auto-calculate threshold
method_val = get(handles.popup_create_method,'Value');
gt_index_all = get(handles.popup_create_gt,'UserData');
gt_index_val = get(handles.popup_create_gt,'Value');
gt_index = gt_index_all(gt_index_val);

if method_val > 1 && gt_index > 0
    set(handles.push_create_calc,'Enable','on');
else
    set(handles.push_create_calc,'Enable','off');
end


function output = get_popupmenu_data(handle, option)
if strcmp(option,'String')
    contents = get(handle,'String');
    value = get(handle,'Value');
    output = contents{value};
elseif strcmp(options,'Index')
    userdata = get(handle,'UserData');
    value = get(handle,'Value');
    output = userdata(value);
end



% --- Executes on button press in push_create_ok.
function push_create_ok_Callback(hObject, eventdata, handles)
% hObject    handle to push_create_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Generate note
if get(handles.radio_create_manual,'Value')
    % manual threshold
    image = get_popupmenu_data(handles.popup_create_imgsel, 'String');
    brainmask = get_popupmenu_data(handles.popup_bmchoice, 'String');
    thresh_low = get(handles.text_sliderlow,'String');
    thresh_high = get(handles.text_sliderhigh,'String');

    note = cell(5,1);
    note{1} = 'Applied manual threshold';
    note{2} = ['   Image: ',image];
    note{3} = ['   Mask: ',brainmask];
    note{4} = ['   Low: ',thresh_low];
    note{5} = ['   High: ',thresh_high];
    

    % Update mask info
    options.name = image;
    options.appendnote = note;

elseif get(handles.radio_create_auto,'Value')
    % Auto threshold
    image = get_popupmenu_data(handles.popup_create_imgsel, 'String');
    method = get_popupmenu_data(handles.popup_create_method, 'String');
    gt = get_popupmenu_data(handles.popup_create_gt, 'String');
    domain = get_popupmenu_data(handles.popup_create_domain, 'String');
    direction = get_popupmenu_data(handles.popup_create_dir, 'String');
    autobm = get_popupmenu_data(handles.popup_create_autobm, 'String');
    thresh = get(handles.text_autothresh,'String');
    
    note = cell(8,1);
    note{1} = 'Applied automatic threshold';
    note{2} = ['   Image: ',image];
    note{3} = ['   Method: ',method];
    note{4} = ['   Ground Truth: ',gt];
    note{5} = ['   Calculated metric within: ',domain];
    note{6} = ['   Mask consisted of: ',direction];
    note{7} = ['   Threshold % calculated within: ',autobm];
    note{8} = ['   Threshold: ', thresh];
    
    options.name = image;
    options.appendnote = note;
end

n = handles.temp_mask_index;
update_maskinfo(n,options,handles);

% Turn off Create Mask panel
set(handles.panel_createmask, 'Visible', 'off');

% Update status variable of main figure
hObject0 = handles.figure_masktool_main;
userdata = get(hObject0,'UserData');
userdata.AddMaskPanelOpen = false;
set(hObject0,'UserData',userdata);
    
    



% --- Executes on button press in push_create_cancel.
function push_create_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_create_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Delete the temporary mask created
n = handles.temp_mask_index;
delete_mask(n, handles);

% Turn off Create Mask panel
set(handles.panel_createmask, 'Visible', 'off');

% Update status variable of main figure
hObject0 = handles.figure_masktool_main;
set(handles.panel_createmask, 'Visible', 'off');
userdata = get(hObject0,'UserData');
userdata.AddMaskPanelOpen = false;
set(hObject0,'UserData',userdata);



function update_addmaskpushbutton(handles)

if any(handles.image_loaded) && ~all(handles.mask_loaded)
    flag = 'on';
else
    flag = 'off';
end
%set(handles.uipush_main_addmask, 'Enable', flag);




% --------------------------------------------------------------------
function menu_mask_rect_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_rect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update UserData to indicate Rectangular Mask Panel is open
hObject0 = handles.figure_masktool_main;
UserData = get(hObject0,'UserData');
UserData.RectMaskOn = true;
set(hObject0,'UserData',UserData);

% Set all masks invisible.
update_mask_visibility('all',handles);

% Calculate initial ROI range 
% (does not work for too small images)
xy_c = round(handles.xyzres([2 1])/2);
xy_w = round(handles.xyzres([2 1])/10);
x0 = xy_c(1) - xy_w(1);
x1 = xy_c(1) + xy_w(1);
y0 = xy_c(2) - xy_w(2);
y1 = xy_c(2) + xy_w(2);
z0 = handles.slice;
z1 = handles.slice;
pos = [x0 y0 (xy_w*2+1)];
%x1 = x0 + 39;
%y1 = y0 + 39;
%pos = [x0 y0 40 40];

% Initialize Rectangular Mask Panel
set(handles.panel_rectmask,'Visible','on');
set(handles.edit_rect_x0,'String',num2str(x0));
set(handles.edit_rect_x1,'String',num2str(x1));
set(handles.edit_rect_y0,'String',num2str(y0));
set(handles.edit_rect_y1,'String',num2str(y1));
set(handles.edit_rect_z0,'String',num2str(z0));
set(handles.edit_rect_z1,'String',num2str(z1));

% Create a mask image in axes
% Create an empty mask
n = find(~handles.mask_loaded,1,'first');
handles.temp_mask_index = n;
mask = false(handles.xyzres);
mask(y0:y1,x0:x1,z0:z1) = true;
option.name = 'Rectangular Mask';
execute_add_newmask(mask,option,handles); % This callback saves handles
%guidata(handles.hObject0, handles);

% Set imrect objects
for i = find(handles.image_loaded)
        h_imrect(i) = imrect(handles.hImageAxes(i),pos);
        addNewPositionCallback(h_imrect(i), @(p) update_rectmask_range(hObject, i, guidata(hObject)));
        setResizable(h_imrect(i),true);
end
set(handles.panel_rectmask,'UserData',h_imrect);


function update_rectmask_range(hObject, axes_no, handles)
% axes_no 0 : called when z range is changed with push button
% axes_no 1-3 : called when imrect is adjusted

if axes_no == 0
    % z position was set through push button
    % Obtain range from edit box contents
    x0 = str2num(get(handles.edit_rect_x0, 'String'));
    x1 = str2num(get(handles.edit_rect_x1, 'String'));
    y0 = str2num(get(handles.edit_rect_y0, 'String'));
    y1 = str2num(get(handles.edit_rect_y1, 'String'));
    z0 = str2num(get(handles.edit_rect_z0, 'String'));
    z1 = str2num(get(handles.edit_rect_z1, 'String'));
else
    % imrect was adjusted
    % Update new x-y range, take z range from edit box
    h_imrect = get(handles.panel_rectmask,'UserData');

    pos = round(getPosition(h_imrect(axes_no)));
    x0 = pos(1);
    y0 = pos(2);
    x1 = x0 + pos(3) - 1;
    y1 = y0 + pos(4) - 1;
    z0 = str2num(get(handles.edit_rect_z0, 'String'));
    z1 = str2num(get(handles.edit_rect_z1, 'String'));

    % Update imrect positions
    for i = find(handles.image_loaded)
            setPosition(h_imrect(i),pos);
    end

    % Update edit box contents for x-y.
    set(handles.edit_rect_x0,'String',num2str(x0));
    set(handles.edit_rect_x1,'String',num2str(x1));
    set(handles.edit_rect_y0,'String',num2str(y0));
    set(handles.edit_rect_y1,'String',num2str(y1));
end

% Update mask
n = handles.temp_mask_index;
mask = false(handles.xyzres);
mask(y0:y1,x0:x1,z0:z1) = true;
update_mask(n, mask, handles);


% --- Executes on button press in push_rect_ok.
function push_rect_ok_Callback(hObject, eventdata, handles)
% hObject    handle to push_rect_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Delete imrect objects
h_imrect = get(handles.panel_rectmask,'UserData');
for i = find(handles.image_loaded)
    delete(h_imrect(i));
end

% Update UserData to indicate Rectangular Mask Panel is closed
hObject0 = handles.figure_masktool_main;
UserData = get(hObject0,'UserData');
UserData.RectMaskOn = false;
set(hObject0,'UserData',UserData);

% Turn off rectangular panel
set(handles.panel_rectmask,'Visible','off');

% Update internal variables
guidata(hObject, handles);


% --- Executes on button press in push_rect_cancel.
function push_rect_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_rect_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Delete imrect objects
h_imrect = get(handles.panel_rectmask,'UserData');
for i = find(handles.image_loaded)
    delete(h_imrect(i));
end

% Update UserData to indicate Rectangular Mask Panel is closed
hObject0 = handles.figure_masktool_main;
UserData = get(hObject0,'UserData');
UserData.RectMaskOn = false;
set(hObject0,'UserData',UserData);

% Turn off rectangular panel
set(handles.panel_rectmask,'Visible','off');

% Update internal variables
execute_delete_mask(handles.temp_mask_index, handles);



% --- Executes on button press in push_rectmask_z0.
function push_rectmask_z0_Callback(hObject, eventdata, handles)
% hObject    handle to push_rectmask_z0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_rect_z0, 'String', num2str(handles.slice));
update_rectmask_range(hObject, 0, handles)

% --- Executes on button press in push_rectmask_z1.
function push_rectmask_z1_Callback(hObject, eventdata, handles)
% hObject    handle to push_rectmask_z1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_rect_z1, 'String', num2str(handles.slice));
update_rectmask_range(hObject, 0, handles)


% --------------------------------------------------------------------
function menu_mask_load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filter = '*.mat';
title = 'Select Mask File to Open';
defname = handles.pwd;

[filename,pathname] = uigetfile(filter, title, defname);

if ischar(filename) && ischar(pathname)
    
    fullfname = fullfile(pathname,filename);
    [pname,fname,ext] = fileparts(fullfname);
    
    switch ext
        case '.mat'
            
            % Load mask
            s = load(fullfname);
            
            if iscell(s.mask)
                % Multi-mask mat file
                for i = 1:length(s.mask)
                    mask = s.mask{i};
                    if isfield(s,'name')
                        options.name = s.name{i};
                    end
                    if isfield(s,'note')
                        options.note = s.note{i};
                    end
                    % Add new mask
                    handles = execute_add_newmask(mask,options,handles);
                end
            else
                % Single-mask mat file
                mask = s.mask;
                if isfield(s,'name')
                    options.name = s.name;
                else
                    options.name = fname;
                end
                if isfield(s,'note')
                    options.note = s.note;
                else
                    options.note = '';
                end
                % Add new mask
                handles = execute_add_newmask(mask,options,handles);
            end
            
    end
    
    guidata(hObject,handles);
    
end



% --- Executes on selection change in popup_create_method.
function popup_create_method_Callback(hObject, eventdata, handles)
% hObject    handle to popup_create_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_create_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_create_method

check_autocalc_enable(handles);


% --- Executes during object creation, after setting all properties.
function popup_create_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_create_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_create_gt.
function popup_create_gt_Callback(hObject, eventdata, handles)
% hObject    handle to popup_create_gt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_create_gt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_create_gt

check_autocalc_enable(handles);

% --- Executes during object creation, after setting all properties.
function popup_create_gt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_create_gt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_create_domain.
function popup_create_domain_Callback(hObject, eventdata, handles)
% hObject    handle to popup_create_domain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_create_domain contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_create_domain

check_autocalc_enable(handles);

% --- Executes during object creation, after setting all properties.
function popup_create_domain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_create_domain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_volume_conv_Callback(hObject, eventdata, handles)
% hObject    handle to menu_volume_conv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Update UserData to indicate Connectivity Panel is open

% Update with better panel flag scheme
%hObject0 = handles.figure_masktool_main;
%UserData = get(hObject0,'UserData');
%UserData.ConnectivityOn = true;
%set(hObject0,'UserData',UserData);

% Open and initialize Convolution Panel
[contents,index] = generate_masklist('Choose a Mask', handles);
set(handles.panel_conv,'Visible','on');
set(handles.popup_conv_source,'String',contents,'UserData',index);
set(handles.popup_conv_source,'Value',1);
set(handles.popup_conv_method,'Value',1,'UserData',{'3D','2D','2Dslice'});
set(handles.edit_conv_radius,'String',5);
set(handles.push_conv_conv,'Enable','off');

function [contents, index] = generate_masklist(header, handles)
index_all = 1:length(handles.mask_loaded);
contents = handles.mask_name(handles.mask_loaded);
index = index_all(handles.mask_loaded);

if ~isempty(header)
    contents = cat(2,header,contents);
    index = [0 index];
end


% --- Executes on selection change in popup_conv_source.
function popup_conv_source_Callback(hObject, eventdata, handles)
% hObject    handle to popup_conv_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns popup_conv_source contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_conv_source

userdata = get(handles.popup_conv_source,'UserData');
index = userdata(get(handles.popup_conv_source,'Value'));

if index > 0
    set(handles.push_conv_conv,'Enable','on');
else
    set(handles.push_conv_conv,'Enable','off');
end
  


% --- Executes during object creation, after setting all properties.
function popup_conv_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_conv_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_conv_radius.
function popup_conv_radius_Callback(hObject, eventdata, handles)
% hObject    handle to popup_conv_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_conv_radius contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_conv_radius


% --- Executes during object creation, after setting all properties.
function popup_conv_radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_conv_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_conv_method.
function popup_conv_method_Callback(hObject, eventdata, handles)
% hObject    handle to popup_conv_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_conv_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_conv_method


% --- Executes during object creation, after setting all properties.
function popup_conv_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_conv_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_conv_close.
function push_conv_close_Callback(hObject, eventdata, handles)
% hObject    handle to push_conv_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.panel_conv,'Visible','off');


% --- Executes on button press in push_conv_conv.
function push_conv_conv_Callback(hObject, eventdata, handles)
% hObject    handle to push_conv_conv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Turn off push buttons while computing
set([handles.push_conv_conv handles.push_conv_close],'Enable','off');
drawnow;

index_all = get(handles.popup_conv_source,'UserData');
method_all = get(handles.popup_conv_method,'UserData');

n = index_all(get(handles.popup_conv_source,'Value'));
oldmask = get_mask(n, handles);
radius = str2num(get(handles.edit_conv_radius,'String'));
method = method_all{get(handles.popup_conv_method,'Value')};

switch method
    case '3D'
        % Dilate mask
        se = strel('sphere',radius);
        newmask = imdilate(oldmask,se);
        % Create new mask
        options.name = [get_mask_info(n,'name',handles),'_3Ddilated'];
        options.note = cat(1,{'%--- Previous note ---%'}, ...
                            get_mask_info(n,'note',handles), ...
                        {'%---------------------%';
                        'Performed 3D dilation';
                        ['  Image: ',get_mask_info(n,'name',handles)];
                        ['  Radius:',num2str(radius)]});
        handles = execute_add_newmask(newmask, options, handles);
    case '2D'
        % Dilate mask
        se = strel('disk', radius);
        newmask = imdilate(oldmask,se);
        % Create new mask
        options.name = [get_mask_info(n,'name',handles),'_2Ddilated'];
        options.note = cat(1,{'%--- Previous note ---%'}, ...
                            get_mask_info(n,'note',handles), ...
                        {'%---------------------%';
                        'Performed 2D dilation';
                        ['  Image: ',get_mask_info(n,'name',handles)];
                        ['  Radius:',num2str(radius)]});
        handles = execute_add_newmask(newmask, options, handles);
    case '2Dslice'
        % Dilate mask
        se = strel('disk', radius);
        oldslice = oldmask(:,:,handles.slice);
        newslice = imdilate(oldslice,se);
        newmask = oldmask;
        newmask(:,:,handles.slice) = newslice;
        % Create new mask
        handles = update_mask(n, newmask, handles);
end

% Turn back on push buttons
set([handles.push_conv_conv handles.push_conv_close],'Enable','on');

% Update mask list
[contents,index] = generate_masklist('Choose a Mask', handles);
set(handles.popup_conv_source,'String',contents,'UserData',index);

% Save handle
guidata(hObject,handles);


function contents = get_mask_info(n,field,handles)
switch field
    case 'name'
        contents = handles.mask_name{n};
    case 'note'
        contents = handles.mask_note{n};
    case 'color'
        contents = handles.mask_color{n};
    case 'alpha'
        contents = handles.mask_alpha(n);
end



function edit_conv_radius_Callback(hObject, eventdata, handles)
% hObject    handle to edit_conv_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_conv_radius as text
%        str2double(get(hObject,'String')) returns contents of edit_conv_radius as a double


% --- Executes during object creation, after setting all properties.
function edit_conv_radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_conv_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mask = get_mask(n,handles)
mask = handles.mask_data{n};


% --- Executes on button press in push_editmask.
function push_editmask_Callback(hObject, eventdata, handles)
% hObject    handle to push_editmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

n = handles.cellsel(1);

name = get_mask_info(n,'name',handles);
alpha = get_mask_info(n,'alpha',handles);
note = get_mask_info(n,'note',handles);

set(handles.edit_properties_name,'String',name);
set(handles.slider_properties_alpha,'Value',alpha);
set(handles.edit_properties_note,'String',note);

set(handles.panel_properties,'Visible','on','UserData',n);




% --- Executes when entered data in editable cell(s) in uitable_mask.
function uitable_mask_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable_mask (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
row = eventdata.Indices(1);
column = eventdata.Indices(2);

if column == 3
     update_mask_visibility(row, handles);
     set(handles.push_editmask,'Enable','off');
end

% --- Executes when selected cell(s) is changed in uitable_mask.
function uitable_mask_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable_mask (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

handles.cellsel = eventdata.Indices;

if isempty(handles.cellsel)
    set(handles.push_editmask,'Enable','off');
else
    row = handles.cellsel(1);
    column = handles.cellsel(2);
    % Enable 'Edit Properties' button for mask
    set(handles.push_editmask,'Enable','on');
    % Update Flip panel properties
    update_flip_panel_per_mask_selection(handles)
    
    if column == 2
        % Cell clicked within Color column
        oldrgb = get_mask_info(row, 'color', handles);
        rgb = uisetcolor(oldrgb);
        
        % Update color in table
        spacing = repmat('&nbsp',1,10);
        colortext = ['<html><body bgcolor="',rgb2hex(rgb),'">',spacing,'</body></html>'];
        tabledata = get(handles.uitable_mask,'Data');
        tabledata{row,2} = colortext;
        set(handles.uitable_mask,'Data',tabledata);
        
        % Update color in internal variable
        handles.mask_color{row} = rgb;
        
        % Re-draw mask with updated color
        layer = generate_masklayer(rgb, handles);
        for j = find(handles.image_loaded)
            set(handles.mask_handle{row}(j),'CData',layer);
        end
        update_mask_alphadata(row, handles);
    
        % Disable 'Edit Properties' button as changing color de-selects the cell
        set(handles.push_editmask,'Enable','off');
    end
end

guidata(hObject, handles);



function edit_properties_note_Callback(hObject, eventdata, handles)
% hObject    handle to edit_properties_note (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_properties_note as text
%        str2double(get(hObject,'String')) returns contents of edit_properties_note as a double


% --- Executes during object creation, after setting all properties.
function edit_properties_note_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_properties_note (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_properties_name_Callback(hObject, eventdata, handles)
% hObject    handle to edit_properties_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_properties_name as text
%        str2double(get(hObject,'String')) returns contents of edit_properties_name as a double


% --- Executes during object creation, after setting all properties.
function edit_properties_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_properties_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_properties_close.
function push_properties_close_Callback(hObject, eventdata, handles)
% hObject    handle to push_properties_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update mask info
n = get(handles.panel_properties,'UserData');
options.name = get(handles.edit_properties_name,'String');
options.note = cellstr(get(handles.edit_properties_note,'String'));
handles = update_maskinfo(n,options,handles);

% Save handle
guidata(hObject,handles);

% Turn off mask property panel
set(handles.panel_properties,'Visible','off');


% --- Executes on slider movement.
function slider_properties_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to slider_properties_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

n = get(handles.panel_properties,'UserData');
options.alpha = get(handles.slider_properties_alpha,'Value');
update_maskinfo(n,options,handles);


% --- Executes during object creation, after setting all properties.
function slider_properties_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_properties_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in push_create_calc.
function push_create_calc_Callback(hObject, eventdata, handles)
% hObject    handle to push_create_calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Auto-threshold callback executed')
% Modify Calculate button while calculating
set(handles.push_create_calc,'String','Wait...','Enable','off');
drawnow;

% Determine method, gt mask index, domain mask index
method_all = get(handles.popup_create_method,'UserData');
method_val = get(handles.popup_create_method,'Value');
gt_index_all = get(handles.popup_create_gt,'UserData');
gt_index_val = get(handles.popup_create_gt,'Value');
domain_index_all = get(handles.popup_create_domain,'UserData');
domain_index_val = get(handles.popup_create_domain,'Value');
direction_all = get(handles.popup_create_dir,'UserData');
direction_val = get(handles.popup_create_dir,'Value');

method = method_all{method_val};
gt_index = gt_index_all(gt_index_val);
domain_index = domain_index_all(domain_index_val);
direction = direction_all(direction_val);

% Check if choices are valid
if method_val > 1 && gt_index > 0
    
    % Obtain image, and gt and domain masks
    image_index_all = get(handles.popup_create_imgsel,'UserData');
    image_index_val = get(handles.popup_create_imgsel,'Value');
    image_index = image_index_all(image_index_val);
    image = handles.image_data{image_index};
    
    gt = get_mask(gt_index, handles);
    if domain_index == 0
        domain = true(handles.xyzres);
    else
        domain = get_mask(domain_index, handles);
    end
    
    gt_dbl = double(gt);
    domain_dbl = double(domain);
    image_dbl = double(image);
    
    % Compute new mask based on method of choice
    switch method
        case 'DSC'
            if strcmp(direction,'above')
                fun = @(t) 1 - calc_dsc(gt_dbl,image_dbl,domain_dbl, t, 'above');
                fmask = @(t) image>t;
            elseif strcmp(direction,'below')
                fun = @(t) 1 - calc_dsc(gt_dbl,image_dbl,domain_dbl, t, 'below');
                fmask = @(t) image<t;
            end
            
            % Find initial point
            n_eval = 40;
            t0 = min(image_dbl(:));
            t1 = convert_per_val(99.9, sort(image_dbl(:)));
            t_eval = linspace(t0,t1,n_eval);
            fun_eval = zeros(1,n_eval);
            for i = 1:n_eval
                fun_eval(i) = fun(t_eval(i));
            end
            [~,i0] = min(fun_eval);
            t_start = t_eval(i0);
            
            % Find optimized point
            t = fminsearch(fun,t_start);
            mask = fmask(t);
            
        case 'DSC_MIP'
            mip_radius = 5;
            if strcmp(direction,'above')
                fun = @(t) 1 - calc_dsc_mip(gt_dbl,image_dbl,domain_dbl, t, 'above',mip_radius);
                fmask = @(t) image>t;
            elseif strcmp(direction,'below')
                fun = @(t) 1 - calc_dsc_mip(gt_dbl,image_dbl,domain_dbl, t, 'below',mip_radius);
                fmask = @(t) image<t;
            end
            
            % Find initial point
            n_eval = 40;
            t0 = min(image_dbl(:));
            t1 = convert_per_val(99.9, sort(image_dbl(:)));
            t_eval = linspace(t0,t1,n_eval);
            fun_eval = zeros(1,n_eval);
            for i = 1:n_eval
                fun_eval(i) = fun(t_eval(i));
            end
            [~,i0] = min(fun_eval);
            t_start = t_eval(i0);
            
            % Find optimized point
            t = fminsearch(fun,t_start);
            mask = fmask(t);
    end
    
    % Save threshold in internal variable
    handles.autothreshold = t;
    % Calculate and display percentage within brain mask chosen
    autobm_all = get(handles.popup_create_autobm,'UserData');
    autobm_val = get(handles.popup_create_autobm,'Value');
    autobm_index = autobm_all(autobm_val);
    if autobm_index == 0
        autobm = true(handles.xyzres);
    else
        autobm = logical(handles.mask_data{autobm_index});
    end
    image_within_bm = image(autobm);
    per = convert_val_per(t, sort(image_within_bm));
    if strcmp(direction,'below')
        per = 100-per;
    end
    content = [num2str(t),'(',sprintf('%0.1f',per),'%)'];
    set(handles.text_autothresh,'String',content);

    % Update mask
    n = handles.temp_mask_index;
    update_mask(n, mask .* autobm, handles);
    
    
    % Enable ok button
    set(handles.push_create_ok,'Enable','on');
    
    % Modify Calculate button while calculating
    set(handles.push_create_calc,'String','Calculate','Enable','on');

    
else
    % Empty mask and update display
    n = handles.temp_mask_index;
    mask = false(handles.xyzres);
    update_mask(n, mask, handles);
    
    % Disable ok button
    set(handles.push_create_ok,'Enable','off');
end


function dsc = calc_dsc(gt,image,domain,t,dir)
domain = logical(domain);
gt0 = gt(domain);
if strcmp(dir,'above')
    mask0 = image(domain) > t;
elseif strcmp(dir,'below')
    mask0 = image(domain) < t;
end
dsc = 2*sum(gt0 & mask0)/(sum(gt0)+sum(mask0));


function dsc = calc_dsc_mip(gt,image,domain,t,dir,radius)

kernel = ones(1,1,2*radius+1);
domain = logical(convn(domain,kernel));
gt = logical(convn(gt,kernel));

if strcmp(dir,'above')
    mask = (image > t);
elseif strcmp(dir,'below')
    mask = (image < t);
end
mask = logical(convn(mask,kernel));

gt0 = gt(domain);
mask0 = mask(domain);
dsc = 2*sum(gt0 & mask0)/(sum(gt0)+sum(mask0));


% --- Executes on selection change in popup_create_autobm.
function popup_create_autobm_Callback(hObject, eventdata, handles)
% hObject    handle to popup_create_autobm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_create_autobm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_create_autobm


% --- Executes during object creation, after setting all properties.
function popup_create_autobm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_create_autobm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_mask_arithmetics_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_arithmetics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[flag, maskA, maskB, oper] = dialog_arithmetics('dummy', handles.mask_loaded, handles.mask_name);

%oper is one of {'and','or','subtract','xor','not'};

if flag
    nameA = get_mask_info(maskA,'name',handles);
    nameB = get_mask_info(maskB,'name',handles);
    
    switch oper
        case 'and'
            options.name = [nameA,' AND ',nameB];
            mask = handles.mask_data{maskA} & handles.mask_data{maskB};
        case 'or'
            options.name = [nameA,' OR ',nameB];
            mask = handles.mask_data{maskA} | handles.mask_data{maskB};
        case 'subtract'
            options.name = [nameA,' - ',nameB];
            mask = (handles.mask_data{maskA} - handles.mask_data{maskB})>0;
        case 'xor'
            options.name = [nameA,' XOR ',nameB];
            mask = xor(handles.mask_data{maskA},handles.mask_data{maskB});
        case 'not'
            options.name = ['NOT ',nameA];;
            mask = ~handles.mask_data{maskA};
    end
    
    execute_add_newmask(mask, options, handles);
end


% --------------------------------------------------------------------
function menu_math_false_Callback(hObject, eventdata, handles)
% hObject    handle to menu_math_false (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[flag, n_mask, n_gt, oper] = dialog_truefalse('dummy', handles.mask_loaded, handles.mask_name);

%oper is one of {'TP','TN','T','FP','FN','F'}

if flag
    
    mask = logical(handles.mask_data{n_mask});
    gt = logical(handles.mask_data{n_gt});
    
    switch oper
        case 'TP'
            result = mask & gt;
            description = 'True Positive';
        case 'TN'
            result = ~mask & ~gt;
            description = 'True Negative';
        case 'T'
            resultTP = mask & gt;
            resultTN = ~mask & ~gt;
            description = 'True (TP+TN)';
            result = resultTP | resultTN;
        case 'FP'
            result = mask & ~gt;
            description = 'False Positive';
        case 'FN'
            result = ~mask & gt;
            description = 'False Negative';
        case 'F'
            resultFP = mask & ~gt;
            resultFN = ~mask & gt;
            result = resultFP | resultFN;
            description = 'False (FP+FN)';
    end
    
    options.name = [oper,' of ',handles.mask_name{n_mask}];
    options.note = {'Performed False/True analysis';
                    ['Mask: ',get_mask_info(n_mask,'name',handles)];
                    ['Ground Truth: ',get_mask_info(n_gt,'name',handles)];
                    ['Computed: ', description];};
    execute_add_newmask(result, options, handles);
end


% --- Executes on button press in push_maskdelete.
function push_maskdelete_Callback(hObject, eventdata, handles)
% hObject    handle to push_maskdelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

n = get(handles.panel_properties,'UserData');

string =  {'Are you sure to delete', ...
    ['Mask ', num2str(n),':{\bf ', handles.mask_name{n}, '}?']};
title = 'Delete a Mask';
options.Interpreter = 'tex';
options.Default = 'No';
choice = questdlg(string, title, options);

if strcmp(choice,'Yes')
    execute_delete_mask(n, handles);
end

function execute_delete_mask(n, handles)
    %Update internal variables
    delete(handles.mask_handle{n});
    color = handles.mask_color{n};
    
    handles.mask_loaded(n) = [];
    handles.mask_loaded(100) = false;
    handles.mask_name(n) = [];
    handles.mask_name{100} = '';
    handles.mask_color(n) = [];
    handles.mask_color{100} = color;
    handles.mask_note(n) = [];
    handles.mask_note{100} = '';
    handles.mask_alpha(n) = [];
    handles.mask_alpha(100) = 0.5;
    handles.mask_data(n) = [];
    handles.mask_data{100} = false(0,0);
    handles.mask_handle(n) = [];
    handles.mask_handle{100} = gobjects(1,3);

    %Update table
    tabledata = get(handles.uitable_mask,'Data');
    tabledata(n,:) = [];
    set(handles.uitable_mask,'Data',tabledata);
       
    %GUI components
    set(handles.panel_properties,'Visible','off');
    set_maskmenus_enable(handles)
    guidata(handles.hObject0, handles);

% --------------------------------------------------------------------
function menu_image_Callback(hObject, eventdata, handles)
% hObject    handle to menu_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_reslice_Callback(hObject, eventdata, handles)
% hObject    handle to menu_reslice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.panel_reslice,'Visible','on');
set(handles.popup_slice_dir,'Value',1);


% --- Executes on button press in push_reslice_cancel.
function push_reslice_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_reslice_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.panel_reslice,'Visible','off');

% --- Executes on selection change in popup_reslice_dir.
function popup_reslice_dir_Callback(hObject, eventdata, handles)
% hObject    handle to popup_reslice_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_reslice_dir contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_reslice_dir


% --- Executes during object creation, after setting all properties.
function popup_reslice_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_reslice_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in push_reslice_ok.
function push_reslice_ok_Callback(hObject, eventdata, handles)
% hObject    handle to push_reslice_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%{
handles.image_name = cell(1,3);
handles.image_handle = gobjects(1,3);
handles.image_data = cell(1,3);

handles.mask_data = cell(1,100);
handles.mask_name = cell(1,100);

handles.image_loaded = false(1,3);
handles.mask_loaded = false(1,100);
%}


% --------------------------------------------------------------------
function copy_mask_to_slice_Callback(hObject, eventdata, handles)
% hObject    handle to copy_mask_to_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in chk_conn_diffslice.
function chk_conn_diffslice_Callback(hObject, eventdata, handles)
% hObject    handle to chk_conn_diffslice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_conn_diffslice

if get(hObject,'Value')
    set(handles.edit.conn_diffslice,'Enable',1);
else
    set(handles.edit.conn_diffslice,'Enable',0);
end



function edit_conn_diffslice_Callback(hObject, eventdata, handles)
% hObject    handle to edit_conn_diffslice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_conn_diffslice as text
%        str2double(get(hObject,'String')) returns contents of edit_conn_diffslice as a double


% --- Executes during object creation, after setting all properties.
function edit_conn_diffslice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_conn_diffslice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_mask_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_mask_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_substack_Callback(hObject, eventdata, handles)
% hObject    handle to menu_substack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open and initialize Convolution Panel
[contents,index] = generate_masklist('Choose a Mask', handles);
set(handles.panel_substack,'Visible','on');
set(handles.popup_substack_source,'String',contents,'UserData',index);
set(handles.popup_substack_source,'Value',1);
set(handles.edit_substack_range,'String','');


% --- Executes on selection change in popup_substack_source.
function popup_substack_source_Callback(hObject, eventdata, handles)
% hObject    handle to popup_substack_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_substack_source contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_substack_source


% --- Executes during object creation, after setting all properties.
function popup_substack_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_substack_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_substack_range_Callback(hObject, eventdata, handles)
% hObject    handle to edit_substack_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_substack_range as text
%        str2double(get(hObject,'String')) returns contents of edit_substack_range as a double


% --- Executes during object creation, after setting all properties.
function edit_substack_range_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_substack_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_subtack_ok.
function push_subtack_ok_Callback(hObject, eventdata, handles)
% hObject    handle to push_subtack_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get info
index = get(handles.popup_substack_source,'UserData');
value = get(handles.popup_substack_source,'Value');
n = index(value);
old_mask = get_mask(n, handles);
new_mask = false(size(old_mask));

% Apply range
rangestr = get(handles.edit_substack_range,'String');
C = strsplit(rangestr,'-');
z0 = str2num(C{1});
z1 = str2num(C{2});
new_mask(:,:,z0:z1) = old_mask(:,:,z0:z1);

% Generate note and new name
options.name = [get_mask_info(n,'name',handles),' ',rangestr];
options.note = cat(1,{'%--- Previous note ---%'}, ...
    get_mask_info(n,'note',handles), ...
    {'%---------------------%';
    'Performed substack';
    ['  Image: ',get_mask_info(n,'name',handles)];
    ['  Ramge:',rangestr]});

% Update mask
if get(handles.radio_substack_new,'Value')
    % Save as new mask
    disp('new mask')
    execute_add_newmask(new_mask, options, handles);
else
    % Save as existing mask
    disp('existing mask')
    update_mask(n, new_mask, handles);
end

set(handles.panel_substack,'Visible','off');


% --- Executes on button press in push_substack_cancel.
function push_substack_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_substack_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.panel_substack,'Visible','off');


% --- Executes on button press in push_flip.
function push_flip_Callback(hObject, eventdata, handles)
% hObject    handle to push_flip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sel = [get(handles.radio_flipy,'Value') get(handles.radio_flipx,'Value') get(handles.radio_flipz,'Value')];
dim = find(sel);

n = handles.cellsel(1);
mask = get_mask(n,handles);
mask = flip(mask,dim);
update_mask(n, mask, handles)


% --- Executes on button press in push_flip_close.
function push_flip_close_Callback(hObject, eventdata, handles)
% hObject    handle to push_flip_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.panel_flip,'Visible','off');

% --------------------------------------------------------------------
function menu_flip_Callback(hObject, eventdata, handles)
% hObject    handle to menu_flip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.panel_flip,'Visible','on');
update_flip_panel_per_mask_selection(handles);
    

function update_flip_panel_per_mask_selection(handles)

if ~isfield(handles,'cellsel') || isempty(handles.cellsel)
    disp('no sel')
    set(handles.text_flip_warning,'Visible','on');
    set(handles.push_flip,'Enable','off');
else
    disp('sel')
    set(handles.text_flip_warning,'Visible','off');
    set(handles.push_flip,'Enable','on');
end


    
