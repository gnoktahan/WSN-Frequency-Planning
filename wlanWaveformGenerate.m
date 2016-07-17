nht = wlanNonHTConfig

fs = 20e6;

bits = [1;0;0;1;1];

numPackets = 5;

nhtWaveform = [];

for P = 1:numPackets
    
    r = randi([30 500],1,1);

    nhtWaveform = [nhtWaveform;wlanWaveformGenerator(bits,nht,'NumPackets',1,'IdleTime',(r)*10^-6);];

end

time = ([0:length(nhtWaveform)-1]/fs)*1e6;

plot(time,abs(nhtWaveform))

xlabel ('Time (microseconds)');

ylabel('Magnitude');