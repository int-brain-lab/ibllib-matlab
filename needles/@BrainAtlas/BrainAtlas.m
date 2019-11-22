classdef BrainAtlas
    % obj = BrainAtlas(atlas_path, atlas_label)
    % The volume arrays dimension correspond to [DV, ML, AP]
    
    properties
        vol_labels   % labels volume of the brain
        vol_image  % imaging volume of the brain
        brain_coor  % BrainCoordinate object
        surf_top  % top surface of the brain
        surf_bottom  % bottom surface of the brain
        labels % structure with fields 'name' and 'index' where index is a direct mapping of the labels in vol_labels
        cmap % colormap for vol_labels. set caxis([0 size(cmap,1)-1]). 
    end
    
    methods
        function obj = BrainAtlas(atlas_path, atlas_label)
            %BRAINATLAS Construct an instance of this class
            %   atlas_path: full path containing files to build the atlas
            %   available atlases: allen50
            switch atlas_label
                case 'ibl50'
                    [obj.vol_labels, obj.vol_image, obj.brain_coor, obj.labels, obj.cmap] = obj.get_ibl(atlas_path, 50);
                case 'ibl25'
                    [obj.vol_labels, obj.vol_image, obj.brain_coor, obj.labels, obj.cmap] = obj.get_ibl(atlas_path, 25);
                case 'ibl10'
                    [obj.vol_labels, obj.vol_image, obj.brain_coor, obj.labels, obj.cmap] = obj.get_ibl(atlas_path, 10); 
                case 'allen50'
                    [obj.vol_labels, obj.vol_image, obj.brain_coor, obj.labels, obj.cmap] = obj.get_allen(atlas_path, 25);
                case 'allen25'
                    [obj.vol_labels, obj.vol_image, obj.brain_coor, obj.labels, obj.cmap] = obj.get_allen(atlas_path, 50);
                case 'allen10'
                    [obj.vol_labels, obj.vol_image, obj.brain_coor, obj.labels, obj.cmap] = obj.get_allen(atlas_path, 10);
                case 'dsurqe'
                    [obj.vol_labels, obj.vol_image, obj.brain_coor, obj.labels] = obj.get_dsurqe(atlas_path);
                otherwise
                    error('Possible atlases are: "allen50", "dsurqe"')
            end
                
            % get the top and bottom surfaces of the brain using the labels volume
            [obj.surf_top, obj.surf_bottom] = deal(zeros(obj.brain_coor.ny, obj.brain_coor.nx));
            for s = 1 : obj.brain_coor.ny
                [i1,i2] = find(diff(obj.vol_labels(:,:,s) == 0,1,1));
                obj.surf_top(s,:) = accumarray(i2, i1, [obj.brain_coor.nx 1], @min, NaN);
                obj.surf_bottom(s,:) = accumarray(i2, i1, [obj.brain_coor.nx 1], @max, NaN);
            end
        end
        
        function dvStart = dvTopForAPslice(obj, apCoord)
            % the dv position of the surface of the brain for some AP
            % position
            thisSliceIdx = round(obj.brain_coor.y2i(apCoord));
            thisSlice = obj.vol_labels(:,:,thisSliceIdx);
            q = max(thisSlice,[],2);
            dvStartIdx = find(q>0,1);
            dvStart = obj.brain_coor.i2z(dvStartIdx);
        end
    end
    
    methods
       h = show(obj, h) 
    end
    
    methods (Static)
        [vlab vim, bc, labels, cmap] = get_ibl(atlas_path, res_nm, varargin)
        [vlab vim, bc, labels, cmap] = get_allen(atlas_path, res_nm, varargin)
        [vlab vim, bc, labels] = get_dsurqe(atlas_path, res_nm)
    end
    
end

