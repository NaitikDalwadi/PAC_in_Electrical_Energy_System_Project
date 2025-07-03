% Extract data from timeseries objects
if exist('PV_Generation', 'var') && isa(PV_Generation, 'timeseries')
    pv_time = PV_Generation.Time;
    pv_data = PV_Generation.Data;
    disp('PV_Generation size:'); disp(size(pv_data));
else
    disp('PV_Generation not found or not a timeseries');
end
if exist('Load_Consumption', 'var') && isa(Load_Consumption, 'timeseries')
    load_time = Load_Consumption.Time;
    load_data = Load_Consumption.Data;
    disp('Load_Consumption size:'); disp(size(load_data));
else
    disp('Load_Consumption not found or not a timeseries');
end
if exist('SOC', 'var') && isa(SOC, 'timeseries')
    soc_time = SOC.Time;
    soc_data = SOC.Data;
    disp('SOC size:'); disp(size(soc_data));
else
    disp('SOC not found or not a timeseries');
end
if exist('I_soc', 'var') && isa(I_soc, 'timeseries')
    I_soc_time = I_soc.Time;
    I_soc_data = I_soc.Data;
    disp('SOC size:'); disp(size(I_soc_data));
else
    disp('SOC not found or not a timeseries');
end

% Export each timeseries to a separate file
if exist('I_soc_data', 'var')
    % Resample SOC
    common_time_soc = I_soc_time; % Use its own time vector
    soc_resampled = resample(I_soc, common_time_soc).Data;
    data_table_soc = table(common_time_soc, soc_resampled, ...
        'VariableNames', {'Time', 'I_soc'});
    writetable(data_table_soc, 'C:\Users\DELL\OneDrive\Desktop\I_soc.xlsx');
    disp('I_SOC exported');
end
if exist('pv_data', 'var')
    % Resample PV_Generation
    common_time_pv = pv_time; % Use its own time vector
    pv_resampled = resample(PV_Generation, common_time_pv).Data;
    data_table_pv = table(common_time_pv, pv_resampled, ...
        'VariableNames', {'Time', 'P_pv'});
    writetable(data_table_pv, 'C:\Users\DELL\OneDrive\Desktop\PV_Generation.xlsx');
    disp('PV_Generation exported');
end
if exist('load_data', 'var')
    % Resample Load_Consumption
    common_time_load = load_time; % Use its own time vector
    load_resampled = resample(Load_Consumption, common_time_load).Data;
    data_table_load = table(common_time_load, load_resampled, ...
        'VariableNames', {'Time', 'P_load'});
    writetable(data_table_load, 'C:\Users\DELL\OneDrive\Desktop\Load_Consumption.xlsx');
    disp('Load_Consumption exported');
end
if exist('soc_data', 'var')
    % Resample SOC
    common_time_soc = soc_time; % Use its own time vector
    soc_resampled = resample(SOC, common_time_soc).Data;
    data_table_soc = table(common_time_soc, soc_resampled, ...
        'VariableNames', {'Time', 'SOC'});
    writetable(data_table_soc, 'C:\Users\DELL\OneDrive\Desktop\SOC.xlsx');
    disp('SOC exported');
end
