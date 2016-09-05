fid = fopen('/Users/GKN/Downloads/CU_RSSI/omni_16dbm.txt', 'r');
A = textscan(fid, '%f %f %s %s %d %d %d %d %d %d %d');
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

accuracy_array = [];
false_positive_array = [];
fp_index = [];
%for st_transition = 0.95 : 0.001 : 1.05

  clear s
  KF_out = [];

  s.A = 1;
  s.Q = 0.000000000000000000000000000001;
  s.H = 1;
  s.R = 0.000000000000000000000000000001;
  s.B = 0;
  s.u = 0;
  s.x = nan;
  s.P = nan;

for i = 1 : floor(length(CU_RSSI)/10)

    s(end).z = CU_RSSI( ((i-1)*10+1) : (10*i) ); % create a measurement
    s(end+1) = kalmanf(s(end)); % perform a Kalman filter iteration

end

KF_out = round([s(2:end).x]);
for i = 1 : length(KF_out)
  if KF_out(i) == 0
    KF_out(i) = 1;
  end
end

count = 0;
for i = 1 : (length(KF_out)-20)
  if KF_out(i) == CU_RSSI(i+10)
    count = count + 1;
  end
end
accuracy = 100*(count/(length(KF_out)-20));

count = 0;
for i = 1 : (length(KF_out)-20)
  if (KF_out(i) == CU_RSSI(i+10)) && (KF_out(i) == 2)
    count = count + 1;
  end
end
throughput_util = 100*(count/(length(KF_out)-20));

count = 0;
for i = 1 : (length(KF_out)-20)
  if (KF_out(i) == 2) && (CU_RSSI(i+10) == 1)
    count = count + 1;
    fp_index = [fp_index,i];
  end
end
false_positive = 100*(count/(length(KF_out)-20));

count = 0;
for i = 1 : (length(KF_out)-20)
  if CU_RSSI(i+10) == 2
    count = count + 1;
  end
end
max_throughput_util = 100*(count/(length(KF_out)-20));

% Combine KF and ES to reduce false positives
KF_ES = ones(1,length(KF_out));
count = 0;
for i = 1 : (length(KF_out)-20)
  if (KF_out(i) == 2) && (ES_estimation(i) == 2)
    KF_ES(i) = 2;
  end
  if (KF_ES(i) == 2) && (CU_RSSI(i+10) == 1)
    count = count + 1;
  end
end
KF_ES_false_positive = 100*(count/(length(KF_out)-20));

count = 0;
for i = 1 : (length(KF_out)-20)
  if (KF_ES(i) == CU_RSSI(i+10)) && (KF_ES(i) == 2)
    count = count + 1;
  end
end
KF_ES_throughput_util = 100*(count/(length(KF_out)-20));

count = 0;
for i = 1 : (length(KF_out)-20)
  if KF_ES(i) == CU_RSSI(i+10)
    count = count + 1;
  end
end
KF_ES_accuracy = 100*(count/(length(KF_out)-20));

%accuracy_array = [accuracy_array;accuracy];
%false_positive_array = [false_positive_array;false_positive];

%end %st_transition

% plot accuracy:
figure
x = 1.1 : 0.1 : 1.9;
subplot(2,1,1)
accuracy_array = [93.9443;94.1190;94.2143;94.2573;94.2795;94.2809;94.2565;94.1345;93.0950];
plot(x,accuracy_array);
grid on
hold on
trad_KF_acc=[93.4712;93.4712;93.4712;93.4712;93.4712;93.4712;93.4712;93.4712;93.4712];
plot(x,trad_KF_acc);
hold on
com_accuracy_array=[93.8849;93.9161;93.9301;93.9251;93.9216;93.9155;93.8855;93.8019;92.9537];
plot(x,com_accuracy_array);
title('KF-ES Combined Accuracy');
xlabel ('mean (up to)');
ylabel('% Accuracy');
subplot(2,1,2)
false_positive_array=[2.7543;2.5181;2.3382;2.1868;2.0281;1.8647;1.6813;1.4472;0.8671];
plot(x,false_positive_array);
grid on
hold on
trad_KF_fp=[3.2644;3.2644;3.2644;3.2644;3.2644;3.2644;3.2644;3.2644;3.2644];
plot(x,trad_KF_fp);
hold on
com_false_positive_array=[1.7188;1.6717;1.6300;1.5855;1.5214;1.4571;1.3790;1.2556;0.8179];
plot(x,com_false_positive_array);
xlabel ('mean (up to)');
ylabel('% False Positivity');
title('KF-ES Combined False Positivity');
