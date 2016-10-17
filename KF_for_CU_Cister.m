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

% plot accuracy for CU:
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


% plot accuracy for CISTER:
figure
x = 1.1 : 0.1 : 1.9;
subplot(2,1,1)
accuracy_array = [66.5880;66.7800;67.2440;67.3880;66.8480;65.6820;64.7620;64.4800;64.3680];
bkf_acc_conf_lower = [65.2350;65.4114;65.8728;66.0047;65.4118;64.1381;63.1450;62.8449;62.7275];
bkf_acc_conf_upper = [67.9410;68.1486;68.6152;68.7713;68.2842;67.2259;66.3790;66.1151;66.0085];
bkf_conf = bkf_acc_conf_upper - accuracy_array;
plot(x,accuracy_array);
errorbar(x,accuracy_array,bkf_conf);
grid on
hold on
trad_KF_acc=[66.5040;66.5040;66.5040;66.5040;66.5040;66.5040;66.5040;66.5040;66.5040];
kf_acc_conf_lower = [65.1625;65.1625;65.1625;65.1625;65.1625;65.1625;65.1625;65.1625;65.1625];
kf_acc_conf_upper = [67.8455;67.8455;67.8455;67.8455;67.8455;67.8455;67.8455;67.8455;67.8455];
kf_conf = kf_acc_conf_upper - trad_KF_acc;
plot(x,trad_KF_acc);
errorbar(x,trad_KF_acc,kf_conf);
hold on
com_accuracy_array=[66.5840;66.6240;66.8020;66.8460;66.4280;65.4440;64.7060;64.4600;64.3700];
com_acc_conf_lower = [65.1891;65.2256;65.4012;65.4344;64.9691;63.8837;63.0777;62.8140;62.7184];
com_acc_conf_upper = [67.9789;68.0224;68.2028;68.2576;67.8869;67.0043;66.3343;66.1060;66.0216];
com_conf = com_acc_conf_upper - com_accuracy_array;
plot(x,com_accuracy_array);
errorbar(x,com_accuracy_array,com_conf);
title('KF-ES Combined Accuracy');
xlabel ('mean (up to)');
ylabel('% Accuracy');
subplot(2,1,2)
false_positive_array = [16.5380;16.0000;14.9100;13.1300;9.9080;7.1580;5.6700;5.1620;5.0280];
bkf_fp_conf_upper = [17.2402;16.7299;15.6528;13.8809;10.6105;7.6912;6.0339;5.4545;5.3006];
bkf_fp_conf = bkf_fp_conf_upper - false_positive_array;
plot(x,false_positive_array);
errorbar(x,false_positive_array,bkf_fp_conf);
grid on
hold on
trad_KF_fp = [16.6940;16.6940;16.6940;16.6940;16.6940;16.6940;16.6940;16.6940;16.6940];
trad_fp_conf_upper = [17.3814;17.3814;17.3814;17.3814;17.3814;17.3814;17.3814;17.3814;17.3814];
trad_fp_conf = trad_fp_conf_upper - trad_KF_fp;
plot(x,trad_KF_fp);
errorbar(x,trad_KF_fp,trad_fp_conf);
hold on
com_false_positive_array = [12.1620;12.0680;11.6760;10.7940;8.6880;6.4820;5.2180;4.4180;4.7080];
com_fp_conf_upper = [12.8195;12.7312;12.3467;11.4747;9.3374;6.9871;5.5737;5.1139;4.9867];
com_fp_conf = com_fp_conf_upper - com_false_positive_array;
plot(x,com_false_positive_array);
errorbar(x,com_false_positive_array,com_fp_conf);
xlabel ('mean (up to)');
ylabel('% False Positivity');
title('KF-ES Combined False Positivity');

%To calculate confidence interval:

%x = accuracy;                      % Change this accordingly
%SEM = std(x)/sqrt(length(x));               % Standard Error
%ts = tinv([0.025  0.975],length(x)-1);      % T-Score
%CI = mean(x) + ts*SEM;                      % Confidence Intervals
