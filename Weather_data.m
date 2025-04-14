% fetchWeather.m
% Fetch weather data and store in workspace
clear;
lat = 40; % Example: New York
lon = -74;
apiKey = '420403061964344e5d10cea9c99de8bd'; % Replace with your key
url = sprintf('https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%s', lat, lon, apiKey);
try
    data = webread(url);
    cloudCover = data.clouds.all; % Percentage
    G = 1000 * (1 - cloudCover/100); % Irradiance in W/m^2
    T = data.main.temp - 273.15; % Temperature in °C
catch
    G = 1000; % Default
    T = 25;
    warning('Weather fetch failed. Using defaults.');
end
% Store in workspace
assignin('base', 'G_weather', G);
assignin('base', 'T_weather', T);