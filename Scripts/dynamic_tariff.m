% Read the Excel file, preserving original column names
data_tariff = readtable('D:\Study\Masters in Automation and IT\Semester 2\PAC in Electrical Energy System\Assignment\Dynamic Tariffs\dynamic_tariff.xlsx', 'VariableNamingRule', 'preserve');

% Extract timestamps and prices from tariff data
timestamps_tariff = data_tariff.timestamp; % Timestamps in seconds since epoch
prices = data_tariff.("price(cent/kWh)");  % Tariff prices in cent/kWh

% Convert timestamps to a relative time vector
time_relative_tariff = seconds(datetime(timestamps_tariff, 'ConvertFrom', 'posixtime') - datetime(timestamps_tariff(1), 'ConvertFrom', 'posixtime'));

% Define the original time vector length (based on data points)
n_points_tariff = length(time_relative_tariff);

% Define the target time range (0 to 4 seconds) with dense points
dense_time = (0:0.01:4)'; % 0.01-second intervals from 0 to 4 seconds

% Scale the original time to the new range (0 to 4 seconds)
scaled_time_tariff = (time_relative_tariff / max(time_relative_tariff)) * 4;

% Verify lengths before interpolation
if length(scaled_time_tariff) ~= length(prices)
    error('Scaled time and tariff vectors have different lengths.');
end

% Create dense prices with step-wise (constant) values between timestamps
dense_prices = zeros(size(dense_time));
for i = 1:length(timestamps_tariff)-1
    % Find indices where dense_time falls within the current time interval
    idx = dense_time >= scaled_time_tariff(i) & dense_time < scaled_time_tariff(i+1);
    dense_prices(idx) = prices(i);
end
% Assign the last price to the remaining indices
idx_last = dense_time >= scaled_time_tariff(end);
dense_prices(idx_last) = prices(end);

% Create output data matrix: [time, price]
tariff_data = [dense_time, dense_prices];

% Save to workspace for Simulink
assignin('base', 'tariff_data', tariff_data);

% Plot original and dense data
% plot(scaled_time_tariff, prices, '-o', 'DisplayName', 'Original Price');
% hold on;
plot(dense_time, dense_prices, '-', 'DisplayName', 'Dense Price');
xlabel('Time (seconds)');
ylabel('Price (cent/kWh)');
title('Dynamic Tariff with Dense Step Interpolation (4s Duration)');
legend;
grid on;