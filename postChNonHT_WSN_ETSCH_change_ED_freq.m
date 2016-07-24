postChNonHT_WSN_ETSCH = [];
err_Tx_E_TSCH = [];
for l = 0 : 20  %number of EDs in each slot
  max_ngb_t_WV2E = [];
for m = 0 : 7  %TS number
  postChNonHT_WSN_ETSCH = [];
  for z = 0 : l
    postChNonHT_WSN_ETSCH = [postChNonHT_WSN_ETSCH;postChNonHT_WSN((1001+60*z+2000*m):(1026+60*z+2000*m),:);];
  end
%[TFR2E,T2E,F2E] = tfrwv(postChNonHT_WSN_ETSCH,1:length(postChNonHT_WSN_ETSCH),length(postChNonHT_WSN_ETSCH),1);
%TFR2E = [];
%for i = 0 : 7
  [TFR2E_2,T2E,F2E] = tfrwv(postChNonHT_WSN_ETSCH((1):((26*(l+1)))),1:length(postChNonHT_WSN_ETSCH((1):((26*(l+1))))),length(postChNonHT_WSN_ETSCH((1):((26*(l+1))))),1);
  %TFR2E = [TFR2E,TFR2E_2];
  %clear TFR2E_2
%end

[r2E,c2E]=size(TFR2E_2);
freq2E = linspace(2.402,2.422,r2E);
for i = 1 : length(freq2E)
    if freq2E(i) >= 2.404
      break
    end
end
for j = i : length(freq2E)
    if freq2E(j) >= 2.406
      break
    end
end
max_ngb_t_WV2E_p = zeros(1,(c2E));
%t_total = 0;
for tm = 1 : (c2E)
    count = 0;
    adjacent = zeros(1,ceil((j-i)));
    %adjacent = zeros(1,ceil((r2E)/2));
    k = 1;
    for fr = i : j % 1722 : 3380
    %for fr = 1 : r2E % 1722 : 3380
        if abs(TFR2E_2(fr,tm)) <= 1e-6 %0.374e-9
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
max_ngb_t_WV2E_p = max_ngb_t_WV2E_p/(j-i);
max_ngb_t_WV2E = [max_ngb_t_WV2E,max_ngb_t_WV2E_p];
%max_ngb_t_WV2E = max_ngb_t_WV2E/(r2E);
end
%figure;
time = ((0:length(postChNonHT_WSN)-1)/fs)*1e5; %length of preChNonHT:1596000 or 19000
x2E = linspace(0,time(length(time)),length(max_ngb_t_WV2E));
%plot(x2E,max_ngb_t_WV2E);
%xlabel ('t [us]');
%ylabel('Probability');
%title ('Time Domain');
xxE = 0:0.01:x2E(length(x2E));
pdfE = spline(x2E,max_ngb_t_WV2E,xxE);
err_Tx_E_TSCH = [err_Tx_E_TSCH;sqrt(immse(pdf_WSN,pdfE))];
end

figure;
x = 1:1:length(err_Tx_E_TSCH);
plot(x,err_Tx_E_TSCH);
xlabel ('number of EDs in each TS');
ylabel('root mean square error');

%Calculate as percentage:
perc_err_ED_freq = [];
for i = 2 : length(err_Tx_E_TSCH)
  perc_err_ED_freq = [perc_err_ED_freq;(((err_Tx_E_TSCH(1) - err_Tx_E_TSCH(i))/err_Tx_E_TSCH(1))*100)];
end
x = 2:1:(length(perc_err_ED_freq)+1);
figure;
plot(x,perc_err_ED_freq);
xlabel ('number of EDs in each TS');
ylabel('% RMSE against E-TSCH');
