function [ind, name] = uigetbrainlabel

h = guidata(getappdata(0, 'Needles'));
D = getappdata(h.fig_main);

ht.fig = figure('color', 'w', 'name', 'brain region', 'menubar',...
    'none', 'toolbar', 'none', 'numbertitle', 'off', 'Position',...
    [200, 200, 600, 220]);
set(ht.fig, 'keypressfcn', {@fig_key_press, ht.fig})
ht.lb = uicontrol('style', 'listbox', 'parent', ht.fig, 'position',...
    [200, 20, 360, 200], 'keypressfcn', {@fig_key_press, ht.fig});
ht.pb = uicontrol('style', 'pushbutton', 'Callback', {@pb_go, ht.fig},...
    'String', 'Go !');

ht.ed = javax.swing.JTextField();
ht.ed.setHorizontalAlignment(javax.swing.JTextField.CENTER)
javacomponent(ht.ed, [20, 200, 150, 20]);
set(ht.ed, 'KeyReleasedCallback', {@edit_callback, ht.fig});
guidata(ht.fig, ht)
set(ht.lb, 'string', D.Data.atlas.labels.name, 'UserData',...
    true(length(D.Data.atlas.labels.name), 1))

waitfor(ht.fig, 'UserData', true)
if ~ht.fig.isvalid
    ind=[]; name='';
    return
end
all_inds = find(get(ht.lb, 'UserData'));
ind = all_inds(get(ht.lb, 'Value'));
name =  D.Data.atlas.labels.name{ind};
ind = D.Data.atlas.labels.index(ind);
close(ht.fig)

function edit_callback(hobj, evt, fig)
typed_text = char(hobj.getText);
h = guidata(getappdata(0, 'Needles'));
D = getappdata(h.fig_main);
ht = guidata(fig);

ind = ~cellfun(@isempty, strfind(D.Data.atlas.labels.name, typed_text));
set(ht.lb, 'string', D.Data.atlas.labels.name(ind),...
    'userdata', ind, 'value', 1)

function fig_key_press(hobj, evt, fig)
switch evt.Key
    case 'return'
        set(fig, 'UserData', true)
end

function pb_go(hobj, evt, fig)
set(fig, 'UserData', true)
