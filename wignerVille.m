HT = wlanHTConfig

HT.PSDULength=16

numPkts = 2;
scramInit = randi([1 127],numPkts,1);
txWaveform = wlanWaveformGenerator([1;0;0;1],HT,'NumPackets',numPkts,'IdleTime',30e-5,'ScramblerInitialization',scramInit);
time = [0:length(txWaveform)-1]/20e-6;
plot(time,abs(txWaveform))
xlabel ('Time (microseconds)');
ylabel('Amplitude');

figure;
%[TFR,T,F] = tfrwv(txWaveform,1:length(txWaveform), length(txWaveform), 1);
[TFR,RTFR,HAT] = tfrrpwv(txWaveform,1:length(txWaveform), length(txWaveform), hamming(length(txWaveform)/4.2),1);

%TFR(:, 1:7200) = 0;    % remove the duplicate part of the distribution
%imagesc(T/1e9, (F+2.407):0.005:(F+2.447), abs(RTFR));
imagesc(abs(RTFR));
colormap(hot);
xlabel('t [s]');
ylabel('f [GHz]');

%spectrogram(txWaveform,kaiser(256,5),220,512,fs,'yaxis')

