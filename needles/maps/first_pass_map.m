function e = first_pass_map(ba)
% first_pass_map(ba)
% create an ElectrodeArray and insert some probes

coords = zeros(384,3); 
coords(:,1) = repmat([43; 11; 59; 27], 384/4, 1);
coords(:,2) = reshape(repmat(20:20:3840, 2, 1), 384, 1)+200;
coords = coords.*1e-6;
e = ElectrodeArray([],[], 'site_coords', coords); 

%% version 6: switching cerebellum/medulla to right hemi
e.removeAll();

useExclusions = true;

tilt1 = 10; 
tilt2 = 15;
spacing = 0.5; % mm

angle = 90+tilt1; dep = 14e-3; minLR = 0.8;
apOffset = spacing/2; nspx = 6; nspy = 8;
% apOffset = 0; nspx = 4; nspy = 6;

exclSites = [...
    2.5 -1; ...
    2.5 minLR+spacing*0; ...
    2.5 minLR+spacing*1; ... 
    2 -1; ...
    2 minLR+spacing*0; ...
    2 minLR+spacing*1; ... 
    2 minLR+spacing*2; ... 
    1.5 minLR+spacing*1; ... 
    1.5 minLR+spacing*2; ... 
    -4 minLR+spacing*3; ...
    -4 minLR+spacing*4; ...    
    -4.5 minLR+spacing*2; ... 
%     -5 minLR+spacing*0; ...
%     -5 minLR+spacing*1; ... 
    -5.5 minLR+spacing*1; ...
    -5.5 minLR+spacing*4; ...
%     -5.5 minLR+spacing*5; ...
    -6 minLR+spacing*2; ...
    -6 minLR+spacing*5; ...
    -6.5 minLR+spacing*2; ...
    -6.5 minLR+spacing*3; ...
    -7 minLR+spacing*2; ...
    -7.5 minLR+spacing*1; ...
    ];

xPos = -5.5:spacing:2.5;
yPos = [-1.0 -0.5 minLR:spacing:4];
for xidx = 1:numel(xPos)
    xx = xPos(xidx); 
    for yidx = 1:numel(yPos)
        yy = yPos(yidx);

        if useExclusions && ismember([xx yy], exclSites, 'rows')
            continue; 
        end
        
        if yy<0
            useAngle = 90+17;
            useYY = yy;
        else
            useAngle = angle;
            useYY = yy; 
        end
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -useYY*1e-3 (xx+apOffset)*1e-3], ...
            [90 useAngle], dep, ba, xidx-16, -(yidx-2));
    end
end

exclSites = [0 0];

xPos = -7.5:spacing:-5.6;
yPos = [minLR:spacing:4];
for xidx = 1:numel(xPos)
    xx = xPos(xidx); 
    for yidx = 1:numel(yPos)
        yy = yPos(yidx);

        if useExclusions && ismember([xx yy], exclSites, 'rows')
            continue; 
        end
                
        useAngle = angle;
        useYY = yy;
        
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) useYY*1e-3 (xx+apOffset)*1e-3], ...
            [90 useAngle], dep, ba, xidx-16, -(yidx-2));
    end
end

n1 = e.n;


angle = 90-tilt2; dep = 4e-3; minLR = 0.8;

exclSites = [...
    1 minLR+spacing*5; ...
    1 minLR+spacing*6; ...
    1 minLR+spacing*7; ...
    0.5 minLR+spacing*6; ...
    0.5 minLR+spacing*7; ...
    0.5 minLR+spacing*8; ...
    0 minLR+spacing*6; ...
    0 minLR+spacing*7; ...
    0 minLR+spacing*8; ...
    -0.5 minLR+spacing*6; ...
    -0.5 minLR+spacing*7; ...
    -0.5 minLR+spacing*8; ...
    -1 minLR+spacing*7; ...
    -1 minLR+spacing*8; ...
    -1.5 minLR+spacing*7; ...
    -1.5 minLR+spacing*8; ...
    -2 minLR+spacing*7; ...
    -2 minLR+spacing*8; ...
    -2.5 minLR+spacing*7; ...
    -2.5 minLR+spacing*8; ...
    -3 minLR+spacing*7; ...
    -3 minLR+spacing*8; ...
    -3.5 minLR+spacing*7; ...
    -3.5 minLR+spacing*8; ...
    -4.5 minLR+spacing*5; ...
    -4.5 minLR+spacing*6; ...
    -4.5 minLR+spacing*7; ...
    -5 minLR+spacing*6; ...    
    -5.5 minLR+spacing*6; ...    
    ];
xPos = -5.5:spacing:3;
yPos = minLR:spacing:5.0;
for xidx = 1:numel(xPos)
    xx = xPos(xidx); 
    for yidx = 1:numel(yPos)
        yy = yPos(yidx);

        if useExclusions && ismember([xx yy], exclSites, 'rows')
            continue; 
        end
        
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) -yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba, xidx-16, -yidx);        
    end
end

exclSites = [0 0];
xPos = -7.5:spacing:-5.6;
yPos = 0.3:spacing:5.0;
for xidx = 1:numel(xPos)
    xx = xPos(xidx); 
    for yidx = 1:numel(yPos)
        yy = yPos(yidx);

        if useExclusions && ismember([xx yy], exclSites, 'rows')
            continue; 
        end
        
        e.add_probe_by_start_angles(...
            [dvTopForAPslice(ba, xx*1e-3) yy*1e-3 xx*1e-3], ...
            [90 angle], dep, ba, xidx-16, -yidx);        
    end
end

fprintf('n penetrations = %d (%d and %d)\n', e.n, n1, e.n-n1);

nPerMouse = 10; 
% N = (e.n-3)*2 + 3*5 + (M*2/3-5)
% M = N/nPerMouse
% so - 
% N - N/nPerMouse*2/3 = 2*e.n + 4
N = (2*e.n + 4) / (1-2/nPerMouse/3);
M = N/nPerMouse; 

fprintf(1, 'total N = %d, M = %d (at %d pens per mouse)\n', round(N), round(M), nPerMouse);

% recompute unique indices
e.sagittal_index = round((e.dvmlap_entry(:,2) ./ ba.brain_coor.dx) * 2 + 5000);
e.coronal_index = round((e.dvmlap_entry(:,3) ./ ba.brain_coor.dy) * 2 + 2000);
% if this fails, use index above
assert(length(unique([e.sagittal_index, e.coronal_index], 'rows')) == e.n)
% move everything to left side
e.dvmlap_entry(:,2) = - e.dvmlap_entry(:,2);
e.dvmlap_tip(:,2) = - e.dvmlap_tip(:,2);


% export to csv
[p, f] = fileparts(which(mfilename));
e.to_csv([p, filesep, f, '.csv'])
