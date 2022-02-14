% OPTIMAL PMU PLACEMENT BY LINEAR INTEGER PROGRAMMING
clear;
clc;

%% loading system data
sysdata = input('Enter system data case: ');
busdata = sysdata.bus;

branchdata = sysdata.branch;
frombus = branchdata(:,1);
tobus = branchdata(:,2);

Bus_injection_data = input('Enter bus injecton data: ');

% Flow measurement data will be taken from the All_flow_data based on user
% input corresponding to row in All_flow_data
ALL_flow_data = branchdata(:,1:2);
flow_data_num = input('Enter flow measurement data: ');
tic
flow_data=zeros(size(flow_data_num,1),2);
for i=1:size(flow_data_num,1)
    flow_data(i,:) = ALL_flow_data(flow_data_num(i),:);
end

%Number of buses in system
n = size(busdata,1);

%% T_PMU matrix
T_PMU=eye(n,n);
m = size(frombus);
for i = 1:m
    T_PMU(frombus(i),tobus(i))=1;
    T_PMU(tobus(i),frombus(i))=1;
end

flow_data_size = size(flow_data,1);
Bus_injection_data_size = size(Bus_injection_data,1);
observable_buses = zeros(n,1);
%% Buses observable due to bus injections
for j = 1:Bus_injection_data_size
    observable_buses(Bus_injection_data(j))=1;
    for i = 1:m
        if frombus(i)==Bus_injection_data(j)
            observable_buses(tobus(i))=1;
        end
        if tobus(i)==Bus_injection_data(j)
            observable_buses(frombus(i))=1;
        end
    end
end
% Buses observable due to flow measurements
for j = 1:flow_data_size
    observable_buses(flow_data(j,1))=1;
    observable_buses(flow_data(j,2))=1;
end
num_observable_buses = sum(observable_buses)
num_non_observable_buses = n-num_observable_buses;
observable_bus = find(observable_buses==1)'
non_observable_bus = find(observable_buses~=1)'

%% T_measurement matrix
T_measurement = zeros(flow_data_size(1)+Bus_injection_data_size(1),num_observable_buses);
T_measurement_size = size(T_measurement,1);
%T_measurement due to flow data
for j = 1:flow_data_size
    T_measurement(j,flow_data(j,1))=1;
    T_measurement(j,flow_data(j,2))=1;
end

T_measurement;
%T_measurement due to bus injections
for j = 1:Bus_injection_data_size
    k = flow_data_size+j;
    T_measurement(k,Bus_injection_data(j))=1;
    for i = 1:m
        if frombus(i)==Bus_injection_data(j)
            T_measurement(k,tobus(i))=1;
        end
        if tobus(i)==Bus_injection_data(j)
            T_measurement(k,frombus(i))=1;
        end
    end
end
T_measurement;
% removing columns with only zero entries
T_measurement( :, all(~T_measurement,1) ) = []
row_size_Tm = size(T_measurement,1);
col_size_Tm = size(T_measurement,2);

% removing buses that are already observable in T_measurement
for j=1:col_size_Tm
    for i=1:row_size_Tm
        if T_measurement(i,j)==1
            for k = i+1:row_size_Tm
                T_measurement(k,j)=0;
            end
        end
    end
end
T_measurement

%% Tcon
Identity_matrix = eye(num_non_observable_buses);
Tcon=[Identity_matrix             zeros(num_non_observable_buses,num_observable_buses);
    zeros(T_measurement_size,num_non_observable_buses)               T_measurement];
Tcon_size = size(Tcon,1);

%% Permutation Matrix
P = zeros(n,n);
for i=1:num_non_observable_buses
    P(i ,non_observable_bus(i))=1;
end

for i=1:num_observable_buses
    P(num_non_observable_buses+i,observable_bus(i))=1 ;
end
P;

%% B_con
B_con = ones(Tcon_size,1);
for i=1:T_measurement_size
    B_con(num_non_observable_buses+i,1) = sum(T_measurement(i,:))-1;
end
X = ones(n,1);
%% Optimizing PMU placements
A = -Tcon*P*T_PMU;
b = -B_con;
intcon = [1:n];
lb = zeros(n,1);
ub = ones(n,1);
f = X;
X = intlinprog(f,intcon,A,b,[],[],lb,ub);
X=round(X)'
total_PMUs = sum(X)
PMUs_at_buses = find(X==1)

toc % calculating total program executiom time