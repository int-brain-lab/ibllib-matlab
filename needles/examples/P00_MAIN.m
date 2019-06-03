% Depends on IBLLIB
cd /home/olivier/Documents/MATLAB/WGs/Physiology
close all


atlas_path = '/datadisk/BrainAtlas/ATLASES/DSURQE_40micron/';

%[V, h, cs] = brainatlas.get_allen(100);
%  [V, h, cs] = brainatlas.get_allen(50);
% [V, h, cs, labels] = brainatlas.get_whs12;
lims.ap_lims = [-.009205 .004288]; % Antero Posterior selection (to remove OB and spine) WAXHOLM
[V, h, cs, labels] = brainatlas.get_dsurqe;
lims = struct('ap_lims', [-0.005177 0.005503], 'ml_lims', [-0.004 0.004]); % for COG vertex, need to update once Bregma is chosen

% X: ML (pitch), 2nd_dim (left - right +)
% Y: AP (roll), 3d_dim +-
% Z: DV (yaw), 1st_dim -+
% VOL(Z, X, Y)


P01_make_all_electrodes;
P02_prune_electrodes;
% P03_make_sections;

% 
% 
% set(h_.fig_volume, 'Position', [647         123        1080         773])
% view(h_.ax, -116.9542, 41.6299);
% axis(h_.ax, [-0.006 0.006 -0.012 0.008 -0.006 0.004])
%%
hold on,
try delete(pl); end
ex = @(xy) xy + diff(xy)/100 .*[-1 1];
pl(1) = plot3([0, 0], ex(cs.ylim), [0, 0], 'y', 'linewidth', 2  );
pl(2) = plot3([0, 0] , [0, 0], ex(cs.zlim), 'y', 'linewidth', 2  );
pl(3) = plot3(ex(cs.xlim), [0, 0] , [0, 0], 'y', 'linewidth', 2  );
h.p.FaceAlpha = 0.5
%% add the zero slices for better localization
figure,
slice(cs.xscale, cs.yscale,cs.zscale,permute(single(V.phy), [3 2 1]),0,0,0)
shading interp
set(gca, 'DataAspectRatio',[1 1 1],'zdir','reverse');
xlabel('x'), ylabel('y'), zlabel('z')

colorbar
colormap bone
