function varargout = PoissonFilterGUI(varargin)
% POISSONFILTERGUI MATLAB code for PoissonFilterGUI.fig
%      POISSONFILTERGUI, by itself, creates a new POISSONFILTERGUI or raises the existing
%      singleton*.
%
%      H = POISSONFILTERGUI returns the handle to a new POISSONFILTERGUI or the handle to
%      the existing singleton*.
%
%      POISSONFILTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POISSONFILTERGUI.M with the given input arguments.
%
%      POISSONFILTERGUI('Property','Value',...) creates a new POISSONFILTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PoissonFilterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PoissonFilterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PoissonFilterGUI

% Last Modified by GUIDE v2.5 27-Jan-2017 14:48:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PoissonFilterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PoissonFilterGUI_OutputFcn, ...
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


% --- Executes just before PoissonFilterGUI is made visible.
function PoissonFilterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PoissonFilterGUI (see VARARGIN)

% Choose default command line output for PoissonFilterGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PoissonFilterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

[ind map] = imread('Bee.png');
img = ind2rgb(ind,map);
axes(handles.axesBee);
imshow(img);


global isProcessed;
isProcessed = -1;

global gx;
global gsig;
global gamp;
global glpf;
gx = [0:30] / 30.0 * 10;
gsig = 0;
gamp = 1;
drawGraphG(handles, gx, gsig, gamp );
glpf = 0;

global ix;
global ith;
global iamp;
ix = [0:100];
ith = 50;
iamp = 1;
drawGraphI(handles, ix, ith, iamp );

global ep;
ep = 1E-8;


% --- Outputs from this function are returned to the command line.
function varargout = PoissonFilterGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global org;
global img;
global Param;
global rcn;

global isProcessed;

[filename, dirpath, filterindex] = uigetfile( '*.*', 'Load Image');
if( filename ~=0 )
    org = imread([dirpath,filename]);

    isProcessed = 0;
    s = size(org);
    if( s(1) * 4 > s(2) * 3 ) 
        % portrait
       scl = 360 / double(s(1));    
    else
        % portrait
        scl = 480 / double(s(2));
    end

    if( scl < 1 )
        img = double(imresize(org,scl));
    else
        img = double(org);
    end

    Param = buildModPoissonParam(size(img));
    rcn = img;

    performDraw(handles);
end
%axes(handles.axes1);
%imshow(uint8(img));


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global org;
global gsig;
global gamp;
global glpf;
global ith;
global iamp;
global ep;
global BlackL;
global median;
global isProcessed;

while( isProcessed > 0 )
end
[filename, dirpath, filterindex] = uiputfile( '*.*', 'Save Image');
if( filename ~= 0 )
    isProcessed = 1;
    set(handles.textProcess,'Visible','on');


    rcn = PoissonFilter(double(org), gsig, gamp, glpf, ith, iamp, median, BlackL, ep );

    imwrite(uint8(rcn),[dirpath,filename]);

    set(handles.textProcess,'Visible','off');
    isProcessed = 0;
end

% --- Executes during object creation, after setting all properties.
function sliderGamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderGamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global gamp;
gamp = 1;
set(hObject,'Value',gamp, 'Min', 0, 'Max', 10 );

% --- Executes on slider movement.
function sliderGamp_Callback(hObject, eventdata, handles)
% hObject    handle to sliderGamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global gx;
global gsig;
global gamp;
gamp = get(hObject,'Value');
drawGraphG(handles, gx, gsig, gamp );
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function editGamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%6.2f',1));

function editGamp_Callback(hObject, eventdata, handles)
% hObject    handle to editGamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGamp as text
%        str2double(get(hObject,'String')) returns contents of editGamp as a double
global gx;
global gamp;
global gsig;
gamp = str2double(get(hObject,'String'));
drawGraphG(handles,gx,gsig,gamp);
performDraw(handles);



% --- Executes during object creation, after setting all properties.
function sliderGsig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderGsig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global gsig;
gsig = 0;
sMin = 0;
sMax = 60;
sStep1 = 0.2 / (sMax-sMin);
sStep2 = sStep1*10;
set(hObject,'Value', gsig, 'Min', sMin, 'Max', sMax );
set(hObject, 'SliderStep', [sStep1, sStep2]);


% --- Executes on slider movement.
function sliderGsig_Callback(hObject, eventdata, handles)
% hObject    handle to sliderGsig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global gx;
global gsig;
global gamp;
gsig = get(hObject,'Value');
drawGraphG(handles, gx, gsig, gamp );
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function editGsig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGsig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%6.2f',0));

function editGsig_Callback(hObject, eventdata, handles)
% hObject    handle to editGsig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGsig as text
%        str2double(get(hObject,'String')) returns contents of editGsig as a double
global gx;
global gamp;
global gsig;
gsig = str2double(get(hObject,'String'));
drawGraphG(handles,gx,gsig,gamp);
performDraw(handles);

function drawGraphG(handles,gx,gsig,gamp)
axes(handles.axes2);
gy = gx .* calcGgain(gx,gsig,gamp);

axes(handles.axes2);
plot(handles.axes2,gx,gy);
axis(handles.axes2,[0, 10, 0, 30]);

set(handles.editGamp,'String',sprintf('%6.2f',gamp));
set(handles.editGsig,'String',sprintf('%6.2f',gsig));

if( gamp < 0 )
    set(handles.sliderGamp,'Value',0);
elseif( gamp > 10 )
    set(handles.sliderGamp,'Value',10);
else
    set(handles.sliderGamp,'Value',gamp);
end

if( gsig < 0 )
    set(handles.sliderGsig,'Value',1);
elseif( gsig > 60 )
    set(handles.sliderGsig,'Value',60);
else
    set(handles.sliderGsig,'Value',gsig);
end

% --- Executes during object creation, after setting all properties.
function sliderIamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderIamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global iamp;
iamp = 1;
sMin = 1;
sMax = 100;
sStep1 = 1.0 / (sMax-sMin);
sStep2 = sStep1*10;
set(hObject,'Value', iamp, 'Min', sMin, 'Max', sMax );
set(hObject, 'SliderStep', [sStep1, sStep2]);

% --- Executes on slider movement.
function sliderIamp_Callback(hObject, eventdata, handles)
% hObject    handle to sliderIamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global ix;
global ith;
global iamp;
iamp = get(hObject,'Value');
drawGraphI(handles, ix, ith, iamp );
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function editIamp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%6.2f',1));

function editIamp_Callback(hObject, eventdata, handles)
% hObject    handle to editIamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIamp as text
%        str2double(get(hObject,'String')) returns contents of editIamp as a double
global ix;
global ith;
global iamp;
iamp = str2double(get(hObject,'String'));
drawGraphI(handles,ix,ith,iamp);
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function sliderIth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderIth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global ith;
ith = 50;
sMin = 1;
sMax = 100;
sStep1 = 1.0 / (sMax-sMin);
sStep2 = sStep1*10;
set(hObject,'Value',ith, 'Min', sMin, 'Max', sMax );
set(hObject, 'SliderStep', [sStep1, sStep2]);


% --- Executes on slider movement.
function sliderIth_Callback(hObject, eventdata, handles)
% hObject    handle to sliderIth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ix;
global ith;
global iamp;
ith = get(hObject,'Value');
drawGraphI(handles, ix, ith, iamp );
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function editIth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%6.2f',50));

function editIth_Callback(hObject, eventdata, handles)
% hObject    handle to editIth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIth as text
%        str2double(get(hObject,'String')) returns contents of editIth as a double
global ix;
global ith;
global iamp;
ith = str2double(get(hObject,'String'));
drawGraphI(handles,ix,ith,iamp);
performDraw(handles);

function drawGraphI(handles,ix,ith,iamp)
iy = calcIgain(ix,ith,iamp);

axes(handles.axes3);
plot(handles.axes3,ix,iy);
axis(handles.axes3,[0, 100, 0, 50]);

set(handles.editIamp,'String',sprintf('%6.2f',iamp));
set(handles.editIth,'String',sprintf('%6.2f',ith));

if( iamp < 1 )
    set(handles.sliderIamp,'Value',1);
elseif( iamp > 100 )
    set(handles.sliderIamp,'Value',100);
else
    set(handles.sliderIamp,'Value',iamp);
end

if( ith < 1 )
    set(handles.sliderIth,'Value',1);
elseif( ith > 100 )
    set(handles.sliderIth,'Value',100);
else
    set(handles.sliderIth,'Value',ith);
end


% --- Executes on button press in togglebuttonOrg.
function togglebuttonOrg_Callback(hObject, eventdata, handles)
% hObject    handle to togglebuttonOrg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebuttonOrg
global img;
global rcn;
global isProcessed;

tog = get(hObject,'Value');
if( tog == 0 )
    str = 'Processed';
else
    str = 'Original';
end

set(handles.textImageTitle,'String',str);

if(isProcessed >=0 )
    axes(handles.axes1);
    if( tog == 0 )
        imshow(uint8(rcn));
    else
        imshow(uint8(img));
    end
end


% --- Executes on button press in pushbuttonReset.
function pushbuttonReset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global gx;
global gsig;
global gamp;
gamp = 1; %Eta
gsig = 0; %Sig
set(handles.sliderGsig,'Value',gsig);
set(handles.sliderGamp,'Value',gamp);
drawGraphG(handles, gx, gsig, gamp );

global median;
median = 0; %Median
set(handles.editMedian,'String',sprintf('%d',uint16(median)));

global glpf;
glpf = 0.0; %LPF
set(handles.sliderGlpf,'Value',glpf);
set(handles.editGlpf,'String',sprintf('%5.2f',glpf));

global ix;
global ith;
global iamp;
iamp = 1; %Alpha
ith = 50; %Beta
set(handles.sliderIth,'Value',ith);
set(handles.sliderIamp,'Value',iamp);
drawGraphI(handles, ix, ith, iamp );

global BlackL;
BlackL=0; %BlackL
set(handles.sliderBlackL,'Value', BlackL );
set(handles.editBlackL,'String',sprintf('%4.2f', BlackL));

global ep;
ep = 1E-8; %Epsilon
set(handles.sliderEp,'Value',-8);
set(handles.editEp,'String',sprintf('%3.2e',1E-8));

global isProcessed;
if( isProcessed >= 0 )
    performDraw(handles);
end



% --- Executes during object creation, after setting all properties.
function sliderEp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global ep;
ep = -8;
sMin = -16;
sMax = 2;
sStep1 = 0.1 / (sMax-sMin);
sStep2 = sStep1*10;
set(hObject,'Value', ep, 'Min', sMin, 'Max', sMax );
set(hObject, 'SliderStep', [sStep1, sStep2]);


% --- Executes on slider movement.
function sliderEp_Callback(hObject, eventdata, handles)
% hObject    handle to sliderEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ep;
ep = 10^(get(hObject,'Value'));
set(handles.editEp,'String',sprintf('%3.2e',ep));
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function editEp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%3.2e',1E-8));

function editEp_Callback(hObject, eventdata, handles)
% hObject    handle to editEp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEp as text
%        str2double(get(hObject,'String')) returns contents of editEp as a double
global ep;
ep = str2double(get(hObject,'String'));
e = log10(ep);
if( e < -16 )
    set(handles.sliderEp,'Value',-16);
elseif( e > 2 )
    set(handles.sliderEp,'Value',2);
else
    set(handles.sliderEp,'Value',e);
end
performDraw(handles);


% --- Executes during object creation, after setting all properties.
function textProcess_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Visible','off');


% --- Executes during object creation, after setting all properties.
function sliderGlpf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderGlpf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global glpf;
glpf = 0.0;
sMin = 0;
sMax = 10;
sStep1 = 0.05 / (sMax-sMin);
sStep2 = sStep1*10;
set(hObject,'Value', glpf, 'Min', sMin, 'Max', sMax );
set(hObject, 'SliderStep', [sStep1, sStep2]);

% --- Executes on slider movement.
function sliderGlpf_Callback(hObject, eventdata, handles)
% hObject    handle to sliderGlpf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global glpf;
glpf = get(hObject,'Value');
set(handles.editGlpf,'String',sprintf('%4.2f',glpf));
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function editGlpf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGlpf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%4.2f', 0.0));


function editGlpf_Callback(hObject, eventdata, handles)
% hObject    handle to editGlpf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGlpf as text
%        str2double(get(hObject,'String')) returns contents of editGlpf as a double
global glpf;
glpf = str2double(get(hObject,'String'));
if( glpf < 0 )
    glpf = 0;
end
if( glpf > 10 )
    glpf = 10;
end

set(hObject,'String',sprintf('%4.2f', glpf));
set(handles.sliderGlpf,'Value',glpf);
performDraw(handles);

function performDraw(handles)
global isProcessed;
global Param;
global rcn;

global gsig;
global gamp;
global glpf;
global ith;
global iamp;
global ep;

global img;
global BlackL;
global median;

if( isProcessed == 0 )
    isProcessed = 2;
    set(handles.textProcess,'Visible','on');
    pause(0);

    rcn = PoissonFilter(double(img), gsig, gamp, glpf, ith, iamp, median, BlackL, ep, Param);        
    axes(handles.axes1);
    imshow(uint8(rcn));

    set(handles.textImageTitle,'String','Processed');
    set(handles.togglebuttonOrg,'Value',0);
    
    set(handles.textProcess,'Visible','off');
    pause(0.0);
    isProcessed = 0;    
end



function editBlackL_Callback(hObject, eventdata, handles)
% hObject    handle to editBlackL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBlackL as text
%        str2double(get(hObject,'String')) returns contents of editBlackL as a double
global BlackL;
BlackL = str2double(get(hObject,'String'));
set(handles.sliderBlackL,'Value',BlackL );
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function editBlackL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBlackL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',sprintf('%4.2f', 0.0));

% --- Executes on slider movement.
function sliderBlackL_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBlackL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global BlackL;
BlackL = get(hObject,'Value');
set(handles.editBlackL,'String',sprintf('%6.2f',BlackL));
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function sliderBlackL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBlackL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global BlackL;
BlackL = 0;
set(hObject,'Value',BlackL, 'Min', 0, 'Max', 200 );



function editMedian_Callback(hObject, eventdata, handles)
% hObject    handle to editMedian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMedian as text
%        str2double(get(hObject,'String')) returns contents of editMedian as a double
global median;
median = round(str2double(get(hObject,'String')));
set(hObject,'String',sprintf('%d',uint16(median)));
performDraw(handles);

% --- Executes during object creation, after setting all properties.
function editMedian_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMedian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global median;
median = 0;
set(hObject,'String',sprintf('%d',uint16(median)));


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in pushbuttonLoadParams.
function pushbuttonLoadParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, dirpath, filterindex] = uigetfile( '*.xls', 'Load Parameters');
if( filename ~= 0 )
    xls=xlsread([dirpath,filename]);

    global gx;
    global gsig;
    global gamp;
    gamp = xls(1); %Eta
    gsig = xls(2); %Sig
    set(handles.sliderGsig,'Value',gsig);
    set(handles.sliderGamp,'Value',gamp);
    drawGraphG(handles, gx, gsig, gamp );

    global median;
    median = xls(3); %Median
    set(handles.editMedian,'String',sprintf('%d',uint16(median)));

    global glpf;
    glpf = xls(4); %LPF
    set(handles.sliderGlpf,'Value',glpf);
    set(handles.editGlpf,'String',sprintf('%5.2f',glpf));

    global ix;
    global ith;
    global iamp;
    iamp = xls(5); %Alpha
    ith = xls(6); %Beta
    set(handles.sliderIth,'Value',ith);
    set(handles.sliderIamp,'Value',iamp);
    drawGraphI(handles, ix, ith, iamp );

    global BlackL;
    BlackL=xls(7); %BlackL
    set(handles.sliderBlackL,'Value', BlackL );
    set(handles.editBlackL,'String',sprintf('%4.2f', BlackL));

    global ep;
    ep = xls(8); %Epsilon
    set(handles.sliderEp,'Value',ep);
    set(handles.editEp,'String',sprintf('%3.2e',ep));
    
    global isProcessed;
    while( isProcessed > 0 )
        pause(0.2);
    end
    performDraw(handles);
end

% --- Executes on button press in pushbuttonSaveParams.
function pushbuttonSaveParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSaveParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, dirpath, filterindex] = uiputfile( '*.xls', 'Save Parameters');
if( filename ~= 0 )
 xls = cell(7,2);
 
 i = 1;
 
 global gamp;
 xls{i,1} = 'Eta';
 xls{i,2} = gamp;
 i = i + 1;
 
 global gsig;
 xls{i,1} = 'Sig';
 xls{i,2} = gsig;
 i = i + 1;
 
 global median;
 xls{i,1} = 'Median';
 xls{i,2} = median;
 i = i + 1;
 
 global glpf;
 xls{i,1} = 'LPF';
 xls{i,2} = glpf;
 i = i + 1;

 global iamp;
 xls{i,1} = 'Alpha';
 xls{i,2} = iamp;
 i = i + 1;

 global ith;
 xls{i,1} = 'Beta';
 xls{i,2} = ith;
 i = i + 1;

 global BlackL;
 xls{i,1} = 'BlackL';
 xls{i,2} = BlackL;
 i = i + 1;
 
 global ep;
 xls{i,1} = 'Epsilon';
 xls{i,2} = ep;
 i = i + 1;
 
 xlswrite( [dirpath,filename], xls );
end
