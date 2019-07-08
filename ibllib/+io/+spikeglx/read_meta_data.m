function meta = read_meta_data(file_meta_data)
% Reads spikeglx meta data file, parse key values
% meta = io.spikeglx.read(file_meta_data)
% returns a struct

fid = fopen(file_meta_data);
% interpret each line as a k=v string
while true
    l = fgetl(fid);
    if l == -1, break, end
    kv = split(l, '=');
    % interpret as numeric if possible
    if ~isempty(str2num(kv{2})), kv{2} = str2num(kv{2}); end
    % remove strange characters from structure name
    meta.(strrep(kv{1}, '~', '')) = kv{2};
end
fclose(fid);

end

