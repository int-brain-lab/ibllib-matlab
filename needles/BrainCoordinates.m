classdef BrainCoordinates
    % X refers to ML
    % Y refers to AP
    % Z refers to DV
    properties
        % coordinates of the element V(1,1,1) in the coordinate space
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
        function self = BrainCoordinates(V, varargin)
            % dzxy, zxy0
            p = inputParser;
            p.addParameter('dzxy',  1, @isnumeric);
            p.addParameter('zxy0',  0, @isnumeric);
            % by default we assume just 2 sites to have a recording length 3.5mm from the tip
            p.parse(varargin{:});
            for fn = fieldnames(p.Results)', eval([fn{1} '= p.Results.' (fn{1}) ';']); end
            % V has dimensions [Nz, Nx, Ny] = [DV, ML, AP]
            % dxyz is a 3 elements vector of spatial resoltion
            % zxy0 is a 3 elements vector defining the coordinates of V[1,1,1] in real space
            [self.nz, self.nx, self.ny] = size(V);            
            if length(dzxy)==1, dzxy = dzxy.*[1 1 1]; end
            self.dx = dzxy(2);
            self.dy = dzxy(3);
            self.dz = dzxy(1);
            if length(zxy0)==1, zxy0 = zxy0.*[1 1 1]; end
            self.x0 = zxy0(2); %- self.dx;
            self.y0 = zxy0(3); %- self.dy;
            self.z0 = zxy0(1); %- self.dz;
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
        
        
        function zxy = iii2zxy(self, iii)
            zxy = [self.i2z(iii(:,1)), self.i2x(iii(:,2)), self.i2y(iii(:,3))];
        end
        
        function zxy = zxy2iii(self, iii)
            zxy = [self.z2i(iii(:,1)), self.x2i(iii(:,2)), self.y2i(iii(:,3))];
        end
        
        function o = iorigin(self)
        % returns the 3 element array of origin 
            o = self.zxy2iii([0,0,0]);
        end
    end
end