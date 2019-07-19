classdef BrainCoordinates
    % X refers to ML
    % Y refers to AP
    % Z refers to DV
    properties
        % reference point (0,0,0) in the coordinate space
        z0 = 0
        x0 = 0
        y0 = 0
        % sampling interval in each direction
        dz = 1
        dx = 1
        dy = 1
        % number of elements for each position
        nz
        nx
        ny
    end
    
    methods
        % Constructor
        function self = BrainCoordinates(V, dzyx, zxy0)
            % V has dimensions [Nz, Nx, Ny] = [DV, ML, AP]
            % dxyz is a 3 elements vector of spatial resoltion
            % zxy0 is a 3 elements vector defining the coordinates of V[1,1,1] in real space
            [self.nz, self.nx, self.ny] = size(V);
            if nargin >=3
                if length(zxy0)==1, zxy0 = zxy0.*[1 1 1]; end
                self.x0 = zxy0(1);
                self.y0 = zxy0(2);
                self.z0 = zxy0(3);
            end
            if nargin >=2
                if length(dzyx)==1, dzyx = dzyx.*[1 1 1]; end
                self.dx = dzyx(1);
                self.dy = dzyx(2);
                self.dz = dzyx(3);
            end
        end
        
        % Methods distance to indice
        function ind = x2i(self,x)
            ind = (x - self.x0)./self.dx + 1;
        end
        function ind = y2i(self,y)
            ind = (y - self.y0)./self.dy + 1;
        end
        function ind = z2i(self,z)
            ind = (z - self.z0)./self.dz + 1;
        end
        
        % indices to distance
        function x = i2x(self, ind)
            x = (ind-1).* self.dx + self.x0;
        end
        function y = i2y(self, ind)
            y = (ind-1).* self.dy + self.y0;
        end
        function z = i2z(self, ind)
            z = (ind-1).* self.dz + self.z0;
        end
        
        % relative position (ratio) to indices
        function ind = rx2i(self, r)
            ind = r.*(self.nx-1) +1;
        end
        function ind = ry2i(self, r)
            ind = r.*(self.ny-1) +1;
        end
        function ind = rz2i(self, r)
            ind = r.*(self.nz-1) +1;
        end
        
        % relative position (ratio) to distance
        function x = rx2x(self, r)
            x = self.i2x(self.rx2i(r));
        end
        function y = ry2y(self, r)
            y = self.i2y(self.ry2i(r));
        end
        function z = rz2z(self, r)
            z = self.i2z(self.rz2i(r));
        end
        
        % Methods length
        function lx = lx(self)
            lx = self.nx.*self.dx; 
        end
        function ly = ly(self)
            ly = self.ny.*self.dy; 
        end
        function lz = lz(self)
            lz = self.nz.*self.dz; 
        end

        % limits for axis
        function xl = xlim(self)
            xl = self.i2x([0 self.nx]);
        end
        function yl = ylim(self)
            yl = self.i2y([0 self.ny]);
        end
        function zl = zlim(self)
            zl = self.i2z([0 self.nz]);
        end
        
        % full scales for plots
        function xs = xscale(self)
           xs = self.i2x([1:self.nx]');
        end
        function ys = yscale(self)
            ys = self.i2y([1:self.ny]');
        end
        function zs = zscale(self)
            zs = self.i2z([1:self.nz]');
        end
        
        
        function r = res(self)
        % return the 3 element array for resolution
           r = [self.dz, self.dx, self.dy]; 
        end
        
         
        function o = origin(self)
        % returns the 3 element array of origin 
            o = [self.z0, self.x0, self.y0];
        end
    end
end