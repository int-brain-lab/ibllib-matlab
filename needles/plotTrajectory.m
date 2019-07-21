

function lab = plotTrajectory(ax, atlas, vectorStart, vectorEnd)
% vectorStart and vectorEnd are in units of mm from bregma,

% get points at 1µm spacing along the vector, including some beyond the
% limits
spacing = 50e-6; 
padding = 1e-3; % 1 mm on either side
trajScale = 1e4*0.7;

len = norm(vectorEnd-vectorStart);
vectorDir = (vectorEnd-vectorStart)./len; 
startSamp = vectorStart-vectorDir*padding; 
endSamp = vectorEnd+vectorDir*padding; 
trajX = 0:spacing:(len+2*padding); % the spatial coordinates along the trajectory
allSamp = startSamp+trajX'*vectorDir;

lab = labelsAlongVector(atlas, allSamp);

% plot the areas
trajX = trajX*trajScale; spacing = spacing*trajScale; padding = padding*trajScale;
im = imagesc(1, trajX, lab, 'Parent', gca);
hold on; 
plot([0.5 1.5], padding*[1 1], 'k', 'LineWidth', 4.0); 
plot([0.5 1.5], (max(trajX)-padding)*[1 1], 'k', 'LineWidth', 4.0); 
fill([0.5 1.5 1.5 0.5], [0 0 padding padding], 'w', 'FaceAlpha', 0.8, 'EdgeAlpha', 0); 
fill([0.5 1.5 1.5 0.5], max(trajX)-[0 0 padding padding], 'w', 'FaceAlpha', 0.8, 'EdgeAlpha', 0); 

dLab = find(diff([-1; double(lab)])~=0);
if dLab(end)~=numel(lab); dLab(end+1) = numel(lab); end
for u = 1:(numel(dLab)-1)
    uy(u) = mean(dLab(u:u+1));
    plot([0.5 1.5], trajX(dLab(u))*[1 1]-0.5*spacing, 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5);
    uStr{u} = atlas.labels.table.acronym{lab(dLab(u))+1};
end

[uy,ii] = sort(uy); 
uStr = uStr(ii);

% add labels
set(ax, 'YTick', trajX(round(uy)-1), 'YTickLabel', uStr, 'XTick', [], 'TickDir', 'out'); 
box(ax, 'off'); 
axis(ax, 'image');
cmap = atlas.cmap; caxis([1 size(cmap,1)]); colormap(cmap);