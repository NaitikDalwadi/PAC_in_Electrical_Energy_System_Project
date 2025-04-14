% Fetch PVGIS data for New York (lat: 40.7128, lon: -74.0060)
[ts_ghi, ts_temp, pv_power] = getPVGISData(40.7128, -74.0060, 2020, 4, 14, 40, 180);
save('pvgis_data.mat', 'ts_ghi', 'ts_temp', 'pv_power');