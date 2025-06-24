% Read the Excel file, preserving original column names
data = readtable('D:\Study\Masters in Automation and IT\Semester 2\PAC in Electrical Energy System\Assignment\Dynamic Tariffs\dynamic_tariff.xlsx', 'VariableNamingRule', 'preserve');

% Extract timestamps and prices from the table
% Use the exact column name; if modified, it might be 'price_cent_kWh'
timestamps = data.('timestamp'); % Or data.timestamp if name was not modified
prices = data.('price(cent/kWh)'); % Or data.price_cent_kWh if modified

% Convert timestamps to a relative time vector (seconds from the start)
time_relative = seconds(datetime(timestamps, 'ConvertFrom', 'posixtime') - datetime(timestamps(1), 'ConvertFrom', 'posixtime'));

% Create a matrix [time, price] for Simulink
simulink_data = [time_relative, prices];

% Optionally, create a timeseries object for flexibility
ts = timeseries(prices, time_relative);

% Save to workspace for Simulink
assignin('base', 'ts_data', ts); % Timeseries format