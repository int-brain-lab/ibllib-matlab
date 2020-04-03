function [vol_labels, vol_image, bc, labels, cmap] = get_allen(atlas_path, varargin)

%% All units SI
% http://help.brain-map.org/display/mousebrain/API#API-DownloadImages
% http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/ara_nissl/

BREGMA = [0+33.2, 570+3.9, 1320-540]; % Bregma indices DV ML AP for the 10nm Atlas

p = inputParser;
p.addOptional('res_um', 50);
p.addParameter('DV_SCALE', 1);
p.addParameter('AP_SCALE', 1);
p.parse(varargin{:});
p.parse(varargin{:});
for fn = fieldnames(p.Results)', eval([fn{1} '= p.Results.' (fn{1}) ';']); end

file_label_csv = [fileparts(which('BrainAtlas')) filesep 'allen_structure_tree.csv'];

nrd_file_annotations =  [atlas_path filesep 'annotation_' num2str(res_um) '.nrrd'];
nrd_file_nissl =  [atlas_path filesep 'average_template_' num2str(res_um) '.nrrd'];

if ~exist(nrd_file_nissl, 'file')
    warning('Atlas template file not found, trying to load ara nissl instead')
    nrd_file_nissl =  [atlas_path filesep 'ara_nissl_' num2str(res_um) '.nrrd'];
end

res = res_um/1e6;
labels.table = readtable(file_label_csv);
[vol_labels_orig, hn] = io.read.nrrd(nrd_file_annotations );
[vol_image, hn] = io.read.nrrd(nrd_file_nissl );
% Organization in memory should reflect most frequent usage: coronal first, sagittal second and transverse last
% This is not important if the file is small, for a large file and memory mapping this will make the difference between usable and unusable
% V has dimensions (n_dv, n_ml, n_ap)
vol_labels_orig = flip(permute(vol_labels_orig,[1,3,2]),3); 
vol_image = flip(permute(vol_image,[1,3,2]),3);

% this takes a while but allows direct indexing and a grayscale colorbar
[id, ~] = unique(vol_labels_orig(:));
[labels.index, labels.table_index] = deal(id.*0);
vol_labels = zeros(size(vol_labels_orig), 'uint16');
for m = 1:length(id)
    if id(m)==0
        ind = 1; % this is "root"
    else
        ind = find(labels.table.id==id(m));
    end
    vol_labels(vol_labels_orig==id(m)) = ind-1;    
    labels.index(m) = ind -1;
    labels.name{m} = labels.table.name{ind};
    labels.table_index(m) = id(m);
end

BREGMA = (BREGMA * 10/res_um);

% create the braincoordinates object with the Bregma as defined above
bc = BrainCoordinates(vol_labels, 'dzxy', res);

zxy0 = -[bc.i2z(BREGMA(1)), bc.i2x(BREGMA(2)), bc.i2y(BREGMA(3))];
bc = BrainCoordinates(vol_labels, 'dzxy', res, 'zxy0', zxy0);

% apply scaling to the ap and dv axes
bc.dz = bc.dz*DV_SCALE;
yy = bc.dy*AP_SCALE;
origBregYidx = bc.y0/bc.dy;
bc.dy = yy;
bc.y0 = origBregYidx*yy;

% make the colormap
q = labels.table.color_hex_triplet;
q = cellfun(@(x) [repmat('0', 1 , 6-length(x)) x], q, 'uni', false);
c1 = cellfun(@(x)hex2dec(x(1:2)), q, 'uni', false);
c2 = cellfun(@(x)hex2dec(x(3:4)), q, 'uni', false);
c3 = cellfun(@(x)hex2dec(x(5:6)), q, 'uni', false);
cmap = horzcat(vertcat(c1{:}),vertcat(c2{:}),vertcat(c3{:}))./255;
