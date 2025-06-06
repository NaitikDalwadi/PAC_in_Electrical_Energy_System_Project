% Fetch data from Open-Meteo (15-minute resolution)
url = 'https://api.open-meteo.com/v1/forecast?latitude=51.0261&longitude=7.5647&models=icon_seamless&minutely_15=global_tilted_irradiance&forecast_days=1&tilt=43';
data = webread(url);

% Extract and preprocess
times = data.minutely_15.time;
irradiance = data.minutely_15.global_tilted_irradiance;
time_dt = datetime(times, 'InputFormat', 'yyyy-MM-dd''T''HH:mm');
time_seconds = seconds(time_dt - time_dt(1));
irradiance = double(irradiance);

% Check lengths
fprintf('Number of time points: %d\n', length(times));
fprintf('Number of irradiance points: %d\n', length(irradiance));
if length(times) ~= length(irradiance)
    error('Time and irradiance vectors have different lengths: %d vs %d', length(times), length(irradiance));
end

% Define minutely time based on actual data length
n_points = length(times);
minutely_time = (0:900:(n_points-1)*900)';
if length(minutely_time) > n_points
    minutely_time = minutely_time(1:n_points); % Trim to match data
elseif length(minutely_time) < n_points
    irradiance = irradiance(1:length(minutely_time)); % Trim irradiance if needed
end

% Define original time vector: 24 points, 0.167-second intervals (0 to 4 seconds)
original_time = (0:0.167:4)';

% Scale minutely time to new time range (map to 0–4 seconds)
scaled_time = (minutely_time / max(minutely_time)) * 4;

% Verify lengths before interpolation
if length(scaled_time) ~= length(irradiance)
    error('Scaled time and irradiance vectors have different lengths: %d vs %d', length(scaled_time), length(irradiance));
end

% Interpolate irradiance data to original 24 points, ensure non-negative
original_irradiance = max(0, interp1(scaled_time, irradiance, original_time, 'linear'));

% Create a dense time grid (0.01-second intervals from 0 to 4 seconds)
dense_time = (0:0.01:4)';

% Perform spline interpolation on the dense grid
dense_irradiance = interp1(original_time, original_irradiance, dense_time, 'spline');

% Ensure non-negative irradiance
dense_irradiance = max(0, dense_irradiance);

% Create output variable: [time, irradiance] with dense points
output_data = [dense_time, dense_irradiance];

% Save to workspace for Simulink
assignin('base', 'solar_data', output_data);

% Display values around 0.7-1.0 seconds for verification (scaled from 60-90s to 0.7-1.0s)
idx_original = find(original_time >= 0.7 & original_time <= 1.0);
idx_dense = find(dense_time >= 0.7 & dense_time <= 1.0);
disp('Original values around 0.7-1.0 seconds:');
disp([original_time(idx_original), original_irradiance(idx_original)]);
disp('Dense values around 0.7-1.0 seconds (subset):');
disp([dense_time(idx_dense(1:5:end)), dense_irradiance(idx_dense(1:5:end))]); % Show every 5th point for brevity

% Plot original and dense data
figure;
plot(original_time, original_irradiance, '-o', 'DisplayName', 'Original (0.167s intervals)');
hold on;
plot(dense_time, dense_irradiance, '-', 'DisplayName', 'Dense (0.01s intervals)');
plot(original_time(idx_original), original_irradiance(idx_original), 'r*', 'DisplayName', 'Original Points (0.7-1.0s)');
xlabel('Time (seconds)');
ylabel('Global Tilted Irradiance (W/m²)');
title('Global Tilted Irradiance Data with Dense Spline Interpolation (4s Duration)');
legend;
grid on;