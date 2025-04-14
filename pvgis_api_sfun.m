function pvgis_api_sfun(block)
    % Level-2 MATLAB S-Function to fetch PVGIS data and output irradiance/temperature
    setup(block);
end

function setup(block)
    % Register number of ports
    block.NumInputPorts  = 8; % lat, lon, year, peakpower, loss, angle, azimuth, t
    block.NumOutputPorts = 2; % ghi, temp

    % Setup port properties
    for i = 1:7
        block.InputPort(i).Dimensions  = 1;
        block.InputPort(i).DatatypeID  = 0; % double
        block.InputPort(i).Complexity  = 'Real';
        block.InputPort(i).DirectFeedthrough = false;
    end
    block.InputPort(8).Dimensions  = 1; % t
    block.InputPort(8).DatatypeID  = 0;
    block.InputPort(8).Complexity  = 'Real';
    block.InputPort(8).DirectFeedthrough = true;

    for i = 1:2
        block.OutputPort(i).Dimensions  = 1;
        block.OutputPort(i).DatatypeID  = 0; % double
        block.OutputPort(i).Complexity  = 'Real';
    end

    % Register parameters
    block.NumDialogPrms = 0;

    % Register methods
    block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Outputs', @Outputs);
    block.RegBlockMethod('SetInputPortDimensions', @SetInputPortDimensions);
end

function SetInputPortDimensions(block, port, dimsInfo)
    block.InputPort(port).Dimensions = dimsInfo;
end

function DoPostPropSetup(block)
    % Define the number of DWork vectors for persistent storage
    block.NumDWorks = 2; % One for ts_ghi, one for ts_temp
    % Do not set DWork properties here to avoid the error
end

function Start(block)
    % Fetch data at simulation start
    lat = block.InputPort(1).Data;
    lon = block.InputPort(2).Data;
    year = block.InputPort(3).Data;
    peakpower = block.InputPort(4).Data;
    loss = block.InputPort(5).Data;
    angle = block.InputPort(6).Data;
    azimuth = block.InputPort(7).Data;

    % Call getPVGISData (or load cached data)
    if exist('pvgis_data.mat', 'file')
        load('pvgis_data.mat', 'timeseries_ghi', 'timeseries_temp');
        ts_ghi = timeseries_ghi;
        ts_temp = timeseries_temp;
    else
        [ts_ghi, ts_temp, ~] = getPVGISData(lat, lon, year, peakpower, loss, angle, azimuth);
        save('pvgis_data.mat', 'ts_ghi', 'ts_temp');
    end

    % Configure DWork properties
    try
        block.DWork(1).Name = 'ts_ghi';
        block.DWork(1).Data = ts_ghi;
        fprintf('Start - DWork(1).Name set to: %s\n', block.DWork(1).Name);
    catch e
        fprintf('Error setting DWork(1) properties: %s\n', e.message);
        rethrow(e);
    end

    try
        block.DWork(2).Name = 'ts_temp';
        block.DWork(2).Data = ts_temp;
        fprintf('Start - DWork(2).Name set to: %s\n', block.DWork(2).Name);
    catch e
        fprintf('Error setting DWork(2) properties: %s\n', e.message);
        rethrow(e);
    end
end

function Outputs(block)
    % Interpolate timeseries at current time t
    t = block.InputPort(8).Data; % Simulation time (seconds)
    ts_ghi = block.DWork(1).Data;
    ts_temp = block.DWork(2).Data;

    % Interpolate
    if isempty(ts_ghi.Data) || isempty(ts_temp.Data)
        ghi = 0;
        temp = 25; % Defaults if data fails
    else
        ghi = interp1(ts_ghi.Time, ts_ghi.Data, t, 'linear', 0);
        temp = interp1(ts_temp.Time, ts_temp.Data, t, 'linear', 0);
    end

    % Output
    block.OutputPort(1).Data = ghi;  % Irradiance (W/m²)
    block.OutputPort(2).Data = temp; % Temperature (°C)
end