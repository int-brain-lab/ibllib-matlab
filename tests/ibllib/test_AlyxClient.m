classdef test_AlyxClient < matlab.unittest.TestCase
 
    properties
        ac
        subjects
        water_types
    end
 
    methods(TestMethodSetup)
        function createObject(testCase)
            testCase.ac = AlyxClient('user', 'test_user', 'password', 'TapetesBloc18',...
                'base_url', 'https://test.alyx.internationalbrainlab.org');
            testCase.subjects = testCase.ac.get('/subjects');
            testCase.assertTrue(length(testCase.subjects.nickname)>=2)
            testCase.water_types = testCase.ac.get('/water-type');
            testCase.assertTrue(length(intersect(testCase.water_types.name, {'Water'; 'Hydrogel'})) == 2)
        end
    end
 
    methods(Test)
 
        function test_endpoint_url_format(testCase)
            sub = testCase.ac.get('subjects/flowers');            
            sub2 = testCase.ac.get('/subjects/flowers');
            testCase.assertEqual(sub, sub2);
            sub2 = testCase.ac.get([testCase.ac.base_url '/subjects/flowers']);
            testCase.assertEqual(sub, sub2);
        end
        
        function test_get_sessions(testCase)
            % tests automatic replacement of base_url or not
            r1 = testCase.ac.get_session('cf264653-2deb-44cb-aa84-89b82507028a');
            r2 = testCase.ac.get_session(...
                'https://test.alyx.internationalbrainlab.org/sessions/cf264653-2deb-44cb-aa84-89b82507028a');
            testCase.verifyEqual(r1,r2);
        end
        
        function test_create_delete_water_admin(testCase)
            wa_ = struct(...
                'subject', testCase.subjects.nickname{1},...
                'date_time', time.serial2iso8601(now),...
                'water_type', 'Water',...
                'user', testCase.ac.user,...
                'adlib', true,...
                'water_administered', 0.52);
            rep = testCase.ac.post('/water-administrations', wa_);
            testCase.assertTrue(rep.water_administered == 0.52);
            % read after write
            rep = testCase.ac.get(rep.url);
            testCase.assertTrue(rep.water_administered == 0.52);
            % now delete the water administration
            testCase.ac.delete(rep.url);
            try
                testCase.ac.get(rep.url)    
                flag = false;
            catch err
                testCase.assertEqual(err.identifier, 'MATLAB:webservices:HTTP404StatusCodeError');
                flag = true;
            end
            testCase.assertTrue(flag);
        end
    end
end