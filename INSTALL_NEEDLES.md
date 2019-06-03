# Install notes for Needles

Designed for Matlab R2016b+.
Earliers versions need to install the Json lab toolbox https://github.com/fangq/jsonlab.


## Download the 3 following files in a directory of your choice:

-	http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti/DSURQE_40micron_average.nii
-	http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti/DSURQE_40micron_labels.nii
-	http://repo.mouseimaging.ca/repo/DSURQE_40micron/DSURQE_40micron_R_mapping.csv

Needles uses the DSURQE Atlas. For more information, http://www.mouseimaging.ca/technologies/mouse_atlas/C57Bl6j_mouse_atlas.html

## Clone or download the WGs repository
-	Clone or download the WGs repository (https://github.com/int-brain-lab/needles)
-	Within the WGs/Physiology repository, edit the `./WGs/Physiology/needles_param.json` file.  
-	Set the path_atlas to the folder in which you did download the 3 files mentionned above.  
For example: 
	` "path_atlas": "/datadisk/BrainAtlas/ATLASES/DSURQE_40micron",`  
**Windows users need to "escape" backslashes this way**:  
	` "path_atlas": "C:\\path\\to\\my\\folder",`  

## Setup the Matlab Path and run

For general use without worrying about the path, run `Run_Needles.m`  file in Matlab

For advanced use with a non-frozen ibllib library, set your paths to:
-	`./WGs/Physiology/`
-	the ibllib Matlab library

## Usage
A blank window should have appeared by now.  
-	click on `File > Load`.  This will fetch and display the Atlas you did download.
-	click and remain clicked on the AP line on the axial window and move to find a coronal plane
-	click on one of the blue electrodes to jump to the corresponding coronal plane.

