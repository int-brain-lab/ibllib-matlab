function varargout = uiaddinsertion(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uiaddinsertion_OpeningFcn, ...
                   'gui_OutputFcn',  @uiaddinsertion_OutputFcn, ...
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

%% Figure callbacks
function uiaddinsertion_OpeningFcn(hObject, evt, h, varargin)
h.output = hObject;
h.fig_needles = getappdata(0, 'Needles');
set(findobj('parent', h.fig_main, 'style', 'edit'), 'callback', {@update_insertion, h.fig_main})
guidata(hObject, h);

function varargout = uiaddinsertion_OutputFcn(hObject, evt, h) 
varargout{1} = h.output;

function fig_main_CloseRequestFcn(fig, evt, h)
% first remove the electrode that was added if it's a cancel or close event
try
    h = guidata(fig);
    D = getappdata(fig, 'Data');
    Dn = getappdata(h.fig_needles, 'Data');
    if isfield(D, 'index'), Dn.E.remove_probe(D.index); end
    % then remove graphic objects
end
delete(fig);

%% Objects Callbacks
function pb_ok_Callback(hobj, evt, h)
D = getappdata(h.fig_main, 'Data');
D = rmfield(D, 'index');
setappdata(h.fig_main, 'Data')
close(h.fig_main)

function pb_cancel_Callback(hobj, evt, h)
close(h.fig_main)

function update_insertion(hobj, evt, fig)
h = guidata(fig);
D = getappdata(fig, 'Data');
hn = guidata(h.fig_needles);
Dn = getappdata(h.fig_needles, 'Data');
% first step is to get all information from the edit boxes in a data struct
edit_boxes = findobj('parent', h.fig_main, 'style', 'edit');
v = struct();
for m = 1:length(edit_boxes)
    nam = strrep(get(edit_boxes(m), 'tag'), 'ed_', '');
    eval(['v.' nam '=' get(edit_boxes(m), 'String') ';'])
end
% init
if ~isfield(D, 'index'), D.index = Dn.E.n + 1; end
% creates/update the probe and plot in Needles
Dn.E.add_probe(v.dv / 1e6, v.ml / 1e6, v.ap / 1e6, v.theta, v.phi, v.depth / 1e6, 'index', D.index);
dvmlap = [Dn.E.dvmlap_entry(D.index, :) ; Dn.E.dvmlap_tip(D.index, :)];
% update the Needles display
hn.fcn.Update_Slices(h.fig_needles, [], mean(dvmlap(:, 3)))
hn.fcn.pl_top_electrodes_ButtonDownFcn(h.fig_needles, [], D.index)
% hn.fcn.electrodes_update(hobj, evt, Dn.E)
% update variables and exit
setappdata(fig, 'Data', D);
guidata(fig,  h);
