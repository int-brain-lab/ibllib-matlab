function [V, h, cv, labels] = get_dsurqe(atlas_path, varargin)
% [V, h, cv, labels] = brainatlas.get_dsurqe(atlas_path, varargin);
% [V, h, cv, labels] = brainatlas.get_dsurqe(..., 'lateralize', true, 'display', false);


% X: ML (pitch), 2nd_dim (left - right +)
% Y: AP (roll), 3d_dim +-
% Z: DV (yaw), 1st_dim -+
% VOL(Z, X, Y)

% NB: will have to add option for offset to origin for Bregma
p = inputParser;
addParameter(p,'lateralize', false);
addParameter(p,'display', true);...
parse(p,varargin{:});
parse(p,varargin{:});
for fn = fieldnames(p.Results)', eval([fn{1} '= p.Results.' (fn{1}) ';']); end

if nargin <=0, display=true; end

nii_file = [atlas_path filesep 'DSURQE_40micron_average.nii'];
V.phy = io.read.nii(nii_file);
nii_file = [atlas_path filesep 'DSURQE_40micron_labels.nii'];
[V.lab, H] = io.read.nii(nii_file);
label_file = [atlas_path filesep 'DSURQE_40micron_R_mapping.csv'];
%https://scalablebrainatlas.incf.org/mouse/WHS12
res = H.PixelDimensions(1)/1e3;
assert(all( H.PixelDimensions(1:3) - H.PixelDimensions(1)< eps))

V.lab = flip( permute(V.lab, [3, 1, 2]), 1);
V.phy = flip( permute(V.phy, [3, 1, 2, 4]), 1);

lab_ = readtable(label_file);

if lateralize
labels.name = [lab_.Structure ; lab_.Structure];
labels.index = [lab_.rightLabel ; lab_.leftLabel];
else
    labels.name = lab_.Structure;
    labels.index = lab_.rightLabel;
    for m = 1:length(lab_.leftLabel)
        V.lab(V.lab==lab_.leftLabel(m)) = lab_.rightLabel(m);
    end
end

% xyz0 = -mean(fv.vertices);
% THis is the 'COG' of the label vertices
xyz0 = [-0.00633537645743948 -0.00797709592544222 -0.0051982867355663];
xyz0 = xyz0 - [ 0 .002623 -.003723]; % BRegma estimate skull
% xyz0 = xyz0 - [ 0 .002623 -.003427]; % BRegma estimate brain

if ~display    
    cv = CartesianVolume(V.lab, res, xyz0);
    h=[];
    return
end


fv = isosurface(permute(V.lab~=0,[3, 2, 1]),0.5);
% in this case the volume is out in pixel unit, convert to SI
fv.vertices = fv.vertices.*res;
cv = CartesianVolume(V.lab, res, xyz0);

fv.vertices = bsxfun( @minus, fv.vertices, mean(fv.vertices));

h.fig_volume = figure('Color','w'); h.p = patch(fv); h.ax = gca;
set(h.ax, 'DataAspectRatio',[1 1 1], 'zdir', 'reverse')
xlabel(h.ax, 'x'), ylabel(h.ax, 'y'), zlabel(h.ax, 'z')
h.p.FaceColor = 'red';
h.p.EdgeColor = 'none';
h.p.FaceAlpha = 0.7;
view(69,42);
camlight;

