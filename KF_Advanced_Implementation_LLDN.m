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

% Determine optimum ED freq and width using Wigner-Ville:  ---------------------------------------------------------
optimum_ED_freq_array = [];
optimum_ED_width_array = [];
for opt = 1 : 500
CISTER_RSSI = [];
CISTER_RSSI = CISTER_RSSI_5600_500((1:500),opt); % first 10ms for initialization

time = ((0:0.02:10-0.02)); %for using RSSI data
postChNonHT_WSN_ETSCH = [];
err_Tx_E_TSCH_widthANDfreq = zeros(2,11);

[TFR_FULL,T2E_FULL,F2E_FULL] = tfrwv(CISTER_RSSI,1:length(CISTER_RSSI),length(CISTER_RSSI)); % Full data continuous
[r2E_FULL,c2E_FULL]=size(TFR_FULL);
max_ngb_t_WV2E_FULL = zeros(1,(c2E_FULL));
%t_total = 0;
for tm = 1 : (c2E_FULL)
    count = 0;
    %adjacent = zeros(1,ceil((j-i)));
    adjacent = zeros(1,ceil((r2E_FULL)));
    k = 1;
    %for fr = i : j % 1722 : 3380
    for fr = 1 : r2E_FULL % 1722 : 3380
        if abs(TFR_FULL(fr,tm)) <= 196
            count = count + 1;
            %t_total = t_total + 1;
        else
            adjacent(1,k) = count;
            k = k + 1;
            count = 0;
        end
    end
    max_ngb_t_WV2E_FULL(1,(tm)) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_t_WV2(1,tm) = count;
    %end
end
clear adjacent;
%max_ngb_t_WV2 = max_ngb_t_WV2/t_total;
max_ngb_t_WV2E_FULL = max_ngb_t_WV2E_FULL/(r2E_FULL);
x2E_FULL = linspace(0,time(length(time)),length(max_ngb_t_WV2E_FULL));
xxE_FULL = 0:0.02:x2E_FULL(length(x2E_FULL));
pdf_WSN_Ch11_RSSI = spline(x2E_FULL,max_ngb_t_WV2E_FULL,xxE_FULL);





for w = 0 : 10 %ED width
  err_Tx_E_TSCH_width = [];
for l = 0 : 1 %number of EDs in each slot
  max_ngb_t_WV2E = [];
for m = 0 : 9 %TS number
  postChNonHT_WSN_ETSCH = [];
  for z = 0 : l
    postChNonHT_WSN_ETSCH = [postChNonHT_WSN_ETSCH;CISTER_RSSI((1+15*z+50*m):(7+w+15*z+50*m),:);];
  end

  [TFR2E_2,T2E,F2E] = tfrwv(postChNonHT_WSN_ETSCH((1):(((7+w)*(l+1)))),1:length(postChNonHT_WSN_ETSCH((1):(((7+w)*(l+1))))),length(postChNonHT_WSN_ETSCH((1):(((7+w)*(l+1))))),1); % Pseudo info discont.

[r2E,c2E]=size(TFR2E_2);
freq2E = linspace(2.404,2.406,r2E);
max_ngb_t_WV2E_p = zeros(1,(c2E));
%t_total = 0;
for tm = 1 : (c2E)
    count = 0;
    %adjacent = zeros(1,ceil((j-i)));
    adjacent = zeros(1,ceil((r2E)));
    k = 1;
    %for fr = i : j % 1722 : 3380
    for fr = 1 : r2E % 1722 : 3380
        if abs(TFR2E_2(fr,tm)) <= 196
            count = count + 1;
            %t_total = t_total + 1;
        else
            adjacent(1,k) = count;
            k = k + 1;
            count = 0;
        end
    end
    max_ngb_t_WV2E_p(1,(tm)) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_t_WV2(1,tm) = count;
    %end
end
clear adjacent;
%max_ngb_t_WV2 = max_ngb_t_WV2/t_total;
max_ngb_t_WV2E_p = max_ngb_t_WV2E_p/(r2E);
max_ngb_t_WV2E = [max_ngb_t_WV2E,max_ngb_t_WV2E_p];
%max_ngb_t_WV2E = max_ngb_t_WV2E/(r2E);
end % m
x2E = linspace(0,time(length(time)),length(max_ngb_t_WV2E));
xxE = 0:0.02:x2E(length(x2E));
pdfE = spline(x2E,max_ngb_t_WV2E,xxE);
err_Tx_E_TSCH_width = [err_Tx_E_TSCH_width;sqrt(immse(pdf_WSN_Ch11_RSSI,pdfE))];
end % l
  err_Tx_E_TSCH_widthANDfreq(:,w+1) = 1-err_Tx_E_TSCH_width;
  err_Tx_E_TSCH_widthANDfreq(1,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(1,w+1).*(1-0.02*(7+w)*1);
  err_Tx_E_TSCH_widthANDfreq(2,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(2,w+1).*(1-0.02*(7+w)*2);
  %err_Tx_E_TSCH_widthANDfreq(3,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(3,w+1).*(1-0.02*(7+w)*3);
  %err_Tx_E_TSCH_widthANDfreq(4,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(4,w+1).*(1-0.02*(7+w)*4);
  %err_Tx_E_TSCH_widthANDfreq(5,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(5,w+1).*(1-0.02*(7+w)*5);
end % w
optimum=min(min(err_Tx_E_TSCH_widthANDfreq));
for i = 1 : length(err_Tx_E_TSCH_widthANDfreq(1,:))
  for j = 1 : length(err_Tx_E_TSCH_widthANDfreq(:,1))
    if err_Tx_E_TSCH_widthANDfreq(j,i) == optimum
      optimum_ED_freq = j;
      optimum_ED_width = 0.14+0.02*(i-1);
    end
  end
end
optimum_ED_freq_array = [optimum_ED_freq_array;optimum_ED_freq];
optimum_ED_width_array = [optimum_ED_width_array;optimum_ED_width];
end % opt
%---------------------------------------------------------------------------------------------

for scan = 1 : 500

  clear s

  CISTER_RSSI = [];
  CISTER_RSSI = CISTER_RSSI_5600_500((1:500),scan); % first 10ms for initialization
  RSSI_LLDN = [];
  LLDN_SF = ones(1,10);
  for i = 0 : 9 % 10 time slots
    RSSI_LLDN = CISTER_RSSI(50*i+13 : 50*i+37); % measurement
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
    RSSI_LLDN = CISTER_RSSI(50*i+13 : 50*i+37); % if ED optimization is not applied
    %RSSI_LLDN = CISTER_RSSI(50*i+20 : 50*i+((optimum_ED_width_array(scan)/0.02)-1+13)); % if ED optimization is applied
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
