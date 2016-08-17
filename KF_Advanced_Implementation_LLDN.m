% Read data from file:
directory='/Users/GKN/Downloads/15.4_RSSI/';
file_name='node1.txt';
fileID=fopen(strcat(directory,file_name),'r');
A=fscanf(fileID,'%f %f',[2000000 1]);
fclose(fileID);

s.x = [1,1,1,1,2,2,2,2,2,1]; %Initialization (first measurement results)
s.A = 1;
s.Q = 0.03^2; % variance, hence stdev^2
s.H = 1;
s.R = 0.06^2; % variance, hence stdev^2
s.B = 0;
s.u = 0;
s.x = nan;
s.P = nan;

LLDN_FULL = [];

for k = 1 : 9195 % Until 330.000
  CISTER_RSSI = [];
  CISTER_RSSI = CISTER_RSSI_250000(((k-1)*500+1):(k*500));
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

%LLDN_FULL_col = LLDN_FULL.'; %convert row to column
%sqrt(immse([s(2:end).x],LLDN_FULL_col))

% difference -> diversion -> take square -> take mean -> take square root -> finally multiply by 100:
perc_err = 100*errperf(LLDN_FULL,KF_out,'rmsre'); %percentage root mean squared relative error
accuracy = 100 - perc_err
