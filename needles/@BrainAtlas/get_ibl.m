function [vol_labels, vol_image, bc, labels, cmap] = get_ibl(varargin)

DV_SCALE = 0.952; % multiplicative factor on DV dimension, determined from MRI->CCF transform by M. Faulkner
AP_SCALE = 1.087; % multiplicative factor on AP dimension
[vol_labels, vol_image, bc, labels, cmap] = BrainAtlas.get_allen(varargin{:}, 'DV_SCALE', DV_SCALE, 'AP_SCALE', AP_SCALE);
