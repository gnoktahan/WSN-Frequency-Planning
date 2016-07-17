time = ((0:0.02:100-0.02)); %for using RSSI data
postChNonHT_WSN_ETSCH = [];
err_Tx_E_TSCH_widthANDfreq = zeros(5,75);
for w = 0 : 74 %number of EDs in each slot
  err_Tx_E_TSCH_width = [];
for l = 0 : 4 %number of EDs in each slot
  max_ngb_t_WV2E = [];
for m = 0 : 7 %TS number
  postChNonHT_WSN_ETSCH = [];
  for z = 0 : l
    postChNonHT_WSN_ETSCH = [postChNonHT_WSN_ETSCH;WSN_Ch11_100ms((1+15*z+500*m):(7+w+15*z+500*m),:);];
  end
  %postChNonHT_WSN_ETSCH = WSN_Ch11_100ms((1+500*m):(7+l+500*m),:);

  [TFR2E_2,T2E,F2E] = tfrwv(postChNonHT_WSN_ETSCH((1):(((7+w)*(l+1)))),1:length(postChNonHT_WSN_ETSCH((1):(((7+w)*(l+1))))),length(postChNonHT_WSN_ETSCH((1):(((7+w)*(l+1))))),1);

  %[TFR2E_2,T2E,F2E] = tfrwv(postChNonHT_WSN_ETSCH((1:(7+l))),1:length(postChNonHT_WSN_ETSCH((1:(7+l)))),length(postChNonHT_WSN_ETSCH((1:(7+l)))),1);


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
end % m
%figure;
x2E = linspace(0,time(length(time)),length(max_ngb_t_WV2E));
%plot(x2E,max_ngb_t_WV2E);
%xlabel ('t [us]');
%ylabel('Probability');
%title ('Time Domain');
xxE = 0:1:x2E(length(x2E));
pdfE = spline(x2E,max_ngb_t_WV2E,xxE);
err_Tx_E_TSCH_width = [err_Tx_E_TSCH_width;sqrt(immse(pdf_WSN_Ch11_RSSI,pdfE))];
end % l
  err_Tx_E_TSCH_widthANDfreq(:,w+1) = 1-err_Tx_E_TSCH_width;
  err_Tx_E_TSCH_widthANDfreq(1,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(1,w+1).*(1-0.002*(7+w)*1);
  err_Tx_E_TSCH_widthANDfreq(2,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(2,w+1).*(1-0.002*(7+w)*2);
  err_Tx_E_TSCH_widthANDfreq(3,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(3,w+1).*(1-0.002*(7+w)*3);
  err_Tx_E_TSCH_widthANDfreq(4,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(4,w+1).*(1-0.002*(7+w)*4);
  err_Tx_E_TSCH_widthANDfreq(5,w+1) = 1-err_Tx_E_TSCH_widthANDfreq(5,w+1).*(1-0.002*(7+w)*5);
end % w

x2 = 1:1:5;
x1 = 0.14:0.02:(0.02*75+0.138);
figure;
surf(x1,x2,err_Tx_E_TSCH_widthANDfreq);
ylabel ('number of EDs in each TS');
xlabel('ED width [ms]');
zlabel('root mean square error');
set(gca,'Ydir','reverse')

%figure;
%plot(x,err_Tx_E_TSCH_width);
%xlabel ('ED width [ms]');
%ylabel('root mean square error');

%Calculate as percentage:
%perc_err_ED_width = [];
%for i = 2 : length(err_Tx_E_TSCH_width)
%  perc_err_ED_width = [perc_err_ED_width;(((err_Tx_E_TSCH_width(i) - err_Tx_E_TSCH_width(1))/err_Tx_E_TSCH_width(1))*100)];
%end
%x = 0.16:0.02:(0.02*length(perc_err_ED_width)+0.158);
%figure;
%plot(x,perc_err_ED_width);
%xlabel ('ED width [ms]');
%ylabel('% error against E-TSCH');
