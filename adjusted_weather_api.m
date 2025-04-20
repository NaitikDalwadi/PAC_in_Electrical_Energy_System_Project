% Fetch data from Open-Meteo
url = 'https://api.open-meteo.com/v1/forecast?latitude=51.0261&longitude=7.5647&hourly=global_tilted_irradiance&models=icon_seamless&forecast_days=1&tilt=43';
data = webread(url);

% Extract data
times = data.hourly.time;
gti = data.hourly.global_tilted_irradiance; % W/m², already adjusted for tilt and azimuth
time_dt = datetime(times, 'InputFormat', 'yyyy-MM-dd''T''HH:mm');
time_seconds = seconds(time_dt - time_dt(1));
gti = double(gti); % Ensure double format

% Create timeseries
ts_gti = timeseries(gti, time_seconds);
assignin('base', 'ts_gti', ts_gti);

% Optional: Plot to verify
plot(time_seconds, gti);
xlabel('Time (seconds)');
ylabel('Global Tilted Irradiance (W/m²)');
title('Solar Radiation Data');