function [f, h] = plotBrainGridIBL(apCoords, mlCoords, dvCoords)
% function plotBrainGrid([brainGridData], [ax])
% 
% To plot the wire mesh data loaded from brainGridData.npy. 

mf = mfilename('fullpath');
brainGridData = readNPY(fullfile(fileparts(mf), 'brainGridData.npy'));

bp = double(brainGridData); 
% bp(sum(bp,2)==0,:) = NaN; % when saved to uint16, NaN's become zeros. There aren't any real vertices at (0,0,0) and it shouldn't look much different if there were
nanEntry = sum(bp,2)==0;
ap = apCoords(round(bp(:,1)+1)); ap(nanEntry) = NaN;
ml = mlCoords(round(bp(:,2)+1));ml(nanEntry) = NaN;
dv = dvCoords(round(bp(:,3)+1));dv(nanEntry) = NaN;

h = plot3(ap, ml, dv, 'Color', [0 0 0 0.3]);

ax = gca;
set(ax, 'ZDir', 'reverse')
axis(ax, 'equal');
axis(ax, 'vis3d');
axis(ax, 'off');
    
   