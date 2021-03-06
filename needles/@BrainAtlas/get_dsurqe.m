function [vol_labels, vol_image, bc, labels] = get_dsurqe(atlas_path, varargin)
% X: ML (pitch), 2nd_dim (left - right +)
% Y: AP (roll), 3d_dim +-
% Z: DV (yaw), 1st_dim -+
% VOL(Z, X, Y)

% NB: will have to add option for offset to origin for Bregma
p = inputParser;
addParameter(p,'lateralize', false);
parse(p,varargin{:});
parse(p,varargin{:});
for fn = fieldnames(p.Results)', eval([fn{1} '= p.Results.' (fn{1}) ';']); end
%https://scalablebrainatlas.incf.org/mouse/WHS12
nii_file_image = [atlas_path filesep 'DSURQE_40micron_average.nii'];
nii_file_labels = [atlas_path filesep 'DSURQE_40micron_labels.nii'];
label_file = [atlas_path filesep 'DSURQE_40micron_R_mapping.csv'];

vol_image = io.read.nii(nii_file_image);
[vol_labels, H] = io.read.nii(nii_file_labels);

res = H.PixelDimensions(1)/1e3;
assert(all( H.PixelDimensions(1:3) - H.PixelDimensions(1)< eps))

vol_labels = flip( permute(vol_labels, [3, 1, 2]), 1);
vol_image = flip( permute(vol_image, [3, 1, 2, 4]), 1);

lab_ = readtable(label_file);

% in this Atlas left and right hemishperes are lateralized (ie. different indices)
% we can choose to keep it this way (lateralize) or to merge the indices for both sides
if lateralize
labels.name = [lab_.Structure ; lab_.Structure];
labels.index = [lab_.rightLabel ; lab_.leftLabel];
else
    labels.name = lab_.Structure;
    labels.index = lab_.rightLabel;
    for m = 1:length(lab_.leftLabel)
        vol_labels(vol_labels==lab_.leftLabel(m)) = lab_.rightLabel(m);
    end
end

zxy0 = [-0.0051982867355663 -0.00633537645743948 -0.00797709592544222];
zxy0 = zxy0- [-.003723 0 .002623]; % BRegma estimate skull
bc = BrainCoordinates(vol_labels, 'dzxy', res, 'zxy0', zxy0);
