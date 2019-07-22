function [E, S] = insert_electrodes(V, cs, S, lims, varargin)
% [E, S] = insert_electrodes(V, cs, S, lims)
% V: Brain Atlas Volume, struct with fields phy and lab: for example
%     phy: [241×315×478 single]
%     lab: [241×315×478 single]
% cs: CartesianVolume object for orientation in the Atlas
% lims : bounding of electrodde positions
%   struct with fields:
%     ap_lims: [-0.0078 0.0029]
%     ml_lims: [-0.0040 0.0040]
% X: ML (pitch), 2nd_dim (right to left)
% Y: AP (roll), 3d_dim 
% Z: DV (yaw), 1st_dim

p=inputParser;
p.addParameter('ax', []);
p.addParameter('csv', '');
parse(p,varargin{:});
for fn = fieldnames(p.Results)'; eval([fn{1} '= p.Results.' (fn{1}) ';']); end
% Electrodes dans le plan coronal
len_active_electrode = 3.8 *1e-3;
% len_active_electrode = 10 *1e-3;
len_electrode_tip = 0.3*1e-3; % this is in fact the distance from the bottom of the brain
len_electrode = 11*1e-3; % fixed electrode length(tip+shank)
phi = 0; % always in coronal plan
theta = 10/180*pi; % insertion is 10 degrees here
delec = 0.5*1e-3*sqrt(2); % we start with a grid of half mm
% create a mesh of electrodes, extract the z coordinate from the brain surface
E = [];
[y_, x_] = meshgrid([0:delec:cs.ly]+cs.y0, [0:delec:cs.lx]+cs.x0);
p_ = round((x_-cs.x0)/delec)*24 + 2000; % line is the coronal slice number
l_ = round((y_-cs.y0)/delec)*24 + 5000; % point is the sagital slice number
% project x_ and y_ on the brain surface
z_ = cs.i2z(interp2(S.top, cs.x2i(x_), cs.y2i(y_)));
% we keep only entry points that intersect the top surface
ind2keep = ~isnan(z_(:));
E.xyz_entry = [x_(ind2keep), y_(ind2keep), z_(ind2keep)];
E.Line = l_(ind2keep);
E.Point = p_(ind2keep);
E.phi = E.xyz_entry(:,1).*0 + phi; % always in coronal plan
E.phi = E.phi;
E.theta = E.phi.*0;
% every insertion site is used twice: 10 and 20 degrees
ne = size(E.xyz_entry,1);
E = structfun(@(x) repmat(x,2,1), E, 'UniformOutput', false);
E.theta(1:ne) = 10/180*pi; % shallow electrodes 10 degrees
E.theta(ne+1:end) = 20/180*pi;
% duplicate all program and revert theta angle
e = E;
e.theta = e.theta .* -1;
E = cat_struct(E, e);
ne = size(E.xyz_entry,1);

% Find the electrodes path using polar coordinates
r = len_electrode; % fixed electrode length (tip+sites)
E.xyz_ = probe_sph2cart(r, E.theta, E.phi, E.xyz_entry);

% get a uniform sampling of points along the electrode paths to compute exit point
nr = ceil(len_electrode*4/cs.dx); % number of sample points along the path
X_ = cs.x2i(bsxfun(@plus, (E.xyz_(:,1) - E.xyz_entry(:,1))*linspace(0,1,nr), E.xyz_entry(:,1)));
Y_ = cs.y2i(bsxfun(@plus, (E.xyz_(:,2) - E.xyz_entry(:,2))*linspace(0,1,nr), E.xyz_entry(:,2)));
Z_ = cs.z2i(bsxfun(@plus, (E.xyz_(:,3) - E.xyz_entry(:,3))*linspace(0,1,nr), E.xyz_entry(:,3)));
E.labels = interp3(V.lab, X_, Z_, Y_, 'nearest'); %extract the indices from the volume
% if all points are 0 this is a dud but this shouldn't happen as each
% electrode has a point of entry on the top surface
% assert(~any(all(E.v==0,2)))
[aa,bb] = find(diff(E.labels==0,1,2)==1);
E.length = E.phi.*0;
E.length(aa) = bb./(nr-1).*r;
E.xyz_exit = probe_sph2cart(E.length, E.theta, E.phi, E.xyz_entry);

% compute active path part of electrode only
E.xyz0 = E.xyz_entry.*0;
% for shallow electrodes entrypoint + active length
ishallow = (abs(E.theta) == 10/180*pi);
E.xyz0(ishallow,:) = E.xyz_entry(ishallow,:);
E.rec_length = min(len_active_electrode, max(0, E.length - len_electrode_tip));
E.xyz_(ishallow,:) = probe_sph2cart(E.rec_length(ishallow), E.theta(ishallow), E.phi(ishallow), E.xyz0(ishallow,:));
% for deep electrodes start from bottom - tip and up to the rec length
isdeep = (abs(E.theta) == 20/180*pi);
E.xyz_(isdeep,:) = probe_sph2cart(-len_electrode_tip, E.theta(isdeep), E.phi(isdeep), E.xyz_exit(isdeep,:));
E.rec_length(isdeep) = min(len_active_electrode, max(0, E.length(isdeep) - len_electrode_tip));
E.xyz0(isdeep,:) = probe_sph2cart(-E.rec_length(isdeep), E.theta(isdeep), E.phi(isdeep), E.xyz_(isdeep,:)); 

% 3D plot overlay
min_rec_length_mm = 2.5; % if probe insertion is smaller than than, discard
mid_line_exclusion_mm = 0.4; % get away from mid-line vascular system


% first take only the right side to have insertions towards medial plane
esel= cs.x2i(E.xyz_entry(:,1)) <= cs.nx/2;
esel = esel & E.rec_length > (min_rec_length_mm/1000); % prune according to the recording length
esel = esel & between(E.xyz_entry(:,2), lims.ap_lims); % Remove olphactory bulb
esel = esel & between(E.xyz_entry(:,1), lims.ml_lims); % REmove lateral electrodes
% remove insertions too close to the midline vascular system
esel = esel & ~between(E.xyz_entry(:,1), cs.i2x(cs.nx/2)+[-1 1].*mid_line_exclusion_mm/1000);
% save the selections in the structure
E = structfun(@(x) x(esel,:), E, 'UniformOutput', false);
E.esel = logical(E.rec_length * 0 +1);

if csv
    % save csv
    CSV_IMPLANTS = 'implantations.csv';
    T = [E.Line, E.Point, E.xyz_entry.*1e3 E.theta.*180/pi E.phi E.length.*1000 E.rec_length.*1000];
    csv_head = ['Line, Point, X_mm, Y_mm, Z_mm, Theta_deg, Phi_deg, Length_mm, Rec_length_mm' char(10)];
    T = sortrows(T(esel,:), [2 1 4]);
    fid = fopen(CSV_IMPLANTS,'w+'); fwrite(fid, csv_head); fclose(fid);
    dlmwrite('implantations.csv', T,'-append')
end

if isempty(ax), return, end

hold(ax, 'on')
% now display electrodes
col = get(ax,'colororder');
hold on, ie = E.theta==10/180*pi & esel;
pl(1) = plot3((E.xyz_entry(ie,1)), (E.xyz_entry(ie,2)), (E.xyz_entry(ie,3)), 'k*', 'parent', ax);          
pl(2) = plot3((flatten([E.xyz0(ie,1) E.xyz_(ie,1) E.xyz0(ie,1).*NaN ]')) ,...
              (flatten([E.xyz0(ie,2) E.xyz_(ie,2) E.xyz0(ie,2).*NaN ]')), ...
              (flatten([E.xyz0(ie,3) E.xyz_(ie,3) E.xyz0(ie,3).*NaN ]')), ...
               'color', col(4,:), 'parent', ax);
hold on, ie = E.theta==20/180*pi & esel;
pl(3) = plot3((flatten([E.xyz0(ie,1) E.xyz_(ie,1) E.xyz0(ie,1).*NaN ]')) ,...
              (flatten([E.xyz0(ie,2) E.xyz_(ie,2) E.xyz0(ie,2).*NaN ]')), ...
              (flatten([E.xyz0(ie,3) E.xyz_(ie,3) E.xyz0(ie,3).*NaN ]')),...
              'color', col(5,:), 'parent', ax);
set(pl,'linewidth',1)


E = ElectrodeArray(E.xyz_entry(:,[3 1 2]), E.xyz_(:, [3 1 2]),...
    'coronal_index', E.Line, 'sagittal_index', E.Point, 'index', double(E.theta * 180/pi == 10));