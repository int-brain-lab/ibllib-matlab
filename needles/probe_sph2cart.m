function [xyz] = probe_sph2cart(r, theta, phi, xyz0)
% [xyz] = probe_sph2cart(r, theta, phi, xyz0)

xyz = xyz0.*0;
xyz(:,1) = r.*sin(theta).*cos(phi) + xyz0(:,1);
xyz(:,2) = r.*sin(theta).*sin(phi) + xyz0(:,2);
xyz(:,3) = r.*cos(theta) + xyz0(:,3);
end

