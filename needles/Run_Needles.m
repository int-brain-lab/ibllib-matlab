function h = Run_Needles

cwd = fileparts(mfilename('fullpath'));
addpath(genpath(strrep( cwd, 'needles', 'ibllib')))
addpath(genpath(cwd))

h = Needles;
