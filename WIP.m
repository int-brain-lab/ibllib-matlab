ba = BrainAtlas('/datadisk/BrainAtlas/ATLASES/Allen', 'allen50');
h = ba.show();


set(h.ax, 'NextPlot', 'add')

ba_ = BrainAtlas('/datadisk/BrainAtlas/ATLASES/DSURQE_40micron', 'dsurqe');

h2 = ba_.show(h);
h2.p.FaceColor = 'green';
