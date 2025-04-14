function [timeseries_ghi, timeseries_temp, pv_power] = IRR_DATA_API(lat, lon, year, peakpower, loss, angle, azimuth)
    % GETPVGISDATA Fetch PVGIS solar data for Simulink PV simulation
    % Inputs:
    %   lat      - Latitude (degrees, e.g., 40.7128 for New York)
    %   lon      - Longitude (degrees, e.g., -74.0060)
    %   year     - Data year (e.g., 2020, PVGIS supports 2005–2020)
    %   peakpower- PV system size (kW, e.g., 4)
    %   loss     - System losses (%, e.g., 14)
    %   angle    - Panel tilt angle (degrees, e.g., 40)
    %   azimuth  - Panel azimuth (degrees, e.g., 180 for south-facing)
    % Outputs:
    %   timeseries_ghi  - Timeseries of irradiance (W/m², G_i_)
    %   timeseries_temp - Timeseries of temperature (°C, T2m)
    %   pv_power        - Array of PV power output (W, P), empty if unavailable

    try
        % Construct PVGIS API URL
        url = sprintf(['https://re.jrc.ec.europa.eu/api/seriescalc?' ...
                       'lat=%f&lon=%f&outputformat=json&pvcalculation=1' ...
                       '&peakpower=%f&loss=%f&angle=%f&azimuth=%f' ...
                       '&startyear=%d&endyear=%d'], ...
                       lat, lon, peakpower, loss, angle, azimuth, year, year);
        
        % Fetch data
        options = weboptions('Timeout', 15);
        data = webread(url, options);
        
        % Extract hourly data
        hourly = data.outputs.hourly;
        n_points = numel(hourly);
        time = datetime({hourly.time}, 'InputFormat', 'yyyyMMdd:HHmm');
        
        % Explicitly extract G_i_ and T2m as vectors
        ghi = zeros(n_points, 1);
        temp = zeros(n_points, 1);
        for i = 1:n_points
            ghi(i) = hourly(i).G_i_;
            temp(i) = hourly(i).T2m;
        end
        
        % PV power (optional)
        if isfield(hourly, 'P')
            pv_power = zeros(n_points, 1);
            for i = 1:n_points
                pv_power(i) = hourly(i).P;
            end
            disp('PV power data (P) included.');
        else
            pv_power = [];
            warning('No PV power data (P) in response.');
        end
        
        % Create timeseries for Simulink
        timeseries_ghi = timeseries(ghi, posixtime(time));
        timeseries_temp = timeseries(temp, posixtime(time));
        
        % Ensure timeseries are valid
        if isempty(ghi) || isempty(temp)
            error('Empty irradiance or temperature data retrieved.');
        end
        
        % Debugging info
        fprintf('Fetched %d data points for %s to %s\n', ...
                numel(time), datestr(time(1)), datestr(time(end)));
        fprintf('G_i_ size: %s\n', mat2str(size(ghi)));
        fprintf('T2m size: %s\n', mat2str(size(temp)));
        
    catch e
        fprintf('Error fetching PVGIS data: %s\n', e.message);
        timeseries_ghi = timeseries(zeros(8760,1), (0:3600:8760*3600-3600)');
        timeseries_temp = timeseries(25*ones(8760,1), (0:3600:8760*3600-3600)');
        pv_power = [];
    end
end