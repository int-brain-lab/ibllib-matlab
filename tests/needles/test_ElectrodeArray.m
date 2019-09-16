classdef test_ElectrodeArray < matlab.unittest.TestCase
    
    properties
        E1
        E2
    end
    
    
    methods(TestMethodSetup)
        function create_object(testCase)
            % create a set of electrodes with entry points on a flat surface
            [ap, ml] = meshgrid(linspace(-.001, .001,11), linspace(-.002, .002,21));
            ap = ap(:);  ml = ml(:); 
            dvmlap_entry = [ap.*0 ml ap];
            dvmlap_tip = [ap.*0 + 0.035 ml ap];
            testCase.E1 = ElectrodeArray(dvmlap_entry, dvmlap_tip);
            
            % create another subset of electrodes from a real insertion map
            entry = [0.0034772 -0.00215 -0.00842425;0.00193499503219871 -0.00265 -0.00742425;0.000973492548298068 -0.00065 -0.00692425;0.0015732 -0.00265 -0.00592425;0.0011448 -0.00115 -0.00542425;0.0008116 -0.00265 -0.00442425;0.0003356 -0.00115 -0.00392425;0.0008116 -0.00315 -0.00292425;0.000306829806807728 -0.00165 -0.00242425;0.00124 -0.00365 -0.00142425;0.0006212 -0.00215 -0.00092425;0.000535239742410303 -0.00065 -0.000424249999999999;0.0012876 -0.00265 0.000575750000000002;0.001002 -0.00115 0.00107575;0.0020016 -0.00265 0.00207575;0.0020968 -0.00215 0.00307575;0.00208729751609936 -0.00215 -0.00792425;0.0011924 -0.00065 -0.00742425;0.0016684 -0.00265 -0.00642425;0.00114488758049678 -0.00115 -0.00592425];
            tip = [0.00654623740367047 -0.00160884590092944 -0.00842425;0.0056772644936451 -0.00199013692486566 -0.00742425;0.00471576200974446 9.86307513433488e-06 -0.00692425;0.00531546946144639 -0.00199013692486566 -0.00592425;0.00488706946144639 -0.000490136924865665 -0.00542425;0.00455386946144639 -0.00199013692486566 -0.00442425;0.00407786946144639 -0.000490136924865665 -0.00392425;0.00455386946144639 -0.00249013692486567 -0.00292425;0.00404909926825412 -0.000990136924865665 -0.00242425;0.00498226946144639 -0.00299013692486566 -0.00142425;0.00436346946144639 -0.00149013692486567 -0.00092425;0.00427750920385669 9.86307513433488e-06 -0.000424249999999999;0.00502986946144639 -0.00199013692486566 0.000575750000000002;0.00474426946144639 -0.000490136924865665 0.00107575;0.00574386946144639 -0.00199013692486566 0.00207575;0.00496865177849396 -0.00164361504685592 0.00307575;0.00683846465439152 -0.000420716583637919 -0.00792425;0.00679025263961462 0.00138745173662821 -0.00742425;0.00684290988895339 -0.000766632423504854 -0.00642425;0.0067074616575563 0.000874611389950458 -0.00592425];
            coronal_index = [5000;5048;5072;5120;5144;5192;5216;5264;5288;5336;5360;5384;5432;5456;5504;5552;5024;5048;5096;5120];
            sagittal_index = [2168;2144;2240;2144;2216;2144;2216;2120;2192;2096;2168;2240;2144;2216;2144;2168;2168;2240;2144;2216];
            index = [1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;0;0;0;0];
            testCase.E2 = ElectrodeArray(entry, tip, 'coronal_index', coronal_index, 'sagittal_index', sagittal_index,...
                'index', index);
            
        end
    end
    
    
    methods(Test)
        function test_constructor(testCase)
            % makes sure default parameters are created if omitted
            E = testCase.E1;
            assert(length(E.probe_roll) == E.n)
        end
        
        function test_insertionLength(self)
            E = self.E1;
            % test with the full array
            self.assertTrue( all(E.insertion_length == .035))
            % try indexing the array
            self.assertTrue( length(E.insertion_length(1:5)) == 5)
        end
        
        
        function test_cartesian2spherical(testCase)
            %% 1:10:200
            E = testCase.E2;
            expected_el = 90 - [10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;20;20;20;20];
            expected_az = 0;
            testCase.assertTrue(all(round(E.elevation) == expected_el ))
            testCase.assertTrue(all(round(E.azimuth) == expected_az ))
        end
        
        function test_active_bounds(self)
           E = self.E2;
           low = E.site_lowest;
           high = E.site_highest;
           d = high-low;
           [~, ~, r] = cart2sph(d(:,1), d(:,2), d(:,3));           
           self.assertTrue(all(r <= 0.035))
           % test indexing
           self.assertTrue(all(E.site_lowest(1) == low(1, :)))
           self.assertTrue(all(all(E.site_highest(7:8) == high(7:8,:))))
        end
        
    end
end