CISTER_RSSI_5600_500 = zeros(5600,500);
for i = 1 : 500
  CISTER_RSSI_5600_500(:,i) = CISTER_RSSI_250000(((i-1)*5600+1):(i*5600));
end

ES_estimation_big = [];
accuracy = zeros(500,1);
throughput_util = zeros(500,1);

for scan = 1 : 500

  CISTER_RSSI = [];
  CISTER_RSSI = CISTER_RSSI_5600_500((1:500),scan); % first 10ms for initialization
  RSSI_LLDN = [];
  LLDN_SF = ones(1,10);
  for i = 0 : 9 % 10 time slots
    RSSI_LLDN = CISTER_RSSI(50*i+1 : 50*(i+1)); % measurement
    %%RSSI_LLDN = CISTER_RSSI(50*i+13 : 50*i+37); % measurement
    if mean(RSSI_LLDN) < 13
      LLDN_SF(i+1) = 2; % 2 means free 1 means occupied (interfered)
      %%LLDN_SF(i+1) = mean(RSSI_LLDN);
    end
  end

alpha = 0.32;
ES_estimation = [];
P_new = [];
P_measured = [];
P_previous = [];
P_measured = LLDN_SF;
P_previous = LLDN_SF;

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
  %%RSSI_LLDN = CISTER_RSSI(50*i+20 : 50*i+((optimum_ED_width_matrix(k,scan)/0.02)-1+13)); % if ED optimization is applied
  RSSI_LLDN_FULL = CISTER_RSSI(50*i+1 : 50*(i+1));
  if mean(RSSI_LLDN) < 13
    LLDN_SF(i+1) = 2; % 2 means free 1 means occupied (interfered)
    %%LLDN_SF(i+1) = mean(RSSI_LLDN);
  end
  if mean(RSSI_LLDN_FULL) < 13
    LLDN_SF_FULL(i+1) = 2; % 2 means free 1 means occupied (interfered)
    %%LLDN_SF_FULL(i+1) = mean(RSSI_LLDN_FULL);
  end
end

LLDN_FULL = [LLDN_FULL,LLDN_SF_FULL];

%Exponential Smoothing algorithm:
P_measured = LLDN_SF_FULL;
%%P_measured = LLDN_SF;
P_new = alpha*P_measured + (1-alpha)*P_previous;
%%P_previous = round(P_new);
P_previous = P_new;
ES_estimation = [ES_estimation,round(P_new)];
%%output = smoothts(P_measured, 'e', 0.2); %calculates slot by slot not frame by frame
%%ES_estimation = [ES_estimation,P_new];

end
ES_estimation_big = [ES_estimation_big;ES_estimation];
%{
for i = 1 : length(ES_estimation)
  if ES_estimation(i) < 13
    ES_estimation(i) = 2; % 2 means free 1 means occupied (interfered)
  else
    ES_estimation(i) = 1;
  end
end
for i = 1 : length(LLDN_FULL)
  if LLDN_FULL(i) < 13
    LLDN_FULL(i) = 2; % 2 means free 1 means occupied (interfered)
  else
    LLDN_FULL(i) = 1;
  end
end
%}

count = 0;
for i = 1 : (length(ES_estimation) - 10)
  if ES_estimation(i) == LLDN_FULL(i+10)
    count = count + 1;
  end
end
accuracy(scan,1) = 100*(count/(length(ES_estimation) - 10));

count = 0;
for i = 1 : (length(ES_estimation) - 10)
  if (ES_estimation(i) == LLDN_FULL(i+10)) && (ES_estimation(i) == 2)
    count = count + 1;
  end
end
throughput_util(scan,1) = 100*(count/(length(ES_estimation) - 10));

count = 0;
for i = 1 : (length(ES_estimation) - 10)
  if (ES_estimation(i) == 2) && (LLDN_FULL(i+10) == 1)
    count = count + 1;
  end
end
false_positive(scan,1) = 100*(count/(length(ES_estimation) - 10));

count = 0;
for i = 1 : (length(ES_estimation) - 10)
  if LLDN_FULL(i+10) == 2
    count = count + 1;
  end
end
max_throughput_util(scan,1) = 100*(count/(length(ES_estimation) - 10));

end

mean_accuracy = mean(accuracy);
mean_false_positive = mean(false_positive);
mean_throughput_util = mean(throughput_util);
mean_max_throughput_util = mean(max_throughput_util);

% plot accuracy pdf:
figure
plot(accuracy);
grid on
title('ES Accuracy PDF');
xlabel ('Dataset');
ylabel('% Accuracy');

% plot throughput_util pdf:
figure
plot(throughput_util);
grid on
title('ES Throughput Gain PDF');
xlabel ('Dataset');
ylabel('% Estimation Accuracy of Clean Channels');
