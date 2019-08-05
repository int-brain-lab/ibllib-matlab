function varargout = Needles(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Needles_OpeningFcn, ...
                   'gui_OutputFcn',  @Needles_OutputFcn, ...
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


function Needles_OpeningFcn(hobj, evt, h, varargin)
h.output = hobj;
h.ver = '1.0.0';
setappdata(0, 'Needles', h.fig_main)
guidata(hobj, h);
set(h.menu_electrode, 'Enable', 'off')


function varargout = Needles_OutputFcn(hobj, evt, h) 
logo = logo_ibl('square');
h.im_logo = image(logo, 'Parent', h.axes_logo);
axis(h.axes_logo, 'off');
% init preferences: when needed, to automatic check to add new prefs
default = struct('path_atlas', pwd,  'lateralize', true);
pfile = [fileparts(mfilename('fullpath')) filesep 'needles_param.json'];
if ~exist(pfile, 'file')
    io.write.json(pfile, default)
end
h.pref = io.read.json(pfile);
h.fcn.Update_Slices = @Update_Slices;
h.fcn.Update_txt_electrodes = @Update_txt_electrodes;
h.fcn.Update_Electrodes = @electrodes_update;
h.fcn.Load_Atlas =  @menu_file_loadatlas_Callback;
% wrap-up and save in handles
guidata(hobj, h);
varargout{1} = h.output;


function load_atlas(h, atlas_label)
cmap = 'bone';
switch true
    case startsWith(atlas_label, 'ibl')
        set(h.txt_title, 'String', 'Stretched version of Allen Brain Institute CCF')
        lims = struct('ap_lims', [-0.0084786 0.00313056], 'ml_lims', [-0.004 0.004]);
        pref_field = 'allen';
    case startsWith(atlas_label, 'allen')
        set(h.txt_title, 'String', 'Allen Brain Institute CCF')
        lims = struct('ap_lims',[-0.0078 0.00288], 'ml_lims', [-0.004 0.004]);
        pref_field = 'allen';
    case strcmp(atlas_label, 'waxholm')
        lims = struct('ap_lims', [-.009205 .004288], 'ml_lims', [-0.004 0.004]);
        pref_field = 'waxholm';
    case strcmp(atlas_label, 'dsurqe')
        set(h.txt_title, 'String', 'Dorr et.al., 2008, High resolution three-dimensional brain atlas using an average magnetic resonance image of 40 adult C57Bl/6J mice.')
        lims = struct('ap_lims', [-0.0078 0.00288], 'ml_lims', [-0.004 0.004]);
        pref_field = 'dsurqe';
end
D.atlas = BrainAtlas(h.pref.(pref_field).path, atlas_label);

% make a direct orthogonal system with your right hand (thumb, index and middle finger),
% point the middle finger towards center of Earth
% If you are standing and your head is straight ahead, your fingers define the directions of ML,AP, DV

% X: ML (pitch), 2nd_dim (left + right -)
% Y: AP (roll), 3d_dim +-
% Z: DV (yaw), 1st_dim -+
% VOL(Z, X, Y)
[D.E] = first_pass_map(D.atlas);

[h.fig_table_elec, h.table_elec] = D.E.show_table;
set(h.table_elec, 'CellSelectionCallback', @table_e_cellSelection)
bc = D.atlas.brain_coor;
% Create all the objects depending on the top axes
h.im_top = imagesc(bc.yscale, bc.xscale, D.atlas.surf_top', 'Parent', h.axes_top);
set(h.axes_top, 'ydir', 'reverse','DataAspectRatio',[1 1 1], 'NextPlot', 'add')
set(h.axes_top,'UserData', round(bc.y2i(0))) % WIndow motion callback
xlabel(h.axes_top, 'AP'), ylabel(h.axes_top, 'ML')
colormap(h.axes_top, cmap);
h.pl_top_origin = plot(h.axes_top, 0,0, 'r+');
h.pl_top_zone_lock = plot(h.axes_top, NaN, 0,'.','MarkerSize',5,'Color',color_from_index(6));
h.pl_top_apline = plot(h.axes_top, [0 0], [bc.xlim], 'color', color_from_index(2));
set(h.pl_top_apline, 'ButtonDownFcn', @pl_top_apline_ButtonDownFcn)
h.pl_top_electrodes = plot(h.axes_top, D.E.dvmlap_entry(:,3), D.E.dvmlap_entry(:,2), '.', ...
'ButtonDownFcn', @pl_top_electrodes_ButtonDownFcn, 'MarkerSize', 10, 'Color','w');
h.pl_top_current_elec = plot(h.axes_top, NaN, NaN, '*', 'color', 'm', 'MarkerSize',12);

% Create all the objects depending on the contrast axes
h.im_phy = imagesc(bc.xscale, bc.zscale,  D.atlas.vol_image(:,:,round(bc.y2i(0))), 'Parent', h.axes_phy);
set(h.axes_phy, 'DataAspectRatio',[1 1 1], 'NextPlot', 'add')
h.pl_phy_origin = plot(h.axes_phy, 0,0, 'r+');
h.pl_phy_xr = plot(h.axes_phy, [bc.xlim NaN 0 0], [0 0 NaN bc.ylim], 'Color', color_from_index(2));
h.pl_phy_zone = plot(h.axes_phy, NaN, 0,'.','MarkerSize',4,'Color',color_from_index(5), 'ButtonDownFcn', @pl_zone_ButtonDownFcn);
h.pl_phy_zone_lock = plot(h.axes_phy, NaN, 0,'.','MarkerSize',4,'Color',color_from_index(6));
h.pl_phy_electrodes(1) = plot(h.axes_phy, NaN, NaN, 'linewidth', 2, 'Color', color_from_index(3));
h.pl_phy_electrodes(2) = plot(h.axes_phy, NaN, NaN, 'linewidth', 2, 'Color', color_from_index(4));
h.pl_phy_electrodes_traj(1) = plot(h.axes_phy, NaN, NaN, '--', 'Color', color_from_index(3)); % Full electrode trajectory
h.pl_phy_electrodes_traj(2) = plot(h.axes_phy, NaN, NaN, '--', 'Color', color_from_index(4)); % Full electrode trajectory
h.pl_phy_current_elec = plot(h.axes_phy, NaN, NaN, '*', 'color', 'm', 'MarkerSize',12);
xlabel(h.axes_phy, 'ML'), ylabel(h.axes_phy, 'DV')
colormap(h.axes_phy, cmap)
% Create all the objects depending on the label axes
h.im_lab = imagesc(bc.xscale, bc.zscale,  D.atlas.vol_labels(:,:,round(bc.y2i(0))), 'Parent', h.axes_label);
set(h.axes_label, 'DataAspectRatio',[1 1 1], 'NextPlot', 'add')
h.pl_lab_origin = plot(h.axes_label, 0,0, 'r+');
h.pl_lab_xr = plot(h.axes_label, [bc.xlim NaN 0 0], [0 0 NaN bc.ylim], 'Color', color_from_index(2));
h.pl_lab_zone = plot(h.axes_label, NaN, 0,'.','MarkerSize',4,'Color',color_from_index(5), 'ButtonDownFcn', @pl_zone_ButtonDownFcn);
h.pl_lab_zone_lock = plot(h.axes_label, NaN, 0,'.','MarkerSize',4,'Color',color_from_index(6));
h.pl_lab_electrodes(1) = plot(h.axes_label, NaN, NaN, 'linewidth', 2, 'Color', color_from_index(3));
% h.pl_lab_electrodes(2) = plot(h.axes_label, NaN, NaN, 'linewidth', 2, 'Color', color_from_index(4));
h.pl_lab_electrodes_traj(1) = plot(h.axes_label, NaN, NaN, '--', 'Color', color_from_index(3)); % Full electrode trajectory
% h.pl_lab_electrodes_traj(2) = plot(h.axes_label, NaN, NaN, '--', 'Color', color_from_index(4)); % Full electrode trajectory
h.pl_lab_current_elec = plot(h.axes_label, NaN, NaN, '*', 'color', 'm', 'MarkerSize',12);
xlabel(h.axes_label, 'ML'), ylabel(h.axes_label, 'DV')
colormap(h.axes_label, cmap)
% Init graphic states for callbacks
set([h.pl_phy_xr, h.pl_lab_xr, h.pl_phy_zone, h.pl_lab_zone], 'Visible', 'Off')
set(h.fig_main,'WindowButtonMotionFcn', {@fig_main_WindowButtonMotionFcn, h})
% prevents from re-loading the Atlas for the time being
set([h.menu_file_allen50, h.menu_file_dsurqe], 'Enable', 'off')
h.txt_top_apline = text(NaN, NaN, '', 'Parent', h.axes_top, 'Color', color_from_index(2),'Fontsize',12, 'Fontweight', 'bold');
guidata(h.fig_main, h)
setappdata(h.fig_main, 'Data', D)
set(h.pan_electrode, 'Visible', 'on')

function electrodes_update(hobj, evt, E)
h = guidata(hobj);
D = getappdata(h.fig_main, 'Data');
D.E = E;
set(h.pl_top_electrodes, 'xdata', D.E.xyz_entry(D.E.esel,2), 'ydata', D.E.xyz_entry(D.E.esel,1));
setappdata(h.fig_main, 'Data', D)

function pl_top_electrodes_ButtonDownFcn(hobj, evt, ie)
h = guidata(hobj);
D = getappdata(h.fig_main, 'Data');
bc = D.atlas.brain_coor;
% if the callback comes from the plot get the index. If it comes from the
% table, we already have the index provided
if nargin <=2
    ie = find((abs(evt.Source.XData-evt.IntersectionPoint(1)) < 1e-9) & ...
        (abs(evt.Source.YData-evt.IntersectionPoint(2)) < 1e-9));
end
% Find the electrode index from the plot to the data structure
ap_current = D.E.dvmlap_entry(ie(1),3);
Update_Slices(h.fig_main, [], ap_current);
set(h.axes_top,'UserData', round(bc.y2i(ap_current(1))))
Update_txt_electrodes(hobj, ie);
set([ h.pl_lab_current_elec, h.pl_phy_current_elec],'Visible', 'on',...
    'xdata', D.E.dvmlap_entry(ie,2), 'ydata', D.E.dvmlap_entry(ie,1))
set( h.pl_top_current_elec,'Visible', 'on',...
    'xdata', D.E.dvmlap_entry(ie,3), 'ydata', D.E.dvmlap_entry(ie,2))
drawnow
% get(h.fig_main, 'SelectionType')
if false && ishandle(h.fig_table_elec)
    get(h.table_elec)
    jUIScrollPane = findjobj(h.table_elec);
    jUITable = jUIScrollPane.getViewport.getView;
    jUITable.changeSelection(ie, 0, false, false);
end


try % FIXME test for other Atlases without cmap
% this will have to move to a method of Electrode Map
ie = ie(1);
f = findobj('Name', 'Trajectory', 'type', 'figure');
if isempty(f)
    f = figure('Color', 'w', 'Position', [200, 100, 380, 900], 'name', 'Trajectory', 'menubar', 'none', 'toolbar', 'none');
    h_.ax1 = subplot(5,1,1, 'parent', f);
    h_.ax2 = subplot(5,1,[2:5], 'parent', f);
    guidata(f, h_);
else
    h_ = guidata(f);
end
entry = D.E.dvmlap_entry(ie,:)*1e3;
tip = D.E.dvmlap_tip(ie,:)*1e3;
angle = atand((entry(2)-tip(2))/(entry(1)-tip(1)));

% slice
D.E.plot_probes_at_slice(D.atlas, h_.ax1, ap_current, ie);
title(sprintf('%.1fap, %.1fml\n%d deg', entry(3), entry(2), round(angle)));
D.E.plot_brain_loc(ie, h_.ax2, D.atlas);
end

function table_e_cellSelection(hobj, evt)
set(hobj, 'UserData', evt)
fig = getappdata(0, 'Needles');
pl_top_electrodes_ButtonDownFcn(fig, evt, evt.Indices(1))


function pl_zone_ButtonDownFcn(hobj, evt)
h = guidata(hobj);
D = getappdata(h.fig_main,'Data');
bc = D.atlas.brain_coor;
plock = [h.pl_lab_zone_lock h.pl_phy_zone_lock];
labind = get(h.pl_lab_zone, 'userdata');
set(plock,'xdata', get(h.pl_lab_zone, 'xdata') ,'ydata', get(h.pl_lab_zone, 'ydata'), 'userdata', labind)
set(h.txt_labels_lock, 'String', get(h.txt_labels, 'string'), 'Visible', 'on')
[iml, iap] = find(squeeze(sum(D.atlas.vol_labels(:,:,:)== labind, 1)));
set(h.pl_top_zone_lock, 'xdata', bc.i2y(iap), 'ydata', bc.i2x(iml))


function pl_top_apline_ButtonDownFcn(hobj, evt)
h = guidata(hobj);
set(h.axes_top,'UserData', NaN)
set(h.fig_main, 'WindowButtonUpFcn', @pl_top_apline_ButtonUpFcn)
set([h.pl_lab_zone h.pl_phy_zone], 'xdata', NaN, 'ydata', NaN)
set([h.txt_labels], 'String', '')


function pl_top_apline_ButtonUpFcn(hobj, evt)
h = guidata(hobj);
D = getappdata(hobj, 'Data');
bc = D.atlas.brain_coor;
ap_current = get(h.pl_top_apline, 'xdata');
Update_Slices(h.fig_main, [], ap_current)
set(h.axes_top,'UserData', round(bc.y2i(ap_current(1))))
set(h.fig_main, 'WindowButtonUpFcn', '')


function fig_main_WindowButtonMotionFcn(hobj, evt, h)
% Next gets executed if over slice or label axes
xy = get(h.axes_phy, 'CurrentPoint');
if between(xy(1), get(h.axes_phy,'xlim')) && between(xy(3), get(h.axes_phy,'ylim'))
    Update_CrossHairs(hobj, evt, xy([1 3]))
    Update_Labels(hobj, evt, xy([1 3]))
    return
end
xy = get(h.axes_label, 'CurrentPoint');
if between(xy(1), get(h.axes_label,'xlim')) && between(xy(3), get(h.axes_label,'ylim'))
    Update_CrossHairs(hobj, evt, xy([1 3]))
    Update_Labels(hobj, evt, xy([1 3]))
    return
end
% stuff gets executed if over top axes
xy = get(h.axes_top, 'CurrentPoint');
if between(xy(1), get(h.axes_top,'xlim')) && between(xy(3), get(h.axes_top,'ylim'))
    set([h.pl_phy_xr, h.pl_lab_xr], 'Visible', 'Off')
    Update_txt_xyz(hobj, xy(3), xy(1), NaN)
    if isnan(get(h.axes_top, 'UserData'))
        Update_Slices(h.fig_main, [], xy(1));
    end
    return
end
set([h.pl_phy_xr, h.pl_lab_xr], 'Visible', 'Off')
ap = get(h.pl_top_apline, 'Xdata');
Update_txt_xyz(h.txt_xyz, NaN, ap(1), NaN);


function Update_CrossHairs(hobj, evt, ml_dv)
h = guidata(hobj);
D = getappdata(hobj, 'Data');
bc = D.atlas.brain_coor;
set([h.pl_phy_xr, h.pl_lab_xr, h.pl_phy_zone, h.pl_lab_zone], 'Visible', 'On')
set( [h.pl_lab_xr, h.pl_phy_xr], 'xdata', [bc.xlim NaN ml_dv([1 1])],...
    'ydata', [ml_dv([2 2]) NaN bc.ylim]);
ap = get(h.pl_top_apline, 'Xdata');
Update_txt_xyz(h.txt_xyz, ml_dv(1), ap(1), ml_dv(2));


function Update_txt_electrodes(hobj, ie)
h = guidata(hobj);
D = getappdata(h.fig_main, 'Data');
set(h.pan_electrode, 'Visible', 'on');
set(h.txt_electrode, 'Visible', 'on', 'String', { '', ...
    ['Line: ' num2str(D.E.coronal_index(ie(1)), '%04.0f')], ...
    ['Point: ' num2str(D.E.sagittal_index(ie(1)), '%04.0f')], ...
    ['AP: ' num2str(D.E.dvmlap_entry(ie(1),3)*1e3, '%6.3f (mm)')],...
    ['ML: ' num2str(D.E.dvmlap_entry(ie(1),2)*1e3, '%6.3f (mm)')]});
%     ['Depths (shallow): ' num2str(D.E.length(ie(1)',1)*1e6, '%06.0f (um)')],...
%     ['Depths (deep): ' num2str(D.E.length(ie(2)',1)*1e6, '%06.0f (um)')]},...


function Update_txt_xyz(hobj, ml, ap, dv)
h = guidata(hobj);
set(h.pan_xyz, 'Visible', 'on')
set(h.txt_xyz, 'String', {[num2str(ml.*1e3, '%6.3f ML (mm)')],'',...
                          [num2str(ap.*1e3, '%6.3f AP(mm)')],'',...
                          [num2str(dv.*1e3, '%6.3f DV (mm)')]},...
                          'Visible', 'on')


function Update_Labels(hobj, evt, ml_dv)
h = guidata(hobj);
D = getappdata(hobj, 'Data');
bc = D.atlas.brain_coor;
yi = round(bc.y2i(get(h.pl_top_apline,'xdata')));
labind = D.atlas.vol_labels(  round(bc.z2i(ml_dv(2))), round(bc.x2i(ml_dv(1))), yi(1));
if labind==0, return, end
[x,z]= find(D.atlas.vol_labels(:,:,yi)== labind);
set([h.pl_phy_zone h.pl_lab_zone], 'xdata', bc.i2x(z), 'ydata', bc.i2z(x), 'visible', 'on', 'UserData', labind)
structure = D.atlas.labels.name{D.atlas.labels.index==labind};
try
    set(h.txt_labels, 'String', structure, 'Visible', 'On')
catch
    disp(structure)
end


function Update_Slices(hobj, evt, ap)
D = getappdata(hobj, 'Data');
h = guidata(hobj);
bc = D.atlas.brain_coor;
% from the top axis handle line and associated text
set(h.pl_top_apline, 'Xdata', ap([1 1]));
ytxt = max(bc.xlim) - diff(bc.xlim)*0.05;
set(h.txt_top_apline, 'String', num2str(ap(1)*1e3, '%6.3f (mm) AP'), 'Position', [ap(1) ytxt 0])
ap_slice = round(bc.y2i( ap(1)) );
% display the coronal slices on the physio and MRI axes
if between(ap_slice,[1 bc.ny])
    set(h.im_phy, 'CData', D.atlas.vol_image(:,:,ap_slice))
    set(h.im_lab, 'CData', D.atlas.vol_labels(:,:,ap_slice))
end
set([h.pl_lab_zone, h.pl_phy_zone], 'visible', 'off')
set([h.pl_phy_current_elec h.pl_lab_current_elec], 'visible', 'off')
% Update the current locked zone if any
labind = get(h.pl_lab_zone_lock, 'Userdata');
if ~isempty(labind)
    [x,z]= find(D.atlas.vol_labels(:,:,ap_slice)== labind);
    set([h.pl_phy_zone_lock h.pl_lab_zone_lock], 'xdata', bc.i2x(z), 'ydata', bc.i2z(x))
end
% Find the electrodes from the closest coronal plane
[d, ie] = min(abs(ap(1) -  D.E.dvmlap_entry(:,3)));
i1 = abs( D.E.dvmlap_entry(:,3) - D.E.dvmlap_entry(ie,3)) < .0003;
% Plot Electrodes
lineplot = @(xyz0,xyz1,n) flatten([xyz0(:,n) xyz1(:,n) xyz1(:,n).*NaN]');
% plot 10 degres insertions, active shank and full track
% i1 = D.E.esel & ie & abs(D.E.theta) == 10*pi/180;
set([h.pl_phy_electrodes(1) h.pl_lab_electrodes(1)],...
    'xdata', lineplot(D.E.dvmlap_entry(i1,:), D.E.dvmlap_tip(i1,:),2),...
    'ydata', lineplot(D.E.dvmlap_entry(i1,:), D.E.dvmlap_tip(i1,:),1))
set([h.pl_phy_electrodes_traj(1) h.pl_lab_electrodes_traj(1)],...
    'xdata', lineplot(D.E.dvmlap_entry(i1,:), D.E.dvmlap_tip(i1,:),2),...
    'ydata', lineplot(D.E.dvmlap_entry(i1,:), D.E.dvmlap_tip(i1,:),1))
% plot 20 degres insertions, active shank and full track
% i2 = D.E.esel & ie & abs(D.E.theta) == 20*pi/180;
% set([h.pl_phy_electrodes(2) h.pl_lab_electrodes(2)],...
%     'xdata', lineplot(D.E.xyz0(i2,:), D.E.xyz_(i2,:),1),...
%     'ydata', lineplot(D.E.xyz0(i2,:), D.E.xyz_(i2,:),3))
% set([h.pl_phy_electrodes_traj(2) h.pl_lab_electrodes_traj(2)],...
%     'xdata', lineplot(D.E.xyz_entry(i2,:), D.E.xyz_exit(i2,:),1),...
%     'ydata', lineplot(D.E.xyz_entry(i2,:), D.E.xyz_exit(i2,:),3))


function fig_main_KeyPressFcn(hobj, evt, h)
h = guidata(h.fig_main);
D = getappdata(h.fig_main, 'Data');
ap = get(h.pl_top_apline, 'Xdata');
switch true
    % lock to posterior electrode plane
    case strcmp(evt.Key, 'leftarrow') & strcmp(evt.Modifier,'control')        
        dap = unique(D.E.xyz_entry(:,2)) - ap(1);
        ap_new = dap (find(dap < 0 , 1 , 'last')) + ap(1);
        % lock to anterior electrode plane
    case strcmp(evt.Key, 'rightarrow') & strcmp(evt.Modifier,'control')
        dap = unique(D.E.xyz_entry(:,2)) - ap(1);
        ap_new = dap (find(dap > 0 , 1 , 'first')) + ap(1);
        % lock to posterior electrode plane
    case strcmp(evt.Key, 'leftarrow')
        ap_slice = round(bc.y2i( ap(1)) ) - 1;
        ap_new = bc.i2y(ap_slice);
        % lock to anterior electrode plane
    case strcmp(evt.Key, 'rightarrow')
        ap_slice = round(bc.y2i( ap(1)) ) + 1;
        ap_new = bc.i2y(ap_slice);
    otherwise, return
end

Update_Slices(hobj, [], ap_new)
Update_txt_xyz(hobj, NaN,  ap_new, NaN)

function menu_about_Callback(hobj, evt, h)
h = guidata(hobj);
message = {'International Brain Laboratory', ...
           'Github: https://github.com/int-brain-lab/WGs',...
           'MIT License', ...
           'Atlas from http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti/'}
f = msgbox(message, ['Needles v' h.ver])

function menu_file_ibl10_Callback(hobj, evt, h)
load_atlas(h, 'ibl10')

function menu_file_ibl25_Callback(hobj, evt, h)
load_atlas(h, 'ibl25')

function menu_file_ibl50_Callback(hobj, evt, h)
load_atlas(h, 'ibl50')

function menu_file_ibl100_Callback(hobj, evt, h)
load_atlas(h, 'ibl100')

function menu_file_allen10_Callback(hobj, evt, h)
load_atlas(h, 'allen10')

function menu_file_allen25_Callback(hobj, evt, h)
load_atlas(h, 'allen25')

function menu_file_allen50_Callback(hobj, evt, h)
load_atlas(h, 'allen50')

function menu_file_allen100_Callback(hobj, evt, h)
load_atlas(h, 'allen100')

function menu_file_waxholm_Callback(hobj, evt, h)
load_atlas(h, 'waxholm')

function menu_file_dsurqe_Callback(hobj, evt, h)
load_atlas(h, 'dsurqe')

function menu_electrode_table_Callback(hobj, evt, h)
function menu_electrode_load_Callback(hobj, evt, h)
function menu_electrode_write_Callback(hobj, evt, h)
