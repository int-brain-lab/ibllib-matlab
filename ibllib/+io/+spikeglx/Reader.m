classdef Reader
    %SPIKEGLXREADER Summary of this class goes here
    %   Detailed explanation goes here
%     file_bin = '/datadisk/Data/Subjects/ZM_1150/2019-05-07/001/raw_ephys_data/probe_right/ephysData_g0_t0.imec.ap.bin'
    properties (SetAccess=immutable)
        file_bin = ''  % full path binary file
        file_meta_data = ''  % full path meta-data file
        nbytes  % total data size
        nc  % number of channels
        ns  % number of samples
        fs  % sampling frequency (Hz)
        meta = struct()  % meta data structure
        int2volts  % conversion facor (v = sample * int2volts / gain)
        gain_channels = 1  % scalar or vector of gains to be applied to raw
        memmap  % memmap object of the file (read-only)
        type  % 'lf' or 'ap'
    end
    
    methods
        function self = Reader(file_bin)
            %SPIKEGLXREADER Construct an instance of this class
            %   sr = SpikeGlxReader(file_bin)
            self.file_bin = file_bin;
            [pn, fn, ~] = fileparts(file_bin);
            self.file_meta_data = [pn, filesep, fn, '.meta'];
            finfo = dir(file_bin);
            self.nbytes = finfo.bytes;
            self.meta = io.spikeglx.read_meta_data(self.file_meta_data);
            % set properties from meta-data: the basics: nc, fs
            self.nc = sum(self.meta.snsApLfSy);
            if strcmp(self.meta.typeThis, 'imec')
                self.fs = self.meta.imSampRate;
            else
                self.fs = self.meta.niSampRate;
            end
            self.ns = self.meta.fileTimeSecs * self.fs;
            % make sure that it checks out
            assert(self.nc * self.ns * 2 == self.nbytes)
            % scaling factor. Needs to be combined with gain also
            if isempty(self.meta.typeThis)
                self.int2volts = self.meta.imAiRangeMax / 512;
            else
                self.int2volts = self.meta.imAiRangeMax / 768;
            end
            if self.meta.snsApLfSy(1) == 0 && self.meta.snsApLfSy(2) ~= 0
                self.type = 'lf';
            elseif self.meta.snsApLfSy(2) == 0 && self.meta.snsApLfSy(1) ~= 0
                self.type = 'ap';
            end
            % get the gains from meta data file
            self.gain_channels = self.gain_channels_from_meta(self.meta);
            % create a memmap file as well
            self.memmap = memmapfile(self.file_bin, 'Format', {'int16', [self.nc, self.ns], 'samples'}, 'Writable', false);
        end
        
        
        function D = read(self, firstsample, lastsample)
            % reads specific samples from the data
            % returns full data array
            D = self.memmap.Data.samples(:, firstsample:lastsample);
            sync_tr_ind = find(self.gain_channels.(self.type) == 1);
            gain = 1 ./ self.gain_channels.(self.type) .* self.int2volts;
            gain(sync_tr_ind) = 1;
            D = single(D) .* gain;
        end
    end
    
    methods (Static)
        function gain = gain_channels_from_meta(meta)
            % from the metadata structure (io.spikeglx.read_meta_data), a vector (nc, 1) containing gains
            gain = 1;
            if ~isfield(meta, 'imroTbl'), return, end
            sy_gain = ones(1, meta.snsApLfSy(end));
            % string is a set of (channel, ?, ?, apgain, lfgain)
            gain = sscanf(meta.imroTbl(find(meta.imroTbl == ')', 1, 'first') + 1:end), '(%i %i %i %i %i)');
            gain = reshape(gain, 5, length(gain) / 5);
            gain = struct('lf', [gain(end, :) sy_gain]', 'ap', [gain(end, :) sy_gain]');
        end
    end
end

