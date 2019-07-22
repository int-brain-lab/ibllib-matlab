

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
    
    methods
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
        end
        
        function obj = add_probe_by_start_angles(obj, startCoord, angles, depth, atlas)
            % angles are [yaw pitch roll] from the P->A axis. Roll doesn't
            % determine the vector but is stored. Depth is relative to
            % surface of the brain. At atlas is required to find the
            % insertion location. Positive yaw goes to the right (CW from
            % above), positive pitch goes down (CW from the right)
            % *** for now it only works in the coronal plane, i.e. yaw is
            % not enabled
            
            % Z X Y is DV LR AP
            
            
            a = sind(angles(2)); b = cosd(angles(2));
            vec = [a b 0];
            
            spacing = 1e-6; trajX = 0:spacing:10e-3; 
            trajThroughBrain = vec'*trajX+startCoord';
            lab = labelsAlongVector(atlas, trajThroughBrain');            
            
            entryIdx = find(lab>0,1);
            lastIdx = find(lab>0,1,'last');
            spanInBrain = sum(lab>0); 
            if ~isempty(entryIdx) && (spanInBrain*spacing)>3.5e-3
                entryZYX = trajThroughBrain(:,max(1,entryIdx-1))';
                
                depthToLast = norm(trajThroughBrain(:,lastIdx)'-entryZYX);
                depth = min(depth, depthToLast);
                tipZYX = vec*depth+entryZYX;

                obj.dvmlap_entry(end+1,:) = entryZYX;
                obj.dvmlap_tip(end+1,:) = tipZYX;

                obj.n = obj.n+1; 
            end
            
        end
        
        
        function dvmlap = dvmlap_exit(obj) % out of the brain
            
        end
        
        function p = pitch(obj) % rotation around L-R axis. Zero horizontal; downwards is positive
            
        end
        
        function y = yaw(obj) % rotation around D-V axis. Zero is anterior; positive is CCW (i.e. left)
        
        end
        
        function r = recording_length(obj) % length of the part of the probe with active sites within the brain
            
        end
        
        function d = insertion_length(obj) % distance between the tip of the probe and the insertion point
            
        end
        
        function plot_brain_loc(obj, idx, ax, atlas) 
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
        
        function h = plot_probes_at_slice(obj, atlas, ax, apCoord)
            these = obj.dvmlap_entry(:,3)==apCoord;
            
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
            caxis([0 size(atlas.cmap,1)-1]); colormap(atlas.cmap);
            
            hold on;            
            axis image;
            h = [];
            for idx = 1:size(xy,1)
                %plot([xy(idx,2) tips(idx,2)], [xy(idx,1) tips(idx,1)], 'r', 'LineWidth', 2.0);
                h(idx) = plot([xyBottom(idx,2) xyTop(idx,2)], [xyBottom(idx,1) xyTop(idx,1)], 'k');
                hold on;
            end
            %xlabel('LR'); ylabel('DV');
            axis off
            set(gca, 'YDir', 'reverse');
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
        
        function to_struct(self)
            s = struct('ap_in', self.dvmlap_entry(:,3),...
                       'ml_in', self.dvmlap_entry(:,2),...
                       'dv_in', self.dvmlap_entry(:,1),...
                       'insertion_length', self.insertion_length,...
                       'pitch', self.pitch,...
                       'yaw', self.yaw,...
                       'coronal_index', self.coronal_index,...
                       'sagittal_index', self.sagittal_index,...
                       'index', self.index);
        end
        
        function to_csv(self)
        
            
        end
        
    end
    
    methods Static
        function from_csv(self)
            
        end
        
            
    end
end
