

classdef ElectrodeArray
    
    properties
                                
        xyz_entry % into the brain, [3xN]
        
        xyz_tip % [3,N]
        
        probe_roll % angle of rotation around the long axis of the probe
            % positive is clockwise seen from the base
        
        site_coords % 3D coordinates relative to the tip
                    % 1st dim = x = across the face of the shank
                    % 2nd dim = y = along the shank
                    % 3rd dim = z = out of plane of the shank (un-used for
                    % neuropixels)
            
    end
    
    methods
        function xyz = xyz_exit(obj) % out of the brain
            
        end
        
        function p = pitch(obj) % rotation around L-R axis. Zero horizontal; downwards is positive
            
        end
        
        function y = yaw(obj) % rotation around D-V axis. Zero is anterior; positive is CCW (i.e. left)
        
        end
        
        function r = recording_length(obj) % length of the part of the probe with active sites within the brain
            
        end
        
        function d = insertion_length(obj) % distance between the tip of the probe and the insertion point
            
        end
        
        
    end
end
