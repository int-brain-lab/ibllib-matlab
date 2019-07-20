

classdef ElectrodeArray
    
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
            
        coronal_index  % line number in a grid
        sagittal_index  % point number in a grid
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
            parse(p, varargin{:});
            for fn = fieldnames(p.Results)', eval(['self.' fn{1} '= p.Results.' (fn{1}) ';']); end
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
        
        function plot_brain_locs(obj, ide, ax) 
            % idx is the electrode for which the plot should be made
            % ax is the axis into which to plot
            
        end
        
        function to_csv()
        end
        
        function from_csv()
            
        end
        
            
    end
end
