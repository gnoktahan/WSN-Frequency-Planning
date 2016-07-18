load('/Users/GKN/Desktop/Tez görseller/17.07.2016/1/err_Tx_E_TSCH_1.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/1/err_Tx_E_TSCH_width_1.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/2/err_Tx_E_TSCH_2.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/2/err_Tx_E_TSCH_width_2.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/3/err_Tx_E_TSCH_3.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/3/err_Tx_E_TSCH_width_3.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/4/err_Tx_E_TSCH_4.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/4/err_Tx_E_TSCH_width_4.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/5/err_Tx_E_TSCH_5.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/5/err_Tx_E_TSCH_width_5.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/6/err_Tx_E_TSCH_6.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/6/err_Tx_E_TSCH_width_6.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/7/err_Tx_E_TSCH_7.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/7/err_Tx_E_TSCH_width_7.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/8/err_Tx_E_TSCH_8.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/8/err_Tx_E_TSCH_width_8.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/9/err_Tx_E_TSCH_width_9.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/9/perc_err_ED_freq_9.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/9/err_Tx_E_TSCH_9.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/10/err_Tx_E_TSCH_10.mat')
load('/Users/GKN/Desktop/Tez görseller/17.07.2016/10/err_Tx_E_TSCH_width_10.mat')

err_Tx_E_TSCH_avg = [];
for i = 1 : 10
  err_Tx_E_TSCH_avg = (err_Tx_E_TSCH_1 + err_Tx_E_TSCH_2 + err_Tx_E_TSCH_3 + err_Tx_E_TSCH_4 + err_Tx_E_TSCH_5 + err_Tx_E_TSCH_6 + err_Tx_E_TSCH_7 + err_Tx_E_TSCH_8 + err_Tx_E_TSCH_9 + err_Tx_E_TSCH_10)/10;
end
figure;
x = 1:1:length(err_Tx_E_TSCH_avg);
plot(x,err_Tx_E_TSCH_avg);
xlabel ('number of EDs in each TS');
ylabel('root mean square error');
%Calculate as percentage:
perc_err_ED_freq_avg = [];
for i = 2 : length(err_Tx_E_TSCH_avg)
  perc_err_ED_freq_avg = [perc_err_ED_freq_avg;(((err_Tx_E_TSCH_avg(i) - err_Tx_E_TSCH_avg(1))/err_Tx_E_TSCH_avg(1))*100)];
end
figure;
x = 2:1:(length(perc_err_ED_freq_avg)+1);
plot(x,perc_err_ED_freq_avg);
xlabel ('number of EDs in each TS');
ylabel('% RMSE against E-TSCH');



err_Tx_E_TSCH_width_avg = [];
for i = 1 : 10
  err_Tx_E_TSCH_width_avg = (err_Tx_E_TSCH_width_1 + err_Tx_E_TSCH_width_2 + err_Tx_E_TSCH_width_3 + err_Tx_E_TSCH_width_4 + err_Tx_E_TSCH_width_5 + err_Tx_E_TSCH_width_6 + err_Tx_E_TSCH_width_7 + err_Tx_E_TSCH_width_8 + err_Tx_E_TSCH_width_9 + err_Tx_E_TSCH_width_10)/10;
end
x = 0.14:0.02:(0.02*length(err_Tx_E_TSCH_width_avg)+0.138);
figure;
plot(x,err_Tx_E_TSCH_width_avg);
xlabel ('ED width [ms]');
ylabel('root mean square error');
%Calculate as percentage:
perc_err_ED_width_avg = [];
for i = 2 : length(err_Tx_E_TSCH_width_avg)
  perc_err_ED_width_avg = [perc_err_ED_width_avg;(((err_Tx_E_TSCH_width_avg(i) - err_Tx_E_TSCH_width_avg(1))/err_Tx_E_TSCH_width_avg(1))*100)];
end
x = 0.16:0.02:(0.02*length(err_Tx_E_TSCH_width_avg)+0.158);
figure;
plot(x,err_Tx_E_TSCH_width_avg);
xlabel ('ED width [ms]');
ylabel('% RMSE against E-TSCH');
