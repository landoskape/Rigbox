classdef calibrate_test < matlab.unittest.TestCase & matlab.mock.TestCase & matlab.mixin.SetGet
  % CALIBRATE_TEST Tests for hw.calibrate
  
  properties % Mocks
    % Mock object for hw.WeighingScale class
    scale
    % Mock object for hw.RewardValveControl (or any
    % hw.ControlSignalGenerator sub-class)
    generator
    % Mock object for hw.DaqController class
    controller
    % Mock scale behaviour
    scaleBehaviour
    % Mock signal generator behaviour
    generatorBehaviour
    % Mock daq controller behaviour
    controllerBehaviour
  end
  
  properties % Parameters for hw.calibrate
    tMin = 20e-3
    tMax = 150e-3
    interval = 0.1
    delivPerSample = 300
    nPerT = 3
    nVolumes = 5
    % Range of volumes to simulate, in ul
    volumeRange = [0.06, 3.5]
    % The amount of noise in simulated weight measurments
    noise = 0.05; % s.d.
  end
  
  properties (Access = protected)
    % A place to store values for readGrams to fetch
    LastGrams
    % Column of weight measurments to return upon calling readGrams
    measurements
  end
  
  methods (TestClassSetup)
    function setupMocks(testCase)
      % Create mocks.  Note that using a metaclass to instantiate a mock
      % only adds abstract properties and methods.  We will therefore
      % create some custom mock objects using the concrete properties and
      % methods of our classes:
      
      % A hw.WeighihngScale mock
      [testCase.scale, testCase.scaleBehaviour] = ...
        createMock(testCase, ...
        'AddedProperties', properties(hw.WeighingScale)', ...
        'AddedMethods', methods(hw.WeighingScale)');
      % A hw.RewardValveControl mock
      [testCase.generator, testCase.generatorBehaviour] = ...
        createMock(testCase, ...
        'AddedProperties', properties(hw.RewardValveControl)', ...
        'AddedMethods', methods(hw.RewardValveControl)');
      % A hw.DaqController mock
      [testCase.controller, testCase.controllerBehaviour] = ...
        createMock(testCase, ...
        'AddedProperties', properties(hw.DaqController)', ...
        'AddedMethods', methods(hw.DaqController)');
    end
    
  end
  
  methods (TestMethodSetup)
    
    function mockMeasurements(testCase)
      % Create some simulated measurements based on the parameters that
      % will be passes to the calibrate function. Could be used to simulate
      % calibration accuracy under certain perameters in the presence of
      % some assumed measurment noise.
      % Fetch the rewards volume range to simulate
      rng = testCase.volumeRange; % ul
      % Replicate based on number of samples and deliveries
      vols = linspace(rng(1), rng(2), testCase.nVolumes) * testCase.delivPerSample;
      % Sample from a Gaussian with some s.d. 1e3 = ul -> g
      r = normrnd(repmat(vols, testCase.nPerT, 1), testCase.noise) / 1e3;
      % Cumulatively sum the measurements, add preceeding volumes for scale
      % check readings
      testCase.measurements = cumsum([0; 3; r(:)]);
    end
    
    function setBehaviours(testCase)
      % Setup some mock behaviours that apply to all tests
      
      % Import all the mock action tools we need
      import matlab.mock.actions.Invoke
      import matlab.mock.actions.AssignOutputs
      import matlab.mock.actions.StoreValue
      import matlab.mock.actions.ReturnStoredValue
      
      % Define behaviours for scale object manipulation
      % Return a serial object when Port is accessed to pass checks
      testCase.assignOutputsWhen(... % ComPort
        get(testCase.scaleBehaviour.Port), serial('port'))
      % Define tare behaviour; set our property to 0
      when(testCase.scaleBehaviour.tare.withExactInputs, ...
        Invoke(@(~) set(testCase, 'LastGrams', 0)));
      % Zero scale during init
      when(testCase.scaleBehaviour.init.withExactInputs, ...
        Invoke(@(~) testCase.scale.tare()));
      
      % Define behaviours for controller
      names = {'rewardValve', 'digitalChannel'};
      testCase.assignOutputsWhen(... % ChannelNames
        get(testCase.controllerBehaviour.ChannelNames), names)
      % Return an array of generator mocks the size of ChannelNames
      generators = repmat(testCase.generator, size(names));
      testCase.assignOutputsWhen(... % SignalGenerators
        get(testCase.controllerBehaviour.SignalGenerators), generators)
      
      % Define behaviours for generator; allow ParamsFun set and get 
      when(set(testCase.generatorBehaviour.ParamsFun), StoreValue)
      when(get(testCase.generatorBehaviour.ParamsFun), ReturnStoredValue)
    end
  end
  
  methods (Test)
    
    function test_calibration(tc)
      % Test the behaviour and results when calibrating given the default
      % input parameters
      
      % Update out scale mock so that each time the function calls
      % readGrams, a the next simulated measurement is returned.
      % Measurments are generated by the mockMeasurements setup method and
      % stored in the measurements property.
      import matlab.mock.actions.AssignOutputs
      action = AssignOutputs(0);
      for i = 1:length(tc.measurements)
        action = action.then(AssignOutputs(tc.measurements(i)));
      end
      when(tc.scaleBehaviour.readGrams.withExactInputs, action)
      
      % Set something to check ParamsFun is reset on errors.  Sometimes
      % testing function handle equality is too strict, so let's instead
      % use the returned value.
      rnd = rand; % Store a random number as over-zealous confirmation
      tc.generator.ParamsFun = @()rnd;
      
      % Call the function under test with our mock objects and parameters
      hw.calibrate('rewardValve', tc.controller, tc.scale, tc.tMin, tc.tMax, ...
        'settleWait', 0, ... % Set to zero to trim test time
        'nPert', tc.nPerT, ...
        'nVolumes', tc.nVolumes, ...
        'interval', tc.interval, ...
        'delivPerSample', tc.delivPerSample);
      
      % Retrieve mock history
      history = tc.getMockHistory(tc.generator);
      % Mock history is stored in an obnoxious manner that required some
      % effort to sort.  Let's create a sequence and filter the
      % Calibrations property access events. 
      f = @(a)endsWith(class(a), 'Modification') && strcmp(a.Name, 'Calibrations');
      seq = sequence(mapToCell(@identity, history)); % Map to cell array
      actual = seq.reverse.filter(f).first.Value; % Get value of last mod
      % Double-check Calibrations was modified at least once
      tc.assertTrue(~isNil(actual), 'Failed to record calibration')
      
      % Check the datetime recorded was reasonable
      tolerance = 1/(24*60); % 1 Minute
      tc.verifyEqual(actual.dateTime, now, 'AbsTol', tolerance, ...
        'Unexpected date time recorded for calibration')
      % Check the value range corresponds to our inputs
      minMax = [actual.measuredDeliveries([1 end]).durationSecs];
      tc.verifyEqual(minMax, [tc.tMin, tc.tMax], 'Unexpected measured time range')
      
      % See if the volumes it measured are close to the range we're testing
      rng = tc.volumeRange;
      vols = linspace(rng(1), rng(2), tc.nVolumes); % Expand to number of volumes
      tc.verifyEqual(vols, [actual.measuredDeliveries.volumeMicroLitres], 'AbsTol', 0.3);
      
      % Check the previous ParamsFun was reset after calibration.  This is
      % over-zelous as the object is never saved after calibrations anyway.
      tc.verifyEqual(tc.generator.ParamsFun(), rnd, ...
        'Failed to reset ParamsFun property in signal generator')
      
      % Retrieve mock history for the DaqControllor
      history = tc.getMockHistory(tc.controller);
      % Find inputs to command method: the method that would open the valve
      f = @(a) strcmp(a.Name, 'command');
      in = cell2mat(fun.map(@(a)a.Inputs{2}, fun.filter(f, history)))';
      
      % Check the parameters values and number of valve open times
      expected = (tc.nPerT * tc.nVolumes) + 1; % +1 for scale test
      tc.verifyEqual(expected, size(in,1), ...
        'Unexpected number of called to DAQ command method')
      tc.verifyTrue(all(in(2:end,3) == tc.delivPerSample), ...
        'Unexpected number of called to DAQ command method')
      tc.verifyTrue(all(in(2:end,2) == tc.interval), ...
        'Unexpected number of called to DAQ command method')
    end
    
    function test_scale_fails(tc)
      % Test behaviour when things go wrong.  We're looking for informative
      % errors and adequate object clean-up
      
      % Import more nonsense
      import matlab.mock.actions.Invoke
      import matlab.mock.actions.AssignOutputs
      import matlab.mock.actions.ThrowException
      % Define readGrams behaviour.  For this test just retrieve the value
      % stored in LastGrams, which will stay as zero
      when(tc.scaleBehaviour.readGrams.withExactInputs, ...
        Invoke(@(~) tc.LastGrams));
      
      % Set something to check ParamsFun is reset on errors.  Sometimes
      % testing function handle equality is too strict, so let's instead
      % use the returned value.
      rnd = rand; % Store a random number as over-zealous confirmation
      tc.generator.ParamsFun = @()rnd;
      
      % Test errors on uninitiated scale:
      fn = @()hw.calibrate('rewardValve', tc.controller, ...
        hw.WeighingScale, tc.tMin, tc.tMax, 'settleWait', 0);
      tc.verifyError(fn, 'Rigbox:hw:calibrate:noscales')
      % Test input errors are informative:
      fn = @()hw.calibrate('rewardValve', tc.controller, ...
        hw.WeighingScale, tc.tMin, tc.tMax, 'partial');
      tc.verifyError(fn, 'Rigbox:hw:calibrate:partialPVpair')
      % Test unresponsive scale
      tc.scale.init; % Sets LastGrams to zero
      fn = @()hw.calibrate('rewardValve', tc.controller, ...
        tc.scale, tc.tMin, tc.tMax, 'settleWait', 0);
      tc.verifyError(fn, 'Rigbox:hw:calibrate:deadscale')
      tc.verifyEqual(tc.generator.ParamsFun(), rnd, ...
        'Failed to reset ParamsFun property in signal generator')
      
      % For this test return some reasonable weights to pass tests, then
      % throw exception in the middle of the calibration
      action = AssignOutputs(0);
      for i = 1:length([0;3;3])
        action = action.then(AssignOutputs(tc.measurements(i)));
      end
      action = action.then(ThrowException(MException('test:unexpected','')));
      when(tc.scaleBehaviour.readGrams.withExactInputs, action)
      fn = @()hw.calibrate('rewardValve', tc.controller, ...
        tc.scale, tc.tMin, tc.tMax, 'settleWait', 0);
      tc.verifyError(fn, 'test:unexpected')
      tc.verifyEqual(tc.generator.ParamsFun(), rnd, ...
        'Failed to reset ParamsFun property in signal generator')
    end
  end
  
end