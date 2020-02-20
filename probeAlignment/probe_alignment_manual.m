%This code determines whether probe shanks are aligned with their holder,
%given pictures of probes at different depths and rotation angles

%Input args:
% depthSecondPic: depth of the probe at the second picture, in mm
% rotationOfProbe: rotation of the probe, in degrees (Good to test the alignment both at 0 and 90 degrees)
% holderName: string description of your probe holder and/or initials (e.g. dovetailNR)
% flip_flag: optional arg, set to 1 if your camera happened to be upside
% down (oops!). Default is 0.

%Requirements:
% 2 pictures of the probe in its holder (one at depth 0, another at some
% deeper depth) taken with the camera at the same location.

% Notation:
%  Images must be named via the following format:
%  holderName_Xdepth_Yrotation.fileformat (any format that matlab can read should work)


function probe_alignment(depthSecondPic,rotationOfProbe,holderName,flip_flag)

addpath probe_pics
close all

depth0=0; %first picture at this depth (mm)
depth1=depthSecondPic; %second picture at this depth (mm)
rotation=rotationOfProbe; %rotation of the probe (to check alignment in two different perspectives, options are 0 or 90)
threshold=9; %threshold required to find (crude) edges of image

[I]=defineProbe(depth0,rotation,holderName,flip_flag);
location=0; %find probe base
[x0cor0,y0cor0]=findLocationOnProbe(I,location); %first probe pic, base
base0=[x0cor0,y0cor0];
location=1; %find probe tip
[x0cor1,y0cor1]=findLocationOnProbe(I,location); %first probe pic, tip
tip0=[x0cor1,y0cor1];


[I]=defineProbe(depth1,rotation,holderName,flip_flag);
location=0; %find probe base
[x1cor0,y1cor0]=findLocationOnProbe(I,location); %second probe pic, base
base1=[x1cor0,y1cor0];
location=1; %find probe tip
[x1cor1,y1cor1]=findLocationOnProbe(I,location); %second probe pic, tip
tip1=[x1cor1,y1cor1];


%Sanity check plot
plotflag=0; %don't need this plot unless checking how good your manual selection was in detail.
if(plotflag)
    figure;
    plot([tip0(1) base0(1)],[tip0(2) base0(2)],'b');hold on; plot([tip1(1) base1(1)],[tip1(2) base1(2)],'k');
    axis equal
end

%Check that the slopes of the probes are parallel. This should be the case
%regardless of any mis-alignment (if not, this means your manual selection
%of base/tip were not precise enough. The code will throw an error and ask
%you to retry!)

% Compute slopes of the probes
slope0=abs((base0(2)-tip0(2))/(base0(1)-tip0(1)));
slope1=abs((base1(2)-tip1(2))/(base1(1)-tip1(1)));
% Compute angle between the two probes
thetaDSlopes=abs(atan(slope1)-atan(slope0))*180/pi; %difference between these (deg)
thetaRSlopes = abs(atan(slope1)-atan(slope0)); %difference between these (rad)

if thetaDSlopes>1
    error('Your probes are not parallel (off by %2.2f degrees). Please redo manual registration. \n \n', thetaDSlopes)
else
    fprintf('Sanity check: the slopes of the probes based on your base/tip selections are only  off by an angle of %2.2f degrees \n \n',thetaDSlopes)
    if(plotflag)
        title(['Sanity check: the slopes of the probes  based on your base/tip selections are only off by %2.2 degrees' , num2str(thetaDSlopes)])
    end
end


% Compute alignment of probe and holder:
%Step 1: How far is the tip at depth 0 (original tip) to the probe at depth X?
[distP]=shortestDistanceToProbe(tip0,base1,tip1);

%Step 2: How far is the tip at depth 0 to the tip at depth X?
[distT]=distanceTipToTip(tip0,tip1);

%Step 3: What is the angle of discrpancy?
thetaD=asin(distP/distT)*180/pi;%in degrees
thetaR = asin(distP/distT); %in radians
fprintf('The probe is  %2.2f degrees off from "aligned" \n \n',thetaD)

%Convert pixels in image to depth in mm. This is not necessary for the
%below computation, but you can use it to convert distP and distT, if you
%want.
depth1InPix=sqrt(distT^2-distP^2); % also equivalent to distP/tan(thetaR);
pixPerMm=depth1InPix/depth1;

%Step 4: How much of a discrepancy does this misalignment cause?
distBrain = tan(thetaR)*1000; %in microns
fprintf('This angle would cause %4.2f microns of discrepancy in the brain for every 1 mm of driving distance \n',distBrain)
end

function [BWs] =defineProbe(depth,rotation, holderName,flip_flag);

picname = [holderName '_' num2str(depth) 'depth_' num2str(rotation) 'rotation'];
%picname = [num2str(depth) 'depth_' num2str(rotation) 'rotation'];
addpath("probe_pics")
filename =dir(['probe_pics/' picname '*.jpg']);
I=imread(filename.name);

if ~exist('flip_flag','var')
    flip_flag = 0;
end
if(flip_flag) %flips image if camera was upside down
    I=flip(I);
end

I = rgb2gray(I);
[x,imthresh] = edge(I,'sobel');
fudgeFactor = 1;
BWs = edge(I,'sobel',imthresh * fudgeFactor);
imshow(BWs,'Colormap',flipud(gray))
end


function [xcor,ycor]=findLocationOnProbe(BWs,location);
imshow(BWs,'Colormap',flipud(gray))
if(location==1)
    title('Zoom image to see TIP clearly. Press any button. Click the TIP of the probe')
    location_text='TIP of the ';
elseif(location==0)
    title('Zoom image to see BASE clearly. Press any button. Click the BASE of the probe')
    location_text='BASE of the ';
    
end

button=1;
while (button)<=1
    zoom on;
    fprintf(['Zoom into the image until you can see the ' location_text 'probe well, then press any key \n \n'])
    
    pause() % you can zoom with your mouse and when your image is okay, you press any key
    zoom off; % to escape the zoom mode
    fprintf(['Click on the ' location_text 'probe \n \n'])
    
    [x,y,button]=ginput(1);
    button=button+1;
    zoom out; % go to the original size of your image
    
end
ycor=y;
xcor=x;
end

function [distP]=shortestDistanceToProbe(input,base,tip);
%computes the shortest distance from a point (input) to a probe (defined by
%base and tip)
basex = base(1);
basey=base(2);
tipx=tip(1);
tipy=tip(2);
if(basex<tipx)
    Xsamples = [basex:tipx];
    Yinterpolated = linterp([basex tipx], [basey tipy],Xsamples);
else
    Xsamples=[tipx:basex];
    Yinterpolated = linterp([ tipx basex], [tipy basey],Xsamples);    
end
xIn=input(1);
yIn=input(2);

[distP,i]=min(sqrt((xIn-Xsamples).^2+(yIn-Yinterpolated).^2)); %perpendicular distance, smallest distance to somewhere along the deep probe shank
end

function [distT]=distanceTipToTip(tip0, tip1);
%computes distance between two pixels (specifically, the tips of probes at two depths)
x0=tip0(1);
y0=tip0(2);
x1 = tip1(1);
y1 = tip1(2);
distT=(sqrt((x0-x1).^2+(y0-y1).^2)); 
end

