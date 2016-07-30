%Create a bit stream to use when generating VHT, HT, and non-HT WLAN format waveforms.
%profile on
%bits = randi([0 1],1000,1);
bits = [1;0;0;1;1];
numPackets = 1;
fs = 20e6;
preChNonHT = [];

%Create a non-HT configuration object and generate a non-HT waveform.

nht = wlanNonHTConfig;
nht.PSDULength = 125; %Physical Layer Service Data Unit. Number of bytes carried in the user payload (actual data), specified as an integer from 1 to 4095.

%for P = 1:numPackets

%
%    r = randi([20 50],1,1);
%
%    preChNonHT = [preChNonHT;wlanWaveformGenerator(bits,nht,'NumPackets',1,'IdleTime',(r)*10^-6);];
%
%end
%----with ACK----
nht2 = wlanNonHTConfig;
nht2.PSDULength = 14; %ACK
nht3 = wlanNonHTConfig;
nht3.PSDULength = 240;
nht4 = wlanNonHTConfig;
nht4.PSDULength = 125;
preChNonHT = [wlanWaveformGenerator(bits,nht,'NumPackets',1,'IdleTime',10e-6);wlanWaveformGenerator(bits,nht2,'NumPackets',1,'IdleTime',(50e-6+32e-6));wlanWaveformGenerator(bits,nht3,'NumPackets',1,'IdleTime',(80e-6));wlanWaveformGenerator(bits,nht4,'NumPackets',1,'IdleTime',(10e-6));wlanWaveformGenerator(bits,nht2,'NumPackets',1,'IdleTime',0);]; %SIFS=10us, DIFS=50us, backoff1=64us (variable 31-1023), backoff2=128us
for i = 1 : 83
  preChNonHT = [preChNonHT;wlanWaveformGenerator(bits,nht,'NumPackets',1,'IdleTime',10e-6);wlanWaveformGenerator(bits,nht2,'NumPackets',1,'IdleTime',(50e-6+32e-6));wlanWaveformGenerator(bits,nht3,'NumPackets',1,'IdleTime',(80e-6));wlanWaveformGenerator(bits,nht4,'NumPackets',1,'IdleTime',(10e-6));wlanWaveformGenerator(bits,nht2,'NumPackets',1,'IdleTime',0);];
end
%----------------
preChNonHT = single(preChNonHT);
time = ((0:length(preChNonHT)-1)/fs)*1e5; %length of preChNonHT:1596000 or 19000
%time = ((0:0.02:100-0.02)); %for using RSSI data

figure;
plot(time,abs(preChNonHT));
xlabel ('t [ms]');
ylabel('Magnitude');

%BANDPASS FILTER

%[b,a] = butter(11, [2e6 4e6]./(fs), 'bandpass');  %Old filter design <GKN>
%h = fvtool(b,a);
%preChNonHT_WSN = filter(b,a,preChNonHT);

g=fdesign.bandpass(0.08,2e6/fs,4e6/fs,0.22,60,1,60);  % New filter design better performance <GKN>
%Hd = design(g,'equiripple');
Hd = design(g,'equiripple'); %cheby2 or ellip or equiripple or kaiserwin
%h = fvtool(Hd);
preChNonHT_WSN = filter(Hd,preChNonHT);

%Calculate free-space path loss for a transmitter-to-receiver separation distance of three meters. Create an 802.11g channel with a 3 Hz maximum Doppler shift and an RMS path delay equal to two times the sample time. Create an AWGN channel.

dist = 3;
fc = 2.412e9;
pathLoss = 10^(-log10(4*pi*dist*(fc/3e8)));
trms = 2/fs; %RMS path delay
ch802 = stdchan(1/fs,dist,'802.11b',trms);
chAWGN = comm.AWGNChannel('NoiseMethod','Variance','VarianceSource','Input port');

%WSN

fc_WSN = 2.405e9;
pathLoss_WSN = 10^(-log10(4*pi*dist*(fc_WSN/3e8)));
fs_WSN = 2e6;
trms_WSN = 2/fs_WSN; %RMS path delay
chWSN = stdchan(1/fs_WSN,dist,'802.11b',trms_WSN);

%Calculate the noise variance for a receiver with a 9 dB noise figure. The noise variance, nVar, is equal to kTBF, where k is Boltzmann's constant, T is the ambient temperature of 290 K, B is the bandwidth (sample rate), and F is the receiver noise figure. Pass the transmitted waveform through the noisy, lossy 802.11b channel.

nVar = 10^((-228.6 + 10*log10(290) + 10*log10(fs) + 9)/10);
postChNonHT = step(chAWGN, filter(ch802,preChNonHT), nVar) * pathLoss;
%postChNonHT = step(chAWGN, preChNonHT, nVar) * pathLoss;

%WSN
%NF for Zolertia Z1 (CC2420 transceiver) is not provided by vendor however
%it is assumed btw 5-7dBm in some papers

nVar_WSN = 10^((-228.6 + 10*log10(290) + 10*log10(fs) + 6)/10);
%postChNonHT_WSN = step(chAWGN, filter(ch802,preChNonHT_WSN), nVar_WSN) * pathLoss;

postChNonHT2 = step(chAWGN, filter(ch802,preChNonHT), nVar_WSN) * pathLoss;
%postChNonHT2 = step(chAWGN, preChNonHT, 8.0062e-51);
postChNonHT_WSN = filter(Hd,postChNonHT2);

%Display a spectrum analyzer with before-channel and after-channel waveforms. Use SpectralAverages = 10 to reduce noise in the plotted signals

title = '20 MHz Non-HT Waveform Before and After 802.11 Channel';
sa = dsp.SpectrumAnalyzer('FrequencyOffset',fc-10e6,'FrequencySpan','Start and stop frequencies','StartFrequency',fc-10e6,'StopFrequency',fc+10e6,'SampleRate',2*fs,'ShowLegend',true,...
    'SpectralAverages',10,'Title',title,'ChannelNames',{'WiFi Ch 1 Before','WiFi Ch 1 After','WSN Ch 11 After'});

%sa = dsp.SpectrumAnalyzer('SampleRate',2*fs,'ShowLegend',true,...
%    'SpectralAverages',10,'Title',title,'ChannelNames',{'WiFi Ch 1 Before','WiFi Ch 1 After','WSN Ch 11 After'});

%step(sa,[abs(preChNonHT),abs(postChNonHT),abs(postChNonHT_WSN)]);
combined = [preChNonHT,postChNonHT,postChNonHT_WSN];
step(sa,combined);

%preChNonHT(1:(length(preChNonHT)/2),:) = 0; % remove the duplicate part of the distribution

%N = nextpow2(length(preChNonHT));
%data = fft(X,2.^N);
%fixer = zeros([2.^N 1]);
%preChNonHT(numel(fixer)) = 0;

clear bits
clear ch802
clear AWGN
clear chWSN
clear chAWGN
%clear combined
clear dist
clear fc
clear fc_WSN
clear fs_WSN
clear g
clear Hd
clear nht
clear nht2
clear nht3
clear nht4
clear numPackets
clear nVar
clear nVar_WSN
clear pathLoss
clear pathLoss_WSN
clear postChNonHT2
clear preChNonHT_WSN
%clear sa
clear title
clear trms
clear trms_WSN

%--------------------------------------------Spectrogram--------------------------------------------------------
Lh=2.*round(((length(postChNonHT_WSN)/4)+1)/2)-1;
Lh2=2.*round(((length(postChNonHT_WSN)/10)+1)/2)-1;
%h = window(@kaiser,Lh);
h = tftb_window(Lh,'Hamming');
g = tftb_window(Lh2,'Hamming');
[TFR,T,F] = tfrsp(postChNonHT_WSN,1:length(postChNonHT_WSN),length(postChNonHT_WSN),h,1);
%[TFR3,RTFR3,HAT3] = tfrrpwv(postChNonHT_WSN, 1:length(postChNonHT_WSN), length(postChNonHT_WSN), h, 1);
%[TFR4,RTFR4,HAT4] = tfrrspwv(postChNonHT_WSN, 1:length(postChNonHT_WSN), length(postChNonHT_WSN),g, h, 1);

%[r1,c1]=size(TFR);
%fr_fixer=0.846; % scale to real frequency range %845
%TFR(1:(ceil(r1.*fr_fixer)),:) = []; % remove the duplicate part of the distribution
%[r2,c2]=size(TFR);
%TFR = [TFR;zeros((ceil(r1.*(fr_fixer-0.475))),c2)]; % add zero to end %455
%[r3,c3]=size(TFR);

[r1,c1]=size(TFR);
TFR(1:(ceil(r1.*0.5)),:) = []; % remove the duplicate part of the distribution
[r2,c2]=size(TFR);
fr_fixer=0.7; % scale to real frequency range %845
TFR_fixer=TFR(1:(ceil(r2.*fr_fixer)),:);
TFR(1:(ceil(r2.*fr_fixer)),:) = [];
TFR = [TFR;TFR_fixer]; % add to end %455
clear TFR_fixer;
[r3,c3]=size(TFR);
freq = linspace(2.402,2.422,r3);

figure;
imagesc(time, freq, abs(TFR));
%imagesc(Log10(abs(TFR)));
%imagesc(10.*abs(RTFR));
view(-90,90) % swap the x and y axis
colormap(hot);
xlabel('t [us]');
ylabel('f [GHz]');

% ---------- PDF Calculation for Spectrogram ------------
% Filled spectrum holes
max_ngb_t_SPR = zeros(1,(c3-419));
%t_total = 0;
for tm = 210 : (c3-210)
    count = 0;
    adjacent = zeros(1,ceil(r3/2));
    i=1;
    for fr = 1 : r3
        if abs(TFR(fr,tm)) >= 1e-6
            count = count + 1;
            %t_total = t_total + 1;
        else
            adjacent(1,i) = count;
            i = i + 1;
            count = 0;
        end
    end
    max_ngb_t_SPR(1,(tm-209)) = max(adjacent);
end
%pdft = pdft/t_total;
max_ngb_t_SPR = max_ngb_t_SPR/r3;
clear adjacent;

max_ngb_f_SPR = zeros(1,r3);
%f_total = 0;
for fr = 1 : r3
    count = 0;
    adjacent = zeros(1,ceil(c3/2));
    i=1;
    for tm = 210 : (c3-210)
        if abs(TFR(fr,tm)) >= 1e-6
            count = count + 1;
            %f_total = f_total + 1;
        else
            adjacent(1,i) = count;
            i = i + 1;
            count = 0;
        end
    end
    max_ngb_f_SPR(1,fr) = max(adjacent);
end
%pdff = pdff/f_total;
max_ngb_f_SPR = max_ngb_f_SPR/length(max_ngb_t_SPR);
clear adjacent;

figure;
x = linspace(2.402,2.422,length(max_ngb_f_SPR));
plot(x,max_ngb_f_SPR);
xlabel ('f [GHz]');
ylabel('Probability');
%title('Frequency Domain');
figure;
x2 = linspace(0,time(length(time)),length(max_ngb_t_SPR));
plot(x2,max_ngb_t_SPR);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
figure;
pdf3D = pdft'*pdff;
mesh(x,time,pdf3D);
xlabel ('f [GHz]');
ylabel('t [us]');
zlabel('Probability');

%Free Spectrum Holes
for i = 1 : length(freq)
    if freq(i) >= 2.404
      break
    end
end
for j = i : length(freq)
    if freq(j) >= 2.406
      break
    end
end
max_ngb_t_SPR2 = zeros(1,(c3-149));
%t_total = 0;
for tm = 150 : (c3)
    count = 0;
    adjacent = zeros(1,ceil((j-i)));
    %adjacent = zeros(1,ceil(r3));
    k = 1;
    for fr = i : j
    %for fr = 1 : r3 %446 : 899
        if abs(TFR(fr,tm)) <= 1e-7
            count = count + 1;
            %t_total = t_total + 1;
        else
          adjacent(1,k) = count;
          k = k + 1;
          count = 0;
        end
    end
    max_ngb_t_SPR2(1,(tm-149)) = max(adjacent);
end
%max_ngb_t_SPR2 = max_ngb_t_SPR2/t_total;
max_ngb_t_SPR2 = max_ngb_t_SPR2/(j-i);
clear adjacent;

max_ngb_f_SPR2 = zeros(1,(j-i));
%f_total = 0;
for fr = i : j
    count = 0;
    adjacent = zeros(1,ceil(c3/2));
    k = 1;
    for tm = 210 : (c3-210)
        if abs(TFR(fr,tm)) <= 1e-6
            count = count + 1;
            %f_total = f_total + 1;
        else
          adjacent(1,k) = count;
          k = k + 1;
          count = 0;
        end
    end
    max_ngb_f_SPR2(1,(fr-i+1)) = max(adjacent);
end
%max_ngb_f_SPR2 = max_ngb_f_SPR2/f_total;
max_ngb_f_SPR2 = max_ngb_f_SPR2/length(max_ngb_t_SPR2);
clear adjacent;

figure;
x2 = linspace(0,time(length(time)),length(max_ngb_t_SPR2));
plot(x2,max_ngb_t_SPR2);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
figure;
x = linspace(2.404,2.406,length(max_ngb_f_SPR2));
plot(x,max_ngb_f_SPR2);
xlabel ('f [GHz]');
ylabel('Probability');
%title ('Frequency Domain');
figure;
pdf3D2 = pdft2'*pdff2;
mesh(x,time,pdf3D2);
xlabel ('f [GHz]');
ylabel('t [us]');
zlabel('Probability');

%---------------------------------------------Wigner-Ville------------------------------------------------------
[TFR2,T2,F2] = tfrwv(postChNonHT_WSN,1:length(postChNonHT_WSN),length(postChNonHT_WSN),1);
%[TFR2,T2,F2] = tfrwv(preChNonHT_WSN,1:length(preChNonHT_WSN),length(preChNonHT_WSN),1);

%[r1,c1]=size(TFR2);
%TFR2(15460:r1,:) = [];
%fr_fixer=0.695; % scale to real frequency range
%[r2,c2]=size(TFR2);
%TFR2(1:(ceil(r1.*fr_fixer)),:) = [];
%[r3,c3]=size(TFR2);
%TFR2 = [TFR2;zeros((ceil(r1.*(fr_fixer+0.1))),c2)]; % add zero to end
%[r4,c4]=size(TFR2);

%[r1,c1]=size(TFR2);
%TFR2_fixer=TFR2(ceil(0.29*r1):ceil(0.6*r1),:); %9750:16403
%TFR2(1:((ceil(0.6*r1)-ceil(0.29*r1))+1),:) = TFR2_fixer; %16403-9750
%clear TFR2_fixer;
%TFR2_fixer=TFR2(ceil(0.68*r1):ceil(0.745*r1),:); %22756:24495
%TFR2((r1-(ceil(0.745*r1)-ceil(0.68*r1))):r1,:) = TFR2_fixer; %24495-22756
%clear TFR2_fixer;
%fr_fixer=0.7; % scale to real frequency range %845
%TFR2_fixer=TFR2(1:(ceil(r1.*fr_fixer)),:);
%TFR2(1:(ceil(r1.*fr_fixer)),:) = [];
%TFR2 = [TFR2;TFR2_fixer]; % add to end %455
%clear TFR2_fixer;
%[r2,c2]=size(TFR2);
%freq2 = linspace(2.402,2.422,r2);

[r1,c1]=size(TFR2);
TFR2_fixer=TFR2(11173:12105,:);
TFR2(1:933,:) = TFR2_fixer;
TFR2_fixer=TFR2(5820:10177,:);
TFR2(10178:14535,:) = TFR2_fixer;
TFR2_fixer=TFR2(8329:10177,:);
TFR2(14536:16384,:) = TFR2_fixer;
[r2,c2]=size(TFR2);
freq2 = linspace(2.402,2.422,r2);

figure;
imagesc(time, freq2, abs(TFR2));
%imagesc(Log10(abs(TFR2)));
view(-90,90) % swap the x and y axis
colormap(hot);
xlabel('t [us]');
ylabel('f [GHz]');

%------------PDF Calculation for Wigner-Ville------------
% Filled spectrum holes
max_ngb_t_WV = zeros(1,(c2-419));
%t_total = 0;
for tm = 210 : (c2-210)
    count = 0;
    adjacent = zeros(1,ceil(r2/2));
    i=1;
    for fr = 1 : r2
        if abs(TFR2(fr,tm)) >= 1e-7
            count = count + 1;
            %t_total = t_total + 1;
        else
          adjacent(1,i) = count;
          i = i + 1;
          count = 0;
        end
    end
    max_ngb_t_WV(1,(tm-209)) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_t_WV(1,tm) = count;
    %end
end
%pdft = pdft/t_total;
max_ngb_t_WV = max_ngb_t_WV/r2;
clear adjacent;

max_ngb_f_WV = zeros(1,r2);
%f_total = 0;
for fr = 1 : r2
    count = 0;
    adjacent = zeros(1,ceil(c2/2));
    i = 1;
    for tm = 210 : (c2-210)
        if abs(TFR2(fr,tm)) >= 1e-6
            count = count + 1;
            %f_total = f_total + 1;
        else
          adjacent(1,i) = count;
          i = i + 1;
          count = 0;
        end
    end
    max_ngb_f_WV(1,fr) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_f_WV(1,fr) = count;
    %end
end
%pdff = pdff/f_total;
max_ngb_f_WV = max_ngb_f_WV/length(max_ngb_t_WV);
clear adjacent;

figure;
x2 = linspace(0,time(length(time)),length(max_ngb_t_WV));
plot(x2,max_ngb_t_WV);
xlabel ('t [us]');
ylabel('Probability');
%title('Time Domain');
figure;
x = linspace(2.402,2.422,length(max_ngb_f_WV));
plot(x,max_ngb_f_WV);
xlabel ('f [GHz]');
ylabel('Probability');
%title('Frequency Domain');
figure;
pdf3D = pdft'*pdff;
mesh(x,time,pdf3D);
xlabel ('f [GHz]');
ylabel('t [us]');
zlabel('Probability');

%Free Spectrum Holes
for i = 1 : length(freq2)
    if freq2(i) >= 2.404
      break
    end
end
for j = i : length(freq2)
    if freq2(j) >= 2.406
      break
    end
end
max_ngb_t_WV2 = zeros(1,(c2));
%t_total = 0;
for tm = 1 : (c2)
    count = 0;
    adjacent = zeros(1,ceil((j-i)));
    %adjacent = zeros(1,ceil((r2)/2));
    k = 1;
    for fr = i : j % 1722 : 3380
    %for fr = 1 : r2 % 1722 : 3380
        if abs(TFR2(fr,tm)) <= 1e-6
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
max_ngb_t_WV2 = max_ngb_t_WV2/(j-i);
clear adjacent;

max_ngb_f_WV2 = zeros(1,(j-i));
%f_total = 0;
for fr = i : j
    count = 0;
    adjacent = zeros(1,ceil(c2/2));
    k = 1;
    for tm = 210 : (c2-210)
        if abs(TFR2(fr,tm)) <= 1e-6
            count = count + 1;
            %f_total = f_total + 1;
        else
            adjacent(1,k) = count;
            k = k + 1;
            count = 0;
        end
    end
    max_ngb_f_WV2(1,(fr-i+1)) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_f_WV2(1,(fr-i+1)) = count;
    %end
end
%max_ngb_f_WV2 = max_ngb_f_WV2/f_total;
max_ngb_f_WV2 = max_ngb_f_WV2/length(max_ngb_t_WV2);
clear adjacent;

figure;
x2 = linspace(0,time(length(time)),length(max_ngb_t_WV2));
plot(x2,max_ngb_t_WV2);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
figure;
x = linspace(2.404,2.406,length(max_ngb_f_WV2));
plot(x,max_ngb_f_WV2);
xlabel ('f [GHz]');
ylabel('Probability');
%title ('Frequency Domain');
figure;
pdf3D2 = pdft2'*pdff2;
mesh(x,time,pdf3D2);
xlabel ('f [GHz]');
ylabel('t [us]');
zlabel('Probability');
%-------------AVERAGE--------------
avg_energy = zeros(1,(c2R));
for tm = 1 : (c2R)
    total_energy = 0;
    %for fr = i : j % 1722 : 3380
    for fr = 1 : r2R % 1722 : 3380
        total_energy = total_energy + abs(TFR2R(fr,tm));
    end
    avg_energy(1,(tm)) = total_energy/r2R;
end
clear total_energy;
figure;
plot(time,avg_energy);
xlabel ('t [us]');
ylabel('Energy');
%title ('Time Domain');
%----------SPR ERROR---------------
figure;
xx_SPR_WSN = 0:1:x2(length(x2));
pdf_SPR_WSN = spline(x2,max_ngb_t_SPR2,xx_SPR_WSN);
plot(xx_SPR_WSN,pdf_SPR_WSN);
hold on;
xx_SPR_WiFi_Rx = 0:1:x2(length(x2));
pdf_SPR_WiFi_Rx = spline(x2,max_ngb_t_SPR2R,xx_SPR_WiFi_Rx);
plot(xx_SPR_WiFi_Rx,pdf_SPR_WiFi_Rx);
hold on;
xx_SPR_WiFi_Tx = 0:1:x2(length(x2));
pdf_SPR_WiFi_Tx = spline(x2,max_ngb_t_SPR2T,xx_SPR_WiFi_Tx);
plot(xx_SPR_WiFi_Tx,pdf_SPR_WiFi_Tx);

err_SPR_Tx_WSN = sqrt(immse(pdf_SPR_WiFi_Tx,pdf_SPR_WSN))
err_SPR_Tx_Rx = sqrt(immse(pdf_SPR_WiFi_Tx,pdf_SPR_WiFi_Rx))
%----------WV ERROR---------------
figure;
xx_WSN = 0:1:x2(length(x2));
pdf_WSN = spline(x2,max_ngb_t_WV2,xx_WSN);
plot(xx_WSN,pdf_WSN);
hold on;
xx_WiFi_Rx = 0:1:time(length(time));
pdf_WiFi_Rx = spline(time,max_ngb_t_WV2R,xx_WiFi_Rx);
plot(xx_WiFi_Rx,pdf_WiFi_Rx);
hold on;
xx_WiFi_Tx = 0:1:time(length(time));
pdf_WiFi_Tx = spline(time,max_ngb_t_WV2T,xx_WiFi_Tx);
plot(xx_WiFi_Tx,pdf_WiFi_Tx);
xlabel ('t [us]');
ylabel('Probability');

err_Tx_WSN = sqrt(immse(pdf_WiFi_Tx,pdf_WSN))
err_Tx_Rx = sqrt(immse(pdf_WiFi_Tx,pdf_WiFi_Rx))
%----------E-TSCH ERROR---------------
figure;
xx_E_TSCH = 0:1:x2_E_TSCH(length(x2_E_TSCH));
pdf_E_TSCH = spline(x2_E_TSCH,max_ngb_t_WV2_ETSCH,xx_E_TSCH);
plot(xx_E_TSCH,pdf_E_TSCH);
hold on;
xx_WiFi_Tx = 0:1:time(length(time));
pdf_WiFi_Tx = spline(time,max_ngb_t_WV2T,xx_WiFi_Tx);
plot(xx_WiFi_Tx,pdf_WiFi_Tx);
xlabel ('t [us]');
ylabel('Probability');
legend('WSN (E-TSCH)','WiFi Tx');

err_Tx_E_TSCH = sqrt(immse(pdf_WiFi_Tx,pdf_E_TSCH))
%------------------------------------
%----------8 SLOT E-TSCH ERROR---------------
figure;
xx_WiFi_Tx = 0:1:time(length(time));
pdf_WiFi_Tx = spline(time,max_ngb_t_WV2T,xx_WiFi_Tx);
plot(xx_WiFi_Tx,pdf_WiFi_Tx);
xlabel ('t [us]');
ylabel('Probability');

pdf_WiFi_Tx_Edited = [];
for i = 1 : 84
  pdf_WiFi_Tx_Edited = [pdf_WiFi_Tx_Edited,pdf_WiFi_Tx];
end

figure;
xxE = 0:1:x2E(length(x2E));
pdfE = spline(x2E,max_ngb_t_WV2E,xxE);
plot(xxE,pdfE);
%hold on;
%xx_WiFi_Tx = 0:1:time(length(time));
%pdf_WiFi_Tx = spline(time,max_ngb_t_WV2T,xx_WiFi_Tx);
%plot(xx_WiFi_Tx,pdf_WiFi_Tx);
%xlabel ('t [us]');
%ylabel('Probability');
%legend('WSN (E-TSCH)','WiFi Tx');

err_Tx_E_TSCH = sqrt(immse(pdf_WiFi_Tx_Edited,pdfE))
%Continuous => result = 4.3780e-08
%E-TSCH => result = 4.9364e-08 => 12.75% worse
%A-TSCH => result = 8.3191e-08 => 68% worse
%E-TSCH 10% worse than 3xE-TSCH
%------------------------------------
%filename = 'wvWorkspace.mat';
%save(filename,'-v7.3')
%hgsave(1, ['/Users/GKN/Desktop/Outputname.fig'], '-v7.3');
