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

% Define original time vector: 24 points, 15-second intervals (0 to 345 seconds)
original_time = (0:15:345)';

% Scale minutely time to new time range (map to 0–345 seconds)
scaled_time = (minutely_time / max(minutely_time)) * 345;

% Verify lengths before interpolation
if length(scaled_time) ~= length(irradiance)
    error('Scaled time and irradiance vectors have different lengths: %d vs %d', length(scaled_time), length(irradiance));
end

% Interpolate irradiance data to original 24 points, ensure non-negative
original_irradiance = max(0, interp1(scaled_time, irradiance, original_time, 'linear'));

% Create a dense time grid (1-second intervals from 0 to 345 seconds)
dense_time = (0:1:345)';

% Perform spline interpolation on the dense grid
dense_irradiance = interp1(original_time, original_irradiance, dense_time, 'spline');

% Ensure non-negative irradiance
dense_irradiance = max(0, dense_irradiance);

% Create output variable: [time, irradiance] with dense points
output_data = [dense_time, dense_irradiance];

% Save to workspace for Simulink
assignin('base', 'solar_data', output_data);

% Display values around 60-90 seconds for verification
idx_original = find(original_time >= 60 & original_time <= 90);
idx_dense = find(dense_time >= 60 & dense_time <= 90);
disp('Original values around 60-90 seconds:');
disp([original_time(idx_original), original_irradiance(idx_original)]);
disp('Dense values around 60-90 seconds (subset):');
disp([dense_time(idx_dense(1:5:end)), dense_irradiance(idx_dense(1:5:end))]); % Show every 5th point for brevity

% Plot original and dense data
figure;
plot(original_time, original_irradiance, '-o', 'DisplayName', 'Original (15s intervals)');
hold on;
plot(dense_time, dense_irradiance, '-', 'DisplayName', 'Dense (1s intervals)');
plot(original_time(idx_original), original_irradiance(idx_original), 'r*', 'DisplayName', 'Original Points (60-90s)');
xlabel('Time (seconds)');
ylabel('Global Tilted Irradiance (W/m²)');
title('Global Tilted Irradiance Data with Dense Spline Interpolation');
legend;
grid on;