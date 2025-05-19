% Fetch data from Open-Meteo
url = 'https://api.open-meteo.com/v1/forecast?latitude=51.0261&longitude=7.5647&hourly=direct_radiation&models=icon_seamless&forecast_days=1';
data = webread(url);

% Extract and preprocess
times = data.hourly.time;
radiation = data.hourly.direct_radiation;
time_dt = datetime(times, 'InputFormat', 'yyyy-MM-dd''T''HH:mm');
time_seconds = seconds(time_dt - time_dt(1));
radiation = double(radiation);

% Define original time vector: 24 points, 15-second intervals (0 to 345 seconds)
original_time = (0:15:345)';

% Scale original time to new time range (map 24 hours to 360 seconds)
hourly_time = (0:3600:23*3600)';
scaled_time = (hourly_time / (23*3600)) * 345;

% Interpolate radiation data to original 24 points, ensure non-negative
original_radiation = max(0, interp1(scaled_time, radiation, original_time, 'linear'));

% Create a dense time grid (1-second intervals from 0 to 345 seconds)
dense_time = (0:1:345)';

% Perform spline interpolation on the dense grid
% Use original 24 points as control points for the spline
dense_radiation = interp1(original_time, original_radiation, dense_time, 'spline');

% Ensure non-negative irradiance
dense_radiation = max(0, dense_radiation);

% Create output variable: [time, irradiance] with dense points
output_data = [dense_time, dense_radiation];

% Save to workspace for Simulink
assignin('base', 'solar_data', output_data);

% Display values around 60-90 seconds for verification
idx_original = find(original_time >= 60 & original_time <= 90);
idx_dense = find(dense_time >= 60 & dense_time <= 90);
disp('Original values around 60-90 seconds:');
disp([original_time(idx_original), original_radiation(idx_original)]);
disp('Dense values around 60-90 seconds (subset):');
disp([dense_time(idx_dense(1:5:end)), dense_radiation(idx_dense(1:5:end))]); % Show every 5th point for brevity

% Plot original and dense data
figure;
plot(original_time, original_radiation, '-o', 'DisplayName', 'Original (15s intervals)');
hold on;
plot(dense_time, dense_radiation, '-', 'DisplayName', 'Dense (1s intervals)');
plot(original_time(idx_original), original_radiation(idx_original), 'r*', 'DisplayName', 'Original Points (60-90s)');
xlabel('Time (seconds)');
ylabel('Direct Radiation (W/m²)');
title('Solar Radiation Data with Dense Spline Interpolation');
legend;
grid on;