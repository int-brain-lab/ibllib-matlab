classdef test_ElectrodeArray < matlab.unittest.TestCase
    
    properties
        E
    end
    
    
    methods(TestMethodSetup)
        function create_object(testCase)
            % test constructor
            [ap, ml] = meshgrid(linspace(-.001, .001,11), linspace(-.002, .002,21));
            ap = ap(:);  ml = ml(:);

            dvmlap_entry = [ap.*0 ml ap];
            dvmlap_tip = [ap.*0 + 0.035 ml ap];
            testCase.E = ElectrodeArray(dvmlap_entry, dvmlap_tip);
        end
    end

    
    methods(Test)
        function test_constructor(testCase)
            E = testCase.E;
        end
    end
end