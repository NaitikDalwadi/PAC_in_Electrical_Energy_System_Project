% Fetch data from Open-Meteo
url = 'https://api.open-meteo.com/v1/forecast?latitude=51.0261&longitude=7.5647&hourly=direct_radiation&models=icon_seamless&forecast_days=1';
data = webread(url);

% Extract and preprocess
times = data.hourly.time;
radiation = data.hourly.direct_radiation;
time_dt = datetime(times, 'InputFormat', 'yyyy-MM-dd''T''HH:mm');
time_seconds = seconds(time_dt - time_dt(1));
radiation = double(radiation);

% Create timeseries for Simulink
ts = timeseries(radiation, time_seconds);

% Save to workspace for Simulink
assignin('base', 'ts_radiation', ts);

% Optional: Plot to verify
plot(time_seconds, radiation);
xlabel('Time (seconds)');
ylabel('Direct Radiation (W/m²)');
title('Solar Radiation Data');