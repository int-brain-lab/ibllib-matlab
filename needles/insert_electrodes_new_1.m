%% create an ElectrodeArray and insert some probes


coords = zeros(384,3); 
coords(:,1) = repmat([43; 11; 59; 27], 384/4, 1);
coords(:,2) = reshape(repmat(20:20:3840, 2, 1), 384, 1)+200;
coords = coords.*1e-6;
e = ElectrodeArray([],[], 'site_coords', coords); 


% e.add_probe_by_start_angles([0 0 0], [90 80], 4*1e-3, ba);
%             e.add_probe_by_start_angles([0 0.5e-3 0], [90 80], 4*1e-3, ba);
%             e.add_probe_by_start_angles([0 1e-3 0], [90 80], 4*1e-3, ba);
%             e.add_probe_by_start_angles([0 1.5e-3 0], [90 80], 4*1e-3, ba);

%% version 1.0: 10 and -10 degrees, like from before

angle = 110;
for xx = -7.5:0.5:2.5
    for yy = 0.5:0.5:7
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], 4*1e-3, ba);
    end
end

angle = 80;
for xx = -7.5:0.5:2.5    
    for yy = 0.8:0.5:7 % deep ones point toward midline so start a bit more lateral        
        if yy<1
            dep = 4e-3; % first one is shallow - rest are deep
        else
            dep = 14e-3;
        end
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba);
    end
end

fprintf('n penetrations = %d\n', e.n);

%% version 2.0: shallower angles, to give more clearance

tilt = 15;

angle = 90+tilt;
for xx = -7.5:0.5:2.5
    for yy = 0.5:0.5:7
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], 4*1e-3, ba);
    end
end

n1 = e.n;

angle = 90-tilt;
for xx = -7.5:0.5:2.5    
    for yy = 0.8:0.5:7 % deep ones point toward midline so start a bit more lateral        
        if yy<1
            dep = 4e-3; % first one is shallow - rest are deep
        else
            dep = 14e-3;
        end
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba);
    end
end

fprintf('n penetrations = %d (%d and %d)\n', e.n, n1, e.n-n1);

%% version 2.1: only one is shallower
% A problem with this is that paired bilateral sites would have to be deep
% rather than superficial, i.e. they can't include cortex. This is another
% reason to go for the midline-going ones being superficial. 
tilt1 = 10;
tilt2 = 15;

angle = 90+tilt1;
for xx = -7.5:0.5:2.5
    for yy = 0.6:0.5:7
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], 4*1e-3, ba);
    end
end

n1 = e.n;

angle = 90-tilt2;
for xx = -7.5:0.5:2.5    
    for yy = 0.8:0.5:5.5 % deep ones point toward midline so start a bit more lateral        
        if yy<1
            dep = 4e-3; % first one is shallow - rest are deep
        else
            dep = 14e-3;
        end
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba);
    end
end

fprintf('n penetrations = %d (%d and %d)\n', e.n, n1, e.n-n1);

%% version 3.0: switch which ones are deep
% - gets perpendicular to layers in visual cortex and doesn't miss parts of
% SC
% - this version has really beautiful coverage but has about twice as many
% medial-going insertions as lateral-going. That's no good really. 
tilt = 10; 
spacing = 0.5; % mm

angle = 90+tilt; dep = 14e-3; minLR = 0.8;
for xx = -7.5:spacing:2.5
    for yy = minLR:spacing:3.0
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba);
    end
end
n1 = e.n;
angle = 90-tilt; dep = 4e-3; minLR = 0.8;
for xx = -7.5:spacing:2.5    
    for yy = minLR:spacing:7 

        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba);
        
        if yy==(minLR+spacing) || yy==(minLR+spacing*2) % for second and third, also go deep
            e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], 14e-3, ba);
        end
    end
end

fprintf('n penetrations = %d (%d and %d)\n', e.n, n1, e.n-n1);

%% version 4: trying version 3 but with shallower angles, though I don't think it'll help

tilt = 15; 
spacing = 0.5; % mm

angle = 90+tilt; dep = 14e-3; minLR = 0.8;
for xx = -7.5:spacing:2.5
    for yy = minLR:spacing:3.5
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba);
    end
end
n1 = e.n;
angle = 90-tilt; dep = 4e-3; minLR = 0.8;
for xx = -7.5:spacing:2.5    
    for yy = minLR:spacing:7 

        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba);
        
        if yy==(minLR+spacing) || yy==(minLR+spacing*2) % for second and third, also go deep
            e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], 14e-3, ba);
        end
    end
end

fprintf('n penetrations = %d (%d and %d)\n', e.n, n1, e.n-n1);
%% version 5: a version of superficial-midline-going but trying to even sites
e.removeAll();

tilt1 = 10; 
tilt2 = 15;
spacing = 0.5; % mm

angle = 90+tilt1; dep = 14e-3; minLR = 0.8;
for xx = -7.5:spacing:2.5
    for yy = [-1.0 -0.5 minLR:spacing:4]
        if yy<0 
            %useAngle = 90+17; 
            continue
        else
            useAngle = angle;
        end
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 useAngle], dep, ba);
    end
end
n1 = e.n;


angle = 90-tilt2; dep = 4e-3; minLR = 0.8;
for xx = -7.5:spacing:2.5    
    for yy = minLR:spacing:5.0 

        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba);
        
%         if yy==(minLR+spacing) || yy==(minLR+spacing*2) % for second and third, also go deep
%             e.add_probe_by_start_angles(...
%             [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
%             [90 angle], 14e-3, ba);
%         end
    end
end

fprintf('n penetrations = %d (%d and %d)\n', e.n, n1, e.n-n1);


%% plot1: by AP position
f = figure; f.Color = 'w';

uAP = unique(e.dvmlap_entry(:,3));
for a = 1:numel(uAP)
    ax = subplot(4,6,a);
    h = e.plot_probes_at_slice(ba, ax, uAP(a));
    set(h, 'LineWidth', 2.0);
    title(sprintf('%.1f', uAP(a)*1e3))
    drawnow;    
    
end

%% plot the trajectories through the brain for just a particular ap slice.

f = figure; f.Color = 'w';
uAP = unique(e.dvmlap_entry(:,3));

a = 8; 

np = 8;
these = find(e.dvmlap_entry(:,3)==uAP(a));
% np = numel(these);
for q = 1:np
    
    entry = e.dvmlap_entry(these(end-q),:)*1e3;
    tip = e.dvmlap_tip(these(end-q),:)*1e3;
    angle = atand((entry(2)-tip(2))/(entry(1)-tip(1)));
    
    % slice
    ax = subplot(5,np,q); 
    h = e.plot_probes_at_slice(ba, ax, uAP(a));
    set(h(end-q), 'LineWidth', 2.0);
    
    title(sprintf('%.1fap, %.1fml\n%d deg', entry(3), entry(2), round(angle)));
    
    % labels
    ax = subplot(5,np,([2 3 4 5]-1)*np+q);
    e.plot_brain_loc(these(end-q), ax, ba);
    drawnow;
end

%% coverage: distance to nearest probe

q = e.coverage1(ba, [-7.5 2.5]*1e-3);

%% coverage: list of areas missed

%% plot: recording locations top down
