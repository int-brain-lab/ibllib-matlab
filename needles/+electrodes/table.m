h = guidata(hobj);
D = getappdata(h.fig_main, 'Data');


h.fig_elec = figure('color', 'w', 'toolbar', 'none', 'menubar', 'none', 'numbertitle',...
    'off', 'name', 'Electrode List')

h.tab_elec = uitable('Parent', h.fig_elec, 'Units', 'normalized', 'Position', [0 0 1 1])

h.tab_elec.Data = randi(100)