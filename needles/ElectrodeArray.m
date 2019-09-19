classdef ElectrodeArray < handle
    
    properties
        n % number of probes
        dvmlap_entry % into the brain [self.n,3], meters
        
        dvmlap_tip% [self.n,3], meters
        
        probe_roll % angle of rotation around the long axis of the probe
        % positive is clockwise seen from the base. Scalar or vector [self.n, 3]
        
        site_coords
        % [nsites,3] 3D coordinates relative to the tip
        % 1st dim = x = across the face of the shank
        % 2nd dim = y = along the shank
        % 3rd dim = z = out of plane of the shank (un-used for neuropixels)
        
        coronal_index  % line number in a grid, corresponds to a coronal slice
        sagittal_index  % point number in a grid, corresponds to a sagittal slice
        index % arbitrary identifier to group probes if necessary. Used to colour probes plots in Needles.
        
    end
    
    methods (Access = private)
        function dvmlap = dvmlap_alongprobe(E, dx)
            % computes the dv ml ap coordinates along the probe from tip.
            % maxes out at exit point
            dtip = E.dvmlap_entry - E.dvmlap_tip;
            [t, p, r] = cart2sph(dtip(:,1), dtip(:,2), dtip(:,3));
            [dv, ml, ap] = sph2cart(t, p, min(dx, r));
            dvmlap = [dv ml ap] + E.dvmlap_tip;
        end
    end
    
    methods
        %% Constructor and adding probes methods
        function self = ElectrodeArray(dvmlap_entry, dvmlap_tip, varargin)
            % ea = ElectrodeArray(dvmlap_entry, dvmlap_tip, 'probe_roll', pr, 'site_coords', sxyz)
            % parse input arguments
            self.n = size(dvmlap_entry, 1);
            self.dvmlap_entry = dvmlap_entry;
            self.dvmlap_tip = dvmlap_tip;
            assert(size(dvmlap_tip, 1) == self.n)
            p = inputParser;
            addOptional(p,'probe_roll',  zeros(self.n, 1), @isnumeric);
            % by default we assume just 2 sites to have a recording length 3.5mm from the tip
            addOptional(p,'site_coords', [0, 3.5*1e-3, 0 ; 0 0 0 ] , @isnumeric);
            % line/points/index identifiers to reference probes easily if necessary
            addOptional(p,'coronal_index', zeros(self.n, 1).*NaN, @isnumeric); % line number refers to a coronal slice
            addOptional(p,'sagittal_index', zeros(self.n, 1).*NaN , @isnumeric); % point number refers to a sagittal slice
            addOptional(p,'index', zeros(self.n, 1).*NaN , @isnumeric); % arbitrary group ID, used for colouring in Needles for example
            parse(p, varargin{:});
            for fn = fieldnames(p.Results)', eval(['self.' fn{1} '= p.Results.' (fn{1}) ';']); end
        end
        
        function removeAll(obj)
            obj.n = 0;
            obj.dvmlap_entry = [];
            obj.dvmlap_tip = [];
            obj.probe_roll = [];
            obj.coronal_index = [];
            obj.sagittal_index = [];
            obj.index = [];
        end
        
        function obj = add_probe_by_start_angles(obj, startCoord, angles, depth, atlas, corIdx, sagIdx)
            % angles are [yaw pitch roll] from the P->A axis. Roll doesn't
            % determine the vector but is stored. Depth is relative to
            % surface of the brain. At atlas is required to find the
            % insertion location. Positive yaw goes to the right (CW from
            % above), positive pitch goes down (CW from the right)
            % *** for now it only works in the coronal plane, i.e. yaw is
            % not enabled
            
            % Z X Y is DV LR AP
            ELEC_LEN = 3.5e-3;
            a = sind(angles(2)); b = cosd(angles(2));
            vec = [a b 0];
            
            spacing = 1e-6; trajX = 0:spacing:10e-3;
            trajThroughBrain = vec'*trajX+startCoord';
            lab = labelsAlongVector(atlas, trajThroughBrain');
            
            entryIdx = find(lab>0,1);
            lastIdx = find(lab>0,1,'last');
            spanInBrain = sum(lab>0);
            if ~isempty(entryIdx) && (spanInBrain*spacing) > ELEC_LEN
                entryZYX = trajThroughBrain(:,max(1,entryIdx-1))';
                
                depthToLast = norm(trajThroughBrain(:,lastIdx)'-entryZYX);
                depth = min(depth, depthToLast);
                tipZYX = vec*depth+entryZYX;
                
                obj.dvmlap_entry(end+1,:) = entryZYX;
                obj.dvmlap_tip(end+1,:) = tipZYX;
                
                obj.coronal_index(end+1,:) = corIdx;
                obj.sagittal_index(end+1,:) = sagIdx;
                obj.index(end+1,:) = double(angles(2)>90);
                obj.n = obj.n+1;
            end
            
        end
        
        %% Geometry and computation methods
        function dvmlap = sites_dvmlap(E, ind)
            dvmlap = zeros(size(E.site_coords(:,2), 1), 3);
            for m = 1: size(dvmlap, 1)
                a = dvmlap_alongprobe(E, E.site_coords(m,2));
                dvmlap(m, :) = a(ind, :);
            end
            
        end
        
        function dvmlap = site_lowest(E, ind)
            low_end = min(E.site_coords(:,2));
            dvmlap = dvmlap_alongprobe(E, low_end);
            if nargin > 1, dvmlap = dvmlap(ind, :); end
        end
        
        function dvmlap = site_highest(E, ind)
            high_end = max(E.site_coords(:,2));
            dvmlap = dvmlap_alongprobe(E, high_end);
            if nargin > 1, dvmlap = dvmlap(ind, :); end
        end
        
        function [r, theta, phi] = cart2sph_(obj, ind)
            % from dvmlap_entry and dvmlap_tip, returns az, el, r
            if nargin < 2, ind = 1:obj.n; end
            d =  obj.dvmlap_tip(ind,:) -  obj.dvmlap_entry(ind,:);
            [r, theta, phi] = obj.cart2sph_d(d);
        end
        
        function phi = phi(obj, ind)
            % angle from right in horizontal plane, clockwise, [-180 180] in degrees
            if nargin < 2, ind = 1:obj.n; end
            [~, ~, phi] = cart2sph_(obj, ind);
        end
        
        function theta = theta(obj, ind)
            % polar angle (from vertical) [0 - 180] in degrees
            if nargin < 2, ind = 1:obj.n; end
            [~, theta] = cart2sph_(obj, ind);
        end
        
        function r = recording_length(obj, ind) % length of the part of the probe with active sites within the brain
        end
        
        function r = depth(varargin)
            r = insertion_length(varargin{:});
        end
        
        function r = insertion_length(obj, ind) % distance between the tip of the probe and the insertion point
            if nargin < 2, ind = 1:obj.n; end
            r = cart2sph_(obj, ind);
        end
        
        %% Export / Display and Plotting methods
        function [fig_elec, tab_elec]= show_table(obj)
            s = obj.to_struct;
            fig_elec  = findobj('type', 'figure', 'tag', 'fig_electrode_table');
            if isempty(fig_elec)
                fig_elec = figure('color', 'w', 'toolbar', 'none', 'menubar', 'none', 'numbertitle',...
                    'off', 'name', 'Electrode List', 'tag', 'fig_electrode_table');
            end
            tab_elec = uitable(fig_elec, 'Units', 'normalized', 'Position', [0 0 1 1]);
            tab_elec.Data = table2array(struct2table(s));
            tab_elec.ColumnName = fields(s);
        end
        
        function plot_brain_loc(obj, idx, ax, atlas)
            % e.plot_brain_loc(obj, idx, ax, atlas)
            % idx is the electrode for which the plot should be made
            % ax is the axis into which to plot
            
            tip = obj.dvmlap_tip(idx,:);
            entry = obj.dvmlap_entry(idx,:);
            
            recordArrayTop = max(obj.site_coords(:,2));
            recordArrayBottom = min(obj.site_coords(:,2));
            
            vectorDir = (entry-tip);
            vectorDir = vectorDir./norm(vectorDir);
            
            vectorEnd = tip+vectorDir*recordArrayBottom;
            vectorStart = tip+vectorDir*recordArrayTop;
            plotTrajectory(ax, atlas, vectorStart, vectorEnd);
            
        end
        
        function h = plot_probes_at_slice(obj, atlas, ax, apCoord, ie)
            %             h = plot_probes_at_slice(obj, atlas, ax, apCoord, ie)
            
            if nargin <= 4, ie = []; end
            
            these = obj.dvmlap_entry(:,3)==apCoord;
            [~, ie] = intersect(find(these), ie);
            
            
            xy = obj.dvmlap_entry(these,1:2);
            tips = obj.dvmlap_tip(these,1:2);
            
            recBottom = min(obj.site_coords(:,2)); recTop = max(obj.site_coords(:,2));
            xyBottom = zeros(size(xy)); xyTop = zeros(size(xy));
            for q = 1:size(xy,1)
                vecDir = xy(q,:)-tips(q,:);
                vecDir = vecDir./norm(vecDir);
                xyBottom(q,:) = vecDir*recBottom+tips(q,:);
                xyTop(q,:) = vecDir*recTop+tips(q,:);
            end
            
            sliceIdx = round(atlas.brain_coor.y2i(apCoord));
            
            zs = atlas.brain_coor.zscale; xs = atlas.brain_coor.xscale;
            
            %     imagesc(xs,zs,ba.vol_image(:,:,sliceIdx)); caxis([0 10000]); colormap gray;
            imagesc(xs,zs,atlas.vol_labels(:,:,sliceIdx), 'Parent', ax);
            caxis(ax, [0 size(atlas.cmap,1)-1]); colormap(get(ax, 'Parent'), atlas.cmap);
            
            set(ax, 'NextPlot', 'add');
            axis(ax, 'image');
            h = [];
            for idx = 1:size(xy,1)
                %plot([xy(idx,2) tips(idx,2)], [xy(idx,1) tips(idx,1)], 'r', 'LineWidth', 2.0);
                h(idx) = plot(ax, [xyBottom(idx,2) xyTop(idx,2)], [xyBottom(idx,1) xyTop(idx,1)], 'k');
                if ie == idx
                    set(h(idx), 'LineWidth', 2, 'Color', 'r')
                end
            end
            %xlabel('LR'); ylabel('DV');
            %             axis(ax, 'off')
            set(ax, 'YDir', 'reverse');
        end
        
        function c = coverage1(obj, atlas, apLims)
            % Compute the distance between each voxel of the atlas and the
            % nearest probe
            
            % find voxels with brain, in the left hemisphere
            v = atlas.vol_labels;
            v = v(:,1:round(size(v,2)/2),:); % assuming volume is symmetric on zero
            apLims = atlas.brain_coor.z2i(apLims);
            v(:,:,(1:size(v,3))<apLims(1)) = 0;
            v(:,:,(1:size(v,3))>apLims(2)) = 0;
            
            [vx, vy, vz] = ind2sub(size(v), find(v>0));
            vx = atlas.brain_coor.i2x(vx);
            vy = atlas.brain_coor.i2x(vy);
            vz = atlas.brain_coor.i2x(vz);
            
            % get vectors
            xy = obj.dvmlap_entry;
            tips = obj.dvmlap_tip;
            
            recBottom = min(obj.site_coords(:,2)); recTop = max(obj.site_coords(:,2));
            xyBottom = zeros(size(xy)); xyTop = zeros(size(xy));
            for q = 1:size(xy,1)
                vecDir = xy(q,:)-tips(q,:);
                vecDir = vecDir./norm(vecDir);
                xyBottom(q,:) = vecDir*recBottom+tips(q,:);
                xyTop(q,:) = vecDir*recTop+tips(q,:);
            end
            
            % compute distances to nearest vectors
            a = xyTop - xyBottom;
            na = (sum(a.^2,2)).^(0.5);
            for q = 1:numel(vx)
                b = [vx(q) vy(q) vz(q)] - xyBottom;
                
                cab = cross(a, b, 2);
                
                d = ((sum(cab.^2,2)).^(0.5))./na;
                
                minD(q) = min(d);
            end
            
            % take average
            c = mean(minD);
            
        end
        
        function s = to_struct(self)
            % work in progress
            s = struct('coronal_index', self.coronal_index,...
                'sagittal_index', self.sagittal_index,...
                'index', self.index,...
                'ap_um', round(self.dvmlap_entry(:,3)*1e6),... % units mm, this rounding gets 2 decimal places in the output
                'ml_um', round(self.dvmlap_entry(:,2)*1e6),...
                'dv_um', -round(self.dvmlap_entry(:,1)*1e6),...
                'depth_um', round(self.depth*1e6),...
                'theta', round(self.theta*10)/10,...
                'phi', round(self.phi*10)/10);
        end
        
        function to_csv(self, output_file)
            if nargin < 2, output_file = [pwd filesep 'electrode_array.csv']; end
            writetable(struct2table(self.to_struct), output_file);
        end
        
    end
    
    methods(Static)
        function [r, theta, phi] = cart2sph_d(d)
            % d is the diff tip-entry (ref to entry point)
            [phi, theta, r] = cart2sph(-d(:,2), d(:,3), d(:,1));
            theta = mod(90 - theta .* 180 / pi, 180);
            phi = phi.* 180 / pi;
        end
    end
end



