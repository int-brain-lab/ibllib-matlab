classdef test_io_spikeglx < matlab.unittest.TestCase
    
    properties
        tdir
    end
    
    methods(TestMethodSetup)
        function create_dir_structures(testCase)
            % create a directory with subfolders and files
            testCase.tdir = [tempdir 'iotest' filesep];
            mkdir([testCase.tdir])
            % copy the meta data files in there
            file_meta = io.dir([fileparts(which('RunTestsIBL')) filesep 'fixtures' filesep 'spikeglx'], 'pattern', '*.meta');
            for m = 1:length(file_meta)
                [~, fn, ext] = fileparts(file_meta{m});
               copyfile(file_meta{m},  [testCase.tdir fn ext])
               meta = io.spikeglx.read_meta_data(file_meta{m});
               % write a binary file
               ns = meta.fileTimeSecs .* meta.imSampRate;
               assert(ns <= 30000)
               data = repmat(int16([1:ns]), meta.nSavedChans, 1);
               fid = fopen([testCase.tdir fn '.bin'], 'w+');
               fwrite(fid, data, '*int16');
               fclose(fid);
            end
        end
    end
    
    methods(TestMethodTeardown)
        function delete_dir(testCase)
            rmdir(testCase.tdir, 's');
        end
    end
    
    methods(Test)
        function test_read(testCase)
            % for each meta data file, interpret meta-data, create a fake binary file and read 
            files_bin = io.dir(testCase.tdir, 'pattern', '*.bin');
            for m = 1:length(files_bin)
                sr = io.spikeglx.Reader(files_bin{m});
                d = sr.read(1, 10);
                testCase.assertTrue(all(d(end, :) == 1:10))
                % test the function wrapper as well
                d2 = io.read.spikeglx(files_bin{m}, 1, 10);
                testCase.assertEqual(d, d2)
            end
        end
    end
end