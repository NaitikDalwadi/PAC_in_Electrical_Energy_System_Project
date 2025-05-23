data = readtable('D:/Study/Masters in Automation and IT/Semester 2/PAC in Electrical Energy System/Assignment/load_profile/Dataset/Dynamic_R_X_15_min_No_PV/SFH9.xlsx');

time = data.index;  % UNIX timestamps
R1 = data.R1;
R2 = data.R2;
R3 = data.R3;
X1 = data.X1;
X2 = data.X2;
X3 = data.X3;

time_relative = (time - time(1));  % Convert to hours relative to the first timestamp

dyn_load = [R1,R2,R3,X1,X2,X3];
load_timeseries = timeseries(dyn_load, time_relative);