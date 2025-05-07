data = readtable('load_profile/Dataset/filtered_dfs/SFH9.xlsx');

time = data.index;  % UNIX timestamps
P = data.P_TOT;     % Active power (P)
Q = data.Q_TOT;     % Reactive power (Q)

time_relative = (time - time(1));  % Convert to hours relative to the first timestamp

PQ = [P, Q];  % 2-column matrix: [P, Q]
PQ_timeseries = timeseries(PQ, time_relative);