%First calculate the PDF for the continuous case:
[TFR2,T2,F2] = tfrwv(WSN_Ch11_100ms,1:length(WSN_Ch11_100ms),length(WSN_Ch11_100ms),1);
[r2,c2]=size(TFR2);

%TFR2(1,:)=[];
%TFR2(:,1)=[];
%[r2,c2]=size(TFR2);
%TFR2(:,c2)=[];
%TFR2(r2,:)=[];
[r2,c2]=size(TFR2);

freq2 = linspace(2.404,2.406,r2);
max_ngb_t_WV2 = zeros(1,(c2));
%t_total = 0;
for tm = 1 : (c2)
    count = 0;
    %adjacent = zeros(1,ceil((j-i)/2));
    adjacent = zeros(1,ceil((r2)));
    k = 1;
    %for fr = i : j % 1722 : 3380
    for fr = 1 : r2 % 1722 : 3380
        if abs(TFR2(fr,tm)) <= 144
            count = count + 1;
            %t_total = t_total + 1;
        else
            adjacent(1,k) = count;
            k = k + 1;
            count = 0;
        end
    end
    max_ngb_t_WV2(1,(tm)) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_t_WV2(1,tm) = count;
    %end
end
%max_ngb_t_WV2 = max_ngb_t_WV2/t_total;
max_ngb_t_WV2 = max_ngb_t_WV2/(r2);
clear adjacent;
time = ((0:0.02:100-0.02)); %for using RSSI data

figure;
x2 = linspace(0,time(length(time)),length(max_ngb_t_WV2));
plot(x2,max_ngb_t_WV2);
xlabel ('t [ms]');
ylabel('Probability');
%title ('Time Domain');

%Calculate the pdf for continuous case:
figure;
xx_WSN_Ch11_RSSI = 0:1:x2(length(x2));
pdf_WSN_Ch11_RSSI = spline(x2,max_ngb_t_WV2,xx_WSN_Ch11_RSSI);
plot(xx_WSN_Ch11_RSSI,pdf_WSN_Ch11_RSSI);
xlabel ('t [ms]');
ylabel('Probability');

% Now, calculate for the discrete case:
postChNonHT_WSN_ETSCH = [];
err_Tx_E_TSCH = [];
for l = 0 : 20  %number of EDs in each slot
  max_ngb_t_WV2E = [];
for m = 0 : 7  %TS number
  postChNonHT_WSN_ETSCH = [];
  for z = 0 : l
    postChNonHT_WSN_ETSCH = [postChNonHT_WSN_ETSCH;WSN_Ch11_100ms((101+15*z+500*m):(107+15*z+500*m),:);];
  end
%[TFR2E,T2E,F2E] = tfrwv(postChNonHT_WSN_ETSCH,1:length(postChNonHT_WSN_ETSCH),length(postChNonHT_WSN_ETSCH),1);
%TFR2E = [];
%for i = 0 : 7
  [TFR2E_2,T2E,F2E] = tfrwv(postChNonHT_WSN_ETSCH((1):((7*(l+1)))),1:length(postChNonHT_WSN_ETSCH((1):((7*(l+1))))),length(postChNonHT_WSN_ETSCH((1):((7*(l+1))))),1);
  %TFR2E = [TFR2E,TFR2E_2];
  %clear TFR2E_2
%end

[r2E,c2E]=size(TFR2E_2);

TFR2E_2(1,:)=[];
TFR2E_2(:,1)=[];
[r2E,c2E]=size(TFR2E_2);
TFR2E_2(:,c2E)=[];
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
        if abs(TFR2E_2(fr,tm)) <= 144 %0.374e-9
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
end
%figure;
%time = (0:0.02:length(WSN_Ch11_100ms)-1); %length of preChNonHT:1596000 or 19000
x2E = linspace(0,time(length(time)),length(max_ngb_t_WV2E));
%plot(x2E,max_ngb_t_WV2E);
%xlabel ('t [us]');
%ylabel('Probability');
%title ('Time Domain');
xxE = 0:1:x2E(length(x2E));
pdfE = spline(x2E,max_ngb_t_WV2E,xxE);
err_Tx_E_TSCH = [err_Tx_E_TSCH;sqrt(immse(pdf_WSN_Ch11_RSSI,pdfE))];
end

figure;
x = 1:1:length(err_Tx_E_TSCH);
plot(x,err_Tx_E_TSCH);
xlabel ('number of EDs in each TS');
ylabel('root mean square error');

%Calculate as percentage:
perc_err_ED_freq = [];
for i = 2 : length(err_Tx_E_TSCH)
  perc_err_ED_freq = [perc_err_ED_freq;(((err_Tx_E_TSCH(i) - err_Tx_E_TSCH(1))/err_Tx_E_TSCH(1))*100)];
end
figure;
x = 2:1:(length(perc_err_ED_freq)+1);
plot(x,perc_err_ED_freq);
xlabel ('number of EDs in each TS');
ylabel('% RMSE against E-TSCH');
