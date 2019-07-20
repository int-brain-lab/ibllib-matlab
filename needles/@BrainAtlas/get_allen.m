function [vol_labels, vol_image, bc, labels] = get_allen(atlas_path, res_um)

%% All units SI
% http://help.brain-map.org/display/mousebrain/API#API-DownloadImages
% http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/ara_nissl/

BREGMA = [0, 570, 540]; % Bregma indices DV ML AP for the 10nm Atlas

if ~exist('res_um', 'var'), res_um = 50; end
file_label_csv = [atlas_path filesep 'structure_tree_safe_2017.csv'];

nrd_file_annotations =  [atlas_path filesep 'annotation_' num2str(res_um) '.nrrd'];
nrd_file_nissl =  [atlas_path filesep 'ara_nissl_' num2str(res_um) '.nrrd'];


res = res_um/1e6;
labels = readtable(file_label_csv);
[vol_labels, hn] = io.read.nrrd(nrd_file_annotations );
[vol_image, hn] = io.read.nrrd(nrd_file_nissl );
% Organization in memory should reflect most frequent usage: coronal first, sagittal second and transverse last
% This is not important if the file is small, for a large file and memory mapping this will make the difference between usable and unusable
vol_labels = flip(permute(vol_labels,[1,3,2]),3); 
vol_image = flip(permute(vol_image,[1,3,2]),3); 

[id, ind] = unique(vol_labels(:));
for m = 1:length(ind)
    vol_labels(vol_labels==id(m)) = ind(m)-1;
end


BREGMA = (BREGMA * 10/res_um);

% create the braincoordinates object with the Bregma as defined above
bc = BrainCoordinates(vol_labels, 'dzxy', res);

zxy0 = -[bc.i2z(BREGMA(1)), bc.i2x(BREGMA(2)), bc.i2y(BREGMA(3))];
bc = BrainCoordinates(vol_labels, 'dzxy', res, 'zxy0', zxy0);
