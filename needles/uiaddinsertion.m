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
% find Needles figure and assign callbacks to objects
h.fig_needles = getappdata(0, 'Needles');
set(findobj('parent', h.fig_main, 'style', 'edit'), 'callback', {@edits_callback, h.fig_main})
set(findobj('parent', h.fig_main, 'style', 'slider'), 'callback', {@sliders_callback, h.fig_main})
% set the dv, ml, ap sliders boundaries as they depend on the Atlas
D = getappdata(h.fig_needles, 'Data');
ml_lim = D.atlas.brain_coor.xlim * 1e6;
ap_lim = D.atlas.brain_coor.ylim * 1e6;
dv_lim = D.atlas.brain_coor.zlim * 1e6;
set(h.sl_ap, 'Min', ap_lim(1), 'Max', ap_lim(2))
set(h.sl_dv, 'Min', dv_lim(1), 'Max', dv_lim(2), 'Value', dv_lim(1))
set(h.sl_ml, 'Min', ml_lim(1), 'Max', ml_lim(2))
guidata(hObject, h);

function varargout = uiaddinsertion_OutputFcn(hObject, evt, h) 
varargout{1} = h.output;

function fig_main_CloseRequestFcn(fig, evt, h)
% first remove the electrode that was added if it's a cancel or close event
try
    h = guidata(fig);
    D = getappdata(fig, 'Data');
    Dn = getappdata(h.fig_needles, 'Data');
    if isfield(D, 'index'),
        Dn.E.remove_probe(D.index);
    end
end
delete(fig);

%% Objects Callbacks
function pb_ok_Callback(hobj, evt, h)
D = getappdata(h.fig_main, 'Data');
D = rmfield(D, 'index');
setappdata(h.fig_main, 'Data', D)
close(h.fig_main)

function pb_cancel_Callback(hobj, evt, h)
close(h.fig_main)

function sliders_callback(hobj, evt, fig)
% slider callbacks update corresponding edit box and triggers update
ed = findobj('parent', fig, 'tag', strrep(get(hobj, 'tag'), 'sl_', 'ed_'));
set(ed, 'String', num2str(get(hobj, 'value'), '%0.1f')) 
update_insertion(fig)

function edits_callback(hobj, evt, fig)
% edit callbacks update corresponding slider and triggers update
sl = findobj('parent', fig, 'tag', strrep(get(hobj, 'tag'), 'ed_', 'sl_'));
set(sl, 'Value', str2double(get(hobj, 'String')))
update_insertion(fig)


%% Main update function
function update_insertion(fig)
h = guidata(fig);
D = getappdata(fig, 'Data');
hn = guidata(h.fig_needles);
Dn = getappdata(h.fig_needles, 'Data');
% get the values from the edit boxes
edit_boxes = findobj('parent', h.fig_main, 'style', 'edit');
v = struct();
for m = 1:length(edit_boxes)
    nam = strrep(get(edit_boxes(m), 'tag'), 'ed_', '');
    eval(['v.' nam '=' get(edit_boxes(m), 'String') ';'])
end
% init
if ~isfield(D, 'index'), D.index = Dn.E.n + 1; end
% we lock the dv to the brain surface - maybe optional ? - this may go somewhere else at some point
iml = round(Dn.atlas.brain_coor.x2i(v.ml / 1e6));
iap = round(Dn.atlas.brain_coor.y2i(v.ap / 1e6));
idv = Dn.atlas.surf_top(iap, iml);
v.dv = Dn.atlas.brain_coor.i2z(idv) * 1e6;
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
