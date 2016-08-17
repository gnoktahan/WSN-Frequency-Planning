% Read data from file:
%{
directory='/Users/GKN/Downloads/15.4_RSSI/';
file_name='node1.txt';
fileID=fopen(strcat(directory,file_name),'r');
A=fscanf(fileID,'%f %f',[2000000 1]);
fclose(fileID);
%}

CISTER_RSSI_5600_500 = zeros(5600,500);
for i = 1 : 500
  CISTER_RSSI_5600_500(:,i) = CISTER_RSSI_250000(((i-1)*5600+1):(i*5600));
end

accuracy = zeros(500,1);
throughput_util = zeros(500,1);

for scan = 1 : 500

  clear s

  CISTER_RSSI = [];
  CISTER_RSSI = CISTER_RSSI_5600_500((1:500),scan);
  RSSI_LLDN = [];
  LLDN_SF = ones(1,10);
  for i = 0 : 9 % 10 time slots
    RSSI_LLDN = CISTER_RSSI(50*i+13 : 50*i+37);
    if mean(RSSI_LLDN) < 14
      LLDN_SF(i+1) = 2; % 2 means free 1 means occupied (interfered)
    end
  end

  %s.x = [1,1,1,1,2,2,2,2,2,1]; %Initialization (first measurement results)
  s.x = LLDN_SF; %Initialization (first measurement results)
  s.A = 1;
  s.Q = 0.03^2; % variance, hence stdev^2
  s.H = 1;
  s.R = 0.06^2; % variance, hence stdev^2
  s.B = 0;
  s.u = 0;
  s.x = nan;
  s.P = nan;

  LLDN_FULL = [];

for k = 1 : 11 % Until 5500
  CISTER_RSSI = [];
  CISTER_RSSI = CISTER_RSSI_5600_500((((k-1)*500+1):(k*500)),scan);
  RSSI_LLDN = [];
  RSSI_LLDN_FULL = [];
  LLDN_SF = ones(1,10);
  LLDN_SF_FULL = ones(1,10);
  for i = 0 : 9 % 10 time slots
    RSSI_LLDN = CISTER_RSSI(50*i+13 : 50*i+37);
    RSSI_LLDN_FULL = CISTER_RSSI(50*i+1 : 50*(i+1));
    if mean(RSSI_LLDN) < 14
      LLDN_SF(i+1) = 2; % 2 means free 1 means occupied (interfered)
    end
    if mean(RSSI_LLDN_FULL) < 14
      LLDN_SF_FULL(i+1) = 2; % 2 means free 1 means occupied (interfered)
    end
  end

  LLDN_FULL = [LLDN_FULL,LLDN_SF_FULL(1:10)];
  %for t = 0 : 499
    s(end).z = LLDN_SF(1:10); % create a measurement
    s(end+1)=kalmanf(s(end)); % perform a Kalman filter iteration
  %end
end

KF_out = round([s(2:end).x]);


% plot it:
%{
figure
hold on
grid on
% plot measurement data:
hz=plot([s(1:end-1).z],'r.');
% plot a-posteriori state estimates:
hk=plot(KF_out,'b-');
ht=plot(LLDN_FULL,'g-');
legend([hz hk ht],'observations','Kalman output','true RSSI')
title('Channel RSSI Estimation with Kalman Filter')
hold off
%}


%LLDN_FULL_col = LLDN_FULL.'; %convert row to column
%sqrt(immse([s(2:end).x],LLDN_FULL_col))

% difference -> diversion -> take square -> take mean -> take square root -> finally multiply by 100:
%perc_err = 100*errperf(LLDN_FULL,KF_out,'rmsre'); %percentage root mean squared relative error
%accuracy(scan,1) = 100 - perc_err;

count = 0;
for i = 1 : length(KF_out)
  if KF_out(i) == LLDN_FULL(i)
    count = count + 1;
  end
end
accuracy(scan,1) = 100*(count/length(KF_out));

count = 0;
for i = 1 : length(KF_out)
  if KF_out(i) == LLDN_FULL(i) && KF_out(i) == 2
    count = count + 1;
  end
end
throughput_util(scan,1) = 100*(count/length(KF_out));

end

% plot accuracy pdf:
figure
grid on
plot(accuracy);
title('KF Accuracy PDF');
xlabel ('Dataset');
ylabel('% Accuracy');

% plot throughput_util pdf:
figure
grid on
plot(throughput_util);
title('KF Throughput Gain PDF');
xlabel ('Dataset');
ylabel('% Estimation Accuracy of Clean Channels');
