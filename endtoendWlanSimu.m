%End-to-End HT Simulation with Frequency Correction

%Set the parameters used throughout the example.
cbw = 'CBW20';   % Channel bandwidth
fs = 20e6;       % Sample rate (Hz)
ntx = 1;         % Number of transmit antennas
nsts = 1;        % Number of space-time streams
nrx = 1;         % Number of receive antennas

%Create a HT configuration object.

ht = wlanHTConfig('ChannelBandwidth',cbw, ...
    'NumTransmitAntennas',ntx,'NumSpaceTimeStreams',nsts, ...
    'SpatialMapping','Direct');

%Generate a HT waveform containing a random PSDU.

txPSDU = randi([0 1],ht.PSDULength*8,1);
txPPDU = wlanWaveformGenerator(txPSDU,ht);

time = ([0:length(txPPDU)-1]/fs)*1e6;
plot(time,abs(txPPDU))
xlabel ('Time (microseconds)');
ylabel('Magnitude');
title('TX');

%Create a ntx x nrx TGac channel and an AWGN channel.

chTG = wlanTGacChannel('SampleRate',fs,'ChannelBandwidth',cbw, ...
    'NumTransmitAntennas',ntx,'NumReceiveAntennas',nrx, ...
    'LargeScaleFadingEffect','Pathloss and shadowing', ...
    'DelayProfile','Model-C');
chAWGN = comm.AWGNChannel('NoiseMethod','Variance', ...
    'VarianceSource','Input port');

%Create a phase/frequency offset object.

pfo = comm.PhaseFrequencyOffset('SampleRate',fs,'FrequencyOffsetSource','Input port');

%Calculate the noise variance for a receiver with a 9 dB noise figure. Pass the transmitted waveform through the noisy TGac channel.

nVar = 10^((-228.6 + 10*log10(290) + 10*log10(fs) + 9)/10);
rxPPDU = step(chAWGN, step(chTG,txPPDU), nVar);

figure;
time = ([0:length(rxPPDU)-1]/fs)*1e6;
plot(time,abs(rxPPDU))
xlabel ('Time (microseconds)');
ylabel('Magnitude');
title('RX');

%Introduce a frequency offset of 500 Hz.

rxPPDUcfo = step(pfo,rxPPDU,500);



