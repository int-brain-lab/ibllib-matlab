

function iblNeuronRasterViewer()

rootDir = uigetdir(pwd, 'Select folder containing the downloaded session');

if ~isempty(rootDir)
    
        
        % load session 
        s = loadSession(rootDir);
        
%         r = s.probes.rawFilename.rawFilename;
%         probeNames = arrayfun(@(x)r(x,:),1:size(r,1),'uni',false);
        probeNames = arrayfun(@num2str,unique(s.clusters.probes), 'uni', false);
        
        if numel(probeNames)>1
            indx = listdlg('ListString',probeNames, 'Name', 'Select a recording');
        else
            indx = 1;
        end
        
        
        if ~isempty(indx)
            iblEventRasters(s,indx);
        end
    end
end



