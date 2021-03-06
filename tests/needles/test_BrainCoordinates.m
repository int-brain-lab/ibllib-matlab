classdef test_BrainCoordinates < matlab.unittest.TestCase
    
    
    methods(Test)
        function test_constructor(testCase)
            V = rand(20, 10, 5 );
            cs = BrainCoordinates(V);
            
            
            % test default parameters
            testCase.assertTrue(all([cs.i2z(1), cs.i2x(1), cs.i2y(1)] == 0))
            testCase.assertTrue(all([cs.i2z(2), cs.i2x(2), cs.i2y(2)] == 1))
            testCase.assertTrue(all(cs.iorigin==1))
            
            % test spatial resolutions
            cs = BrainCoordinates(V, 'dzxy', [-0.1 0.1 0.2]);
            testCase.assertTrue(all(cs.res == [-0.1 0.1 0.2]))
            testCase.assertTrue(all([cs.i2z(1), cs.i2x(1), cs.i2y(1)] == 0))
            testCase.assertTrue(all([cs.i2z(2), cs.i2x(2), cs.i2y(2)] == [-0.1 0.1 0.2]))
            testCase.assertTrue(all(cs.iorigin==1))
            
            % test origin
            BREGMA = [10 20 30];
            zxy0 = -[cs.i2z(BREGMA(1)), cs.i2x(BREGMA(2)), cs.i2y(BREGMA(3))];
            
            cs = BrainCoordinates(V, 'dzxy', [-0.1 0.1 0.2], 'zxy0', zxy0);
            testCase.assertTrue(all([cs.i2z(1), cs.i2x(1), cs.i2y(1)] == zxy0))
            testCase.assertTrue(all(cs.res == [-0.1 0.1 0.2]))
            testCase.assertTrue(all([cs.i2z(BREGMA(1)), cs.i2x(BREGMA(2)), cs.i2y(BREGMA(3))] == 0))
            
            testCase.assertTrue(all([cs.iii2zxy(BREGMA) == 0]))
        end
    end
end