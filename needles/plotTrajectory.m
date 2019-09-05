

function lab = plotTrajectory(ax, atlas, vectorStart, vectorEnd)
% vectorStart and vectorEnd are in units of mm from bregma,

% get points at 1um spacing along the vector, including some beyond the
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

% the indices from the volume do not map directly to the table provided
[~, ilab] = ismember(uint32(lab), atlas.labels.index);
[iok, tind] = ismember(atlas.labels.table_index(ilab), atlas.labels.table.id);
brainLocations = cellfun(@(x) 'OUT', cell(length(ilab), 1), 'UniformOutput', false);
brainLocations(iok) = atlas.labels.table.acronym(tind(iok));



% plot the areas
trajX = trajX*trajScale; spacing = spacing*trajScale; padding = padding*trajScale;
im = imagesc(1, trajX, lab, 'Parent', ax);
set(ax, 'nextplot', 'add')
plot([0.5 1.5], padding*[1 1], 'k', 'LineWidth', 4.0); 
plot([0.5 1.5], (max(trajX)-padding)*[1 1], 'k', 'LineWidth', 4.0); 
fill([0.5 1.5 1.5 0.5], [0 0 padding padding], 'w', 'FaceAlpha', 0.8, 'EdgeAlpha', 0); 
fill([0.5 1.5 1.5 0.5], max(trajX)-[0 0 padding padding], 'w', 'FaceAlpha', 0.8, 'EdgeAlpha', 0); 

dLab = find(diff([-1; double(lab)])~=0);
if dLab(end)~=numel(lab); dLab(end+1) = numel(lab); end
for u = 1:(numel(dLab)-1)
    uy(u) = mean(dLab(u:u+1));
    plot([0.5 1.5], trajX(dLab(u))*[1 1]-0.5*spacing, 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5);
    itable = tind(dLab(u))
    if itable == 0
        sStr{u} = 'OUT';
    else
        uStr{u} = atlas.labels.table.acronym{itable};
    end
end

[uy,ii] = sort(uy); 
uStr = uStr(ii);

% add labels
set(ax, 'YTick', trajX(round(uy)-1), 'YTickLabel', uStr, 'XTick', [], 'TickDir', 'out'); 
box(ax, 'off'); 
axis(ax, 'image');
cmap = atlas.cmap; caxis(ax, [1 size(cmap,1)]); colormap(get(ax, 'Parent'), cmap);