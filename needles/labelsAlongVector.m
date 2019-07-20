

function lab = labelsAlongVector(atlas, zyx_sites)

% get labels from those points - convert to indices
inds = atlas.brain_coor.zxy2iii(zyx_sites);
av = atlas.vol_labels; 

% clip ones that are out of range
for d = 1:3; inds(:,d) = min(max(inds(:,d),1),size(av,d)); end

inds = round(inds); 

lab = av(sub2ind(size(av), inds(:,1), inds(:,2), inds(:,3)));