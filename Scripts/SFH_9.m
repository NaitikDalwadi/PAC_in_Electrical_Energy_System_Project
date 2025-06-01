data = readtable('D:/Study/Masters in Automation and IT/Semester 2/PAC in Electrical Energy System/Assignment/load_profile/Dataset/Dynamic_P_Q_15_min_No_PV/SFH9.xlsx');

time = data.index;  % UNIX timestamps
P1 = data.P_TOT;
Q1 = data.Q_TOT;
time_relative = (time - time(1));  % Convert to hours relative to the first timestamp

dyn_load = [P1,Q1];
load_timeseries = timeseries(dyn_load, time_relative);