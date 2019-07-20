function h = show(self, h)
% display a 3D rendering of the brain


fv = isosurface(double(self.vol_labels) , 0.5);
% in this case the volume is out in pixel unit, convert to SI
iorigin = self.brain_coor.iorigin;
iorigin = iorigin([2 1 3]); 
fv.vertices = bsxfun( @minus, fv.vertices, iorigin);
fv.vertices = fv.vertices.* self.brain_coor.res;

if nargin <=1
    h.fig_volume = figure('Color','w'); h.ax = gca;
end
h.p = patch(fv);
set(h.ax, 'DataAspectRatio',[1 1 1], 'zdir', 'reverse')
xlabel(h.ax, 'x'), ylabel(h.ax, 'y'), zlabel(h.ax, 'z')
h.p.FaceColor = 'red';
h.p.EdgeColor = 'none';
h.p.FaceAlpha = 0.7;
view([-5,-500,0]);
camlight;

end

