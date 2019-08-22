function h = show(self, h)
% display a 3D rendering of the brain

%%
fv = isosurface(double(permute(self.vol_labels, [3, 2, 1])) , 0.5);
% in this case the volume is out in pixel unit, convert to SI
iorigin = self.brain_coor.iorigin;
iorigin = iorigin([2, 3, 1]); 
fv.vertices = bsxfun( @minus, fv.vertices, iorigin);
res = self.brain_coor.res;
fv.vertices = fv.vertices.* res([2, 3, 1]);

if nargin <=1
     h.fig_volume = figure('Color','w', 'name', ...
     '3D brain surface', 'numbertitle', 'off');
     h.ax = gca;
end
h.p = patch(fv);
set(h.ax, 'DataAspectRatio',[1 1 1], 'zdir', 'reverse', 'xdir', 'normal')
xlabel(h.ax, 'ml'), ylabel(h.ax, 'ap'), zlabel(h.ax, 'dv')
h.p.FaceColor = 'red';
h.p.EdgeColor = 'none';
h.p.FaceAlpha = 0.7;
view(-75, 45)
camlight;
%%
end

