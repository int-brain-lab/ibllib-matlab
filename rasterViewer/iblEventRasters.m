



function iblEventRasters(s, nProbe)
% Wrapper for evRastersGUI from /cortex-lab/spikes
%
% Inputs:
%   - s - is a struct created with loadSession
%   - nProbe - is an index of which probe to include (1-indexed, i.e. cannot
%   be zero)
%
% Example usage:
% >> s = loadSession('Muller_2017-01-07');
% >> eventRasters(s)

fprintf(1, 'initializing...\n');
if nargin<2
    nProbe = 1; 
end

inclCID = find(double(s.clusters.probes)==nProbe-1)-1; 
inclSpikes = ismember(s.spikes.clusters, inclCID);

st = s.spikes.times(inclSpikes); 
clu = s.spikes.clusters(inclSpikes); 

% lickTimes = s.licks.times;
lickTimes = [1 2 3]';

s.trials = s.x_ibl_trials;
contrastLeft = s.trials.contrastLeft; contrastLeft(isnan(contrastLeft)) = 0;
contrastRight = s.trials.contrastRight; contrastRight(isnan(contrastRight)) = 0;
feedback = s.trials.feedbackType;
choice = s.trials.choice;
choice(choice==0) = 3; choice(choice==1) = 2; choice(choice==-1) = 1;

cweA = table(contrastLeft, contrastRight, feedback, choice); 

stimOn = s.trials.stimOn_times;
beeps = s.trials.goCue_times;
feedbackTime = s.trials.feedback_times;

cwtA = table(stimOn, beeps, feedbackTime);

moveData = struct();
% moveData.moveOnsets = s.wheelMoves.intervals(:,1); 
% moveData.moveOffsets = s.wheelMoves.intervals(:,2); 
% moveData.moveType = s.wheelMoves.type;
whT = s.x_ibl_wheel.times;
whPos = s.x_ibl_wheel.position;
Fs = 1000; 
whTeven = whT(1):1/Fs:whT(end);
whPos = interp1(whT, whPos, whTeven); 
params.posThresh = 0.1; % if position changes by less than this
params.tThresh = 0.2; % over at least this much time, then it is a quiescent period
params.minGap = 0.1; % any movements that have this little time between the end of one and
    % the start of the next, we'll join them
params.posThreshOnset = 0.05; % a lower threshold, used when finding exact onset times.     
params.minDur = 0.05; % seconds, movements shorter than this are dropped
fprintf(1, 'computing wheel movements...\n');
[moveOnsets, moveOffsets, moveAmps, peakVelTimes] = wheel.findWheelMoves3(whPos, whTeven, Fs, params);
moveType = wheel.classifyWheelMoves(whTeven, -whPos, moveOnsets, moveOffsets, beeps, feedbackTime, choice);
moveData.moveOnsets = moveOnsets; 
moveData.moveOffsets = moveOffsets; 
moveData.moveType = moveType;

% anatData - a struct with: 
%   - coords - [nCh 2] coordinates of sites on the probe
%   - wfLoc - [nClu nCh] size of the neuron on each channel
%   - borders - table containing upperBorder, lowerBorder, acronym
%   - clusterIDs - an ordering of clusterIDs that you like
%   - waveforms - [nClu nCh nTimepoints] waveforms of the neurons
anatData = struct();
coords = s.channels.localCoordinates(s.channels.probes==nProbe-1,:);
anatData.coords = coords;

% temps = s.clusters.templateWaveforms(inclCID+1,:,:);
% tempIdx = s.clusters.templateWaveformChans(inclCID+1,:);
% wfs = zeros(numel(inclCID), size(coords,1), size(temps,2));
% for q = 1:size(wfs,1); wfs(q,tempIdx(q,:)+1,:) = squeeze(temps(q,:,:))'; end
% anatData.wfLoc = max(wfs,[],3)-min(wfs,[],3); 
% anatData.waveforms = wfs;
wfLoc = zeros(numel(inclCID), size(coords,1));
wfLoc(sub2ind(size(wfLoc), [1:numel(inclCID)]', s.clusters.channels(inclCID+1)+1)) = 10;
anatData.wfLoc = wfLoc; 
anatData.waveforms = zeros(numel(inclCID), size(coords,1), 50);

% acr = s.channels.brainLocation.allen_ontology(s.channels.probe==nProbe-1,:);
% lowerBorder = 0; upperBorder = []; acronym = {acr(1,:)};
% for q = 2:size(acr,1)
%     if ~strcmp(acr(q,:), acronym{end})
%         upperBorder(end+1) = coords(q,2); 
%         lowerBorder(end+1) = coords(q,2); 
%         acronym{end+1} = acr(q,:);
%     end
% end
% upperBorder(end+1) = max(coords(:,2));
% upperBorder = upperBorder'; lowerBorder = lowerBorder'; acronym = acronym';
upperBorder = 3840; lowerBorder = 0; acronym = {'unknown'};
anatData.borders = table(upperBorder, lowerBorder, acronym);

pkCh = s.clusters.channels(s.clusters.probes==nProbe-1);
[~,ii] = sort(pkCh); 
anatData.clusterIDs = inclCID(ii); 
anatData.wfLoc = anatData.wfLoc(ii,:); 
anatData.waveforms = anatData.waveforms(ii,:,:);

fprintf(1, 'starting GUI...\n');
f = evRastersGUI(st, clu, cweA, cwtA, moveData, lickTimes, anatData);