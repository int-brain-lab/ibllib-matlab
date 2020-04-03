# Install notes for Needles

Designed for Matlab R2016b+.
Earliers versions need to install the Json lab toolbox https://github.com/fangq/jsonlab.


## Download the atlas files into a directory of your choice:

### For Allen CCF Atlas at 50 µm resolution (IBL's default)
You will need the average_template and the annotation volume.
For IBL, files are in google drive / WG-Physiology/Resources/Brain Atlases/Allen50:
- 	http://ibl.flatironinstitute.org/histology/ATLAS/Needles/Allen/
Download file average_template_25.nrrd (can chose 10 or 50 depending on wanted resolution)

Files are also publicly available from the Allen Brain Institute servers:
-   http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/


### For the "DSURQE" MRI atlas (used previously, and used for calibration)
-	http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti/DSURQE_40micron_average.nii
-	http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti/DSURQE_40micron_labels.nii
-	http://repo.mouseimaging.ca/repo/DSURQE_40micron/DSURQE_40micron_R_mapping.csv

For more information, http://www.mouseimaging.ca/technologies/mouse_atlas/C57Bl6j_mouse_atlas.html

## Clone or download the WGs repository
-	Clone or download the WGs repository (https://github.com/int-brain-lab/ibllib-matlab)
-	Within the WGs/Physiology repository, edit the `./ibllib-matlab-master/needles/needles_param.json` file.  
-	Set the path_atlas to the folder in which you did download the 3 files mentionned above.  
For example: 
	` "path_atlas": "/datadisk/BrainAtlas/ATLASES/",`  
**Windows users need to "escape" backslashes this way**:  
	` "path_atlas": "C:\\path\\to\\my\\folder",`  

## Setup the Matlab Path and run

For general use without worrying about the path, run `Run_Needles.m`  file in Matlab

For advanced use with a non-frozen ibllib library, set your paths to:
-	`./ibllib-matlab-master/needles/`
-	the ibllib Matlab library

## Usage
A blank window should have appeared by now.  
-	click on `File > Load`.  This will fetch and display the Atlas you did download. The "IBL50" atlas is the main one to use.
-	click and remain clicked on the AP line on the axial window and move to find a coronal plane
-	click on one of the white dots to jump to the corresponding coronal plane.

