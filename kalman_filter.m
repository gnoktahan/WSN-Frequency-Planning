RSSI = WSN_Ch11_100ms - 45;
s.x = mean(RSSI);
s.A = 1;
s.Q = 3^2; % variance, hence stdev^2
s.H = 1;
s.R = 6^2; % variance, hence stdev^2
s.B = 0;
s.u = 0;
s.x = nan;
s.P = nan;

for t = 1 : 5000
   s(end).z = RSSI(t); % create a measurement
   s(end+1)=kalmanf(s(end)); % perform a Kalman filter iteration
end

figure
hold on
grid on
% plot measurement data:
hz=plot([s(1:end-1).z],'r.');
% plot a-posteriori state estimates:
hk=plot([s(2:end).x],'b-');
ht=plot(RSSI,'g-');
legend([hz hk ht],'observations','Kalman output','true RSSI')
title('Channel RSSI Estimation with Kalman Filter')
hold off

%RSSI_col = RSSI.'; %convert row to column
%sqrt(immse([s(2:end).x],RSSI_col))

% difference -> diversion -> take square -> take mean -> take square root -> finally multiply by 100:
perc_err = 100*errperf(RSSI_col,[s(2:end).x],'rmsre'); %percentage root mean squared relative error
