function slice = tilted_slice(self, linepts, sxdim, sydim, ssdim)
%         E.tilted_slice(linept, sxdim, sydim, ssdim)
%         Get a slice from the volume, tilted around 1 rotation axis
%         :param linepts: 2 points defining a probe trajectory. This trajectory is projected onto the
%         sxdim=0. The extracted slice corresponds to the plane orthogonal to the sxdim=0 plane
%         passing by the projected trajectory.
%         :param sxdim: = 0  coordinate system dimension corresponding to slice abscissa
%          (this direction is the rotation axis for tilt)
%         :param sydim: = 2  coordinate system dimension corresponding to slice ordinate
%         :param: ssdim: = 1  squeezed dimension
% %         For a tilted coronal slice (default), sxdim=ml, sydim=dv, ssdim=ap
% %         For a tilted sagittal slice, sxdim=ap, sydim=dv, ssdim=ml
%         For a tilted coronal slice (default), sxdim=2, sydim=1, ssdim=3
%         For a tilted sagittal slice, sxdim=3, sydim=1, ssdim=2

tilt_line = linepts;
tilt_line(:, sxdim) = 0;
tilt_line_i = round(self.brain_coor.zxy2iii(tilt_line));



n = size(self.vol_image);
tile_shape = [diff(tilt_line_i(:, sydim)) + 1, n(sxdim)];
indx = 1 : tile_shape(2);
indy = 1 : tile_shape(1);
inds = linspace(tilt_line_i(1, ssdim), tilt_line_i(1, ssdim),  tile_shape(1));
[~, INDS] = meshgrid(indx, round(inds));
[INDX, INDY] = meshgrid(indx, indy);
[~, ordre] = sort([ssdim sxdim sydim]);
IND = [INDS(:) INDX(:) INDY(:)];
IND = IND(:, ordre);



slice = reshape(self.vol_image(sub2ind(n, IND(:,1), IND(:,2), IND(:,3))), tile_shape);
figure, imagesc(slice), axis equal

end