%% create an ElectrodeArray and insert some probes


coords = zeros(384,3); 
coords(:,1) = repmat([43; 11; 59; 27], 384/4, 1);
coords(:,2) = reshape(repmat(20:20:3840, 2, 1), 384, 1);
coords = coords.*1e-6;
e = ElectrodeArray([],[], 'site_coords', coords); 
% e.add_probe_by_start_angles([0 0 0], [90 80], 4*1e-3, ba);
%             e.add_probe_by_start_angles([0 0.5e-3 0], [90 80], 4*1e-3, ba);
%             e.add_probe_by_start_angles([0 1e-3 0], [90 80], 4*1e-3, ba);
%             e.add_probe_by_start_angles([0 1.5e-3 0], [90 80], 4*1e-3, ba);

angle = 80;
for xx = -6:0.5:3
    for yy = 0.5:0.5:3
        e.add_probe_by_start_angles([0 yy*1e-3 xx*1e-3], [90 angle], 14*1e-3, ba);
    end
end

angle = 110;
for xx = -6:0.5:3
    for yy = 0.5:0.5:3
        e.add_probe_by_start_angles([0 yy*1e-3 xx*1e-3], [90 angle], 4*1e-3, ba);
    end
end

%% plot1: by AP position
figure; 

uAP = unique(e.dvmlap_entry(:,3));
zs = ba.brain_coor.zscale; xs = ba.brain_coor.xscale;
for a = 1:numel(uAP)
    
    these = e.dvmlap_entry(:,3)==uAP(a);
    
    xy = e.dvmlap_entry(these,1:2);
    tips = e.dvmlap_tip(these,1:2);
    
    sliceIdx = round(ba.brain_coor.y2i(uAP(a)));
    
    subplot(4,5,a); 
    
    imagesc(xs,zs,ba.vol_image(:,:,sliceIdx));
    hold on; colormap gray; caxis([0 10000]); axis image;
    for idx = 1:size(xy,1)
        plot([xy(idx,2) tips(idx,2)], [xy(idx,1) tips(idx,1)], 'r', 'LineWidth', 2.0);
        hold on; 
    end
    xlabel('LR'); ylabel('DV');
    set(gca, 'YDir', 'reverse');
    drawnow;
    
end

%% plot the trajectories through the brain for just a particular ap slice.

figure; 
uAP = unique(e.dvmlap_entry(:,3));
a = 10; 
these = find(e.dvmlap_entry(:,3)==uAP(a));
for q = 1:numel(these)
    ax = subplot(1,10,q); 
    
    e.plot_brain_loc(these(q), ax, ba);
    drawnow;
end
