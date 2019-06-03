function [V, h, cv] = get_allen(res_um)
% [V, h, cv] = brainatlas.get_allen(50);

%% All units SI
% http://help.brain-map.org/display/mousebrain/API#API-DownloadImages
% http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/ara_nissl/
if ~exist('res_um', 'var'), res_um = 50; end
file_label_csv = '/datadisk/BrainAtlas/structure_tree_safe_2017.csv';

switch res_um
    case 50
        nrd_file_annotations =  '/datadisk/BrainAtlas/annotation_50.nrrd';
        nrd_file_nissl =  '/datadisk/BrainAtlas/ara_nissl_50.nrrd';
    case 100
        nrd_file_annotations =  '/datadisk/BrainAtlas/annotation_100.nrrd';
        nrd_file_nissl =  '/datadisk/BrainAtlas/ara_nissl_100.nrrd';
end
res = res_um/1e6;
labels = readtable(file_label_csv);
[V.lab, hn] = io.read.nrrd(nrd_file_annotations );
[V.phy, hn] = io.read.nrrd(nrd_file_nissl );
% Organization in memory should reflect most frequent usage: coronal first, sagittal second and transverse last
% This is not important if the file is small, for a large file and memory mapping this will make the difference between usable and unusable
V.lab = flip(permute(V.lab,[1,3,2]),3); 
V.phy = flip(permute(V.phy,[1,3,2]),3); 

[id, ind] = unique(V.lab(:));
for m = 1:length(ind)
    V.lab(V.lab==id(m)) = ind(m)-1;
end

%
% close all
fv = isosurface(permute(V.lab~=0,[3, 2, 1]),0.5);
% in this case the volume is out in pixel unit, convert to SI
fv.vertices = fv.vertices.*res;
fv.faces= fv.faces;

cv = CartesianVolume(V.lab, res, mean(fv.vertices));
fv.vertices = bsxfun( @minus, fv.vertices, mean(fv.vertices));

h.fig_volume = figure('Color','w'); h.p = patch(fv); h.ax = gca;
set(h.ax, 'DataAspectRatio',[1 1 1], 'zdir', 'reverse')
xlabel(h.ax, 'x'), ylabel(h.ax, 'y'), zlabel(h.ax, 'z')
h.p.FaceColor = 'red';
h.p.EdgeColor = 'none';
h.p.FaceAlpha = 0.7;
view(69,42);
camlight;

