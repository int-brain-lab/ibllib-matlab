% ba = BrainAtlas('/Users/nick/Dropbox/projects/ibl/data/allenAtlas', 'allen50');
ba = BrainAtlas('/datadisk/BrainAtlas/ATLASES/Allen', 'allen50');

ba = BrainAtlas('/datadisk/BrainAtlas/ATLASES/Allen', 'ibl50');


h = ba.show();


set(h.ax, 'NextPlot', 'add')

%ba_ = BrainAtlas('/Users/nick/Dropbox/projects/ibl/data/atlas', 'dsurqe');
ba = BrainAtlas('/datadisk/BrainAtlas/ATLASES/DSURQE_40micron', 'dsurqe');

h2 = ba_.show(h);
h2.p.FaceColor = 'green';

%%

figure; 
h = ba.show();
set(h.ax, 'NextPlot', 'add')
h2 = ba_.show(h);
h2.p.FaceColor = 'green';
