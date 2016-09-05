fid = fopen('/Users/GKN/Downloads/CU_RSSI/omni_16dbm.txt', 'r');
A = textscan(fid, '%f %f %s %s %f %f %f %f %f %f %f');
CU_RSSI=A{1,9};
CU_RSSI = CU_RSSI.'; %convert column vector to row vector
clear A;

  for i = 1 : length(CU_RSSI)
    if CU_RSSI(i) <= -65
      CU_RSSI(i) = 2; % 2 means free 1 means occupied (interfered)
    else
      CU_RSSI(i) = 1; % 2 means free 1 means occupied (interfered)
    end
  end

%accuracy_array = [];
%false_positive_array = [];
%for var_alpha = 0.1 : 0.05 : 1
alpha = 0.25;
ES_estimation = [];
P_new = [];
P_measured = [];
P_previous = [];
P_previous = CU_RSSI( 1 : 10 );

for i = 1 : floor(length(CU_RSSI)/10)

  %Exponential Smoothing algorithm:
  P_measured = CU_RSSI(((i-1)*10+1) : (10*i));
  P_new = alpha*P_measured + (1-alpha)*P_previous;
  P_previous = P_new;
  ES_estimation = [ES_estimation,round(P_new)];

end

count = 0;
for i = 1 : length(ES_estimation)-20
  if ES_estimation(i) == CU_RSSI(i+10)
    count = count + 1;
  end
end
accuracy = 100*(count/(length(ES_estimation)-20));

count = 0;
for i = 1 : length(ES_estimation)-20
  if ES_estimation(i) == CU_RSSI(i+10) && ES_estimation(i) == 2
    count = count + 1;
  end
end
throughput_util = 100*(count/(length(ES_estimation)-20));

count = 0;
for i = 1 : length(ES_estimation)-20
  if (ES_estimation(i) == 2) && (CU_RSSI(i+10) == 1)
    count = count + 1;
  end
end
false_positive = 100*(count/(length(ES_estimation)-20));

count = 0;
for i = 1 : length(ES_estimation)-20
  if CU_RSSI(i+10) == 2
    count = count + 1;
  end
end
max_throughput_util = 100*(count/(length(ES_estimation)-20));

%accuracy_array = [accuracy_array;accuracy];
%false_positive_array = [false_positive_array;false_positive];

%end % var_alpha
