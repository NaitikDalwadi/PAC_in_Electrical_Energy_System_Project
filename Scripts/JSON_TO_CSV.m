% Extract data
time_seconds = ts_ghi.Time; % Time in seconds since 01-Jan-2020 00:30:00
ghi_data = ts_ghi.Data;     % Irradiance (W/m²)
temp_data = ts_temp.Data;   % Temperature (°C)
pv_power_data = pv_power;   % PV power (W)

% Create a table
data_table = table(time_seconds, ghi_data, temp_data, pv_power_data, ...
    'VariableNames', {'Time_Seconds', 'Irradiance_Wm2', 'Temperature_C', 'PV_Power_W'});

% Write to CSV
writetable(data_table, 'pvgis_data_2020.csv');
disp('Saved PVGIS data to pvgis_data_2020.csv');