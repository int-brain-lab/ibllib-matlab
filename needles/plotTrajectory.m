

function lab = plotTrajectory(ax, atlas, vectorStart, vectorEnd)
% vectorStart and vectorEnd are in units of mm from bregma,

% get points at 1µm spacing along the vector, including some beyond the
% limits
spacing = 1e-6; 
padding = 1e-3; % 1 mm on either side

len = norm(vectorEnd-vectorStart);
vectorDir = (vectorEnd-vectorStart)./len; 
startSamp = vectorStart-vectorDir*padding; 
endSamp = vectorEnd+vectorDir*padding; 
trajX = 0:spacing:(len+2*padding); % the spatial coordinates along the trajectory
allSamp = startSamp+trajX'*vectorDir;

% get labels from those points - convert to indices
inds = atlas.brain_coor.zxy2iii(allSamp);
av = atlas.vol_labels; 

% clip ones that are out of range
for d = 1:3; inds(:,d) = min(max(inds(:,d),1),size(av,d)); end

lab = av(round(sub2ind(size(av), inds(:,1), inds(:,2), inds(:,3))));

% plot the areas
im = imagesc(1, trajX, lab, 'Parent', gca);
hold on; 
plot([0.5 1.5], padding*[1 1], 'k', 'LineWidth', 2.0); 
plot([0.5 1.5], (max(trajX)-padding)*[1 1], 'k', 'LineWidth', 2.0); 
fill([0.5 1.5 1.5 0.5], [0 0 padding padding], 'w', 'FaceAlpha', 0.7, 'EdgeAlpha', 0); 
fill([0.5 1.5 1.5 0.5], max(trajX)-[0 0 padding padding], 'w', 'FaceAlpha', 0.7, 'EdgeAlpha', 0); 

dLab = find(diff([-1; double(lab)])~=0);
dLab(end+1) = numel(lab);
for u = 1:(numel(dLab)-1)
    uy(u) = mean(dLab(u:u+1));
    uStr{u} = atlas.labels.acronym{lab(dLab(u))};
end

[uy,ii] = sort(uy); 
uStr = uStr(ii);

% add labels
set(ax, 'YTick', trajX(round(uy)), 'YTickLabel', uStr, 'XTick', [], 'TickDir', 'out'); 
box(ax, 'off'); 
cmap = atlas.cmap; caxis([1 size(cmap,1)]); colormap(cmap);