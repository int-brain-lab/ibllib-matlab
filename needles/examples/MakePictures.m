h = guidata(Needles);
OUTPUT_DIR = ['PICS'];

D = getappdata(h.fig_main, 'Data');


E = structfun(@(x) x(D.E.esel,:), D.E, 'UniformOutput', false);
[l, il] = unique(E.Line);
%%
for m = 1:length(l)
    set(h.pl_top_current_elec, 'Visible', 'off')
    
    ap_current = E.xyz0(il(m),2);
    h.fcn.Update_Slices(h.fig_main, [], ap_current);
    
    h.fcn.Update_txt_electrodes(h.fig_main, find(D.E.Line==l(m),1,'first'))
    
    set(h.fig_main,'PaperPositionMode','auto')
    im_name = ['cline_' num2str(l(m), '%04.0f') '_coronal_slice_' num2str(ap_current*1e6, '%06.0fnm')];
    disp(im_name)
    print( h.fig_main, [OUTPUT_DIR filesep im_name], '-dpng')
    pause(1)
end

