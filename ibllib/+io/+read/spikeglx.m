function [D, meta] = spikeglx(bin_file, first, last)
% D = io.read.spikeglx(bin_file, first, last)
% Returns binary data in Volts

sr = io.spikeglx.Reader(bin_file);
D = sr.read(first, last);

meta = sr.meta;

end

