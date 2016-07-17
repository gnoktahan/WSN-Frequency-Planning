% physical channel parameters
TWO_DOT_FOUR_GHZ= 2400000000;   % Hz
PISTER_HACK_LOWER_SHIFT= 40; %           # -40 dB
SPEED_OF_LIGHT=299792458; %    # m/s
txPower = 0; %dbm
antennaGain = 0; %dBm
recantennaGain= 0; %dBm
STABLE_RSSI = -93.6;     %   # dBm, corresponds to PDR = 0.5
noisepower=-105; %dBm
interference=60; %dBm
squaresize=5; %meters
T=35;   %number of users
rssitable=[
            -97    0.0000; 
            -96    0.1494;
            -95    0.2340;
            -94    0.4071;  %            #<-- 50% PDR is here; at RSSI=-93.6
            -93    0.6359;
            -92    0.6866;
            -91    0.7476;
            -90    0.8603;
            -89    0.8702;
            -88    0.9324;
            -87    0.9427;
            -86    0.9562;
            -85    0.9611;
            -84    0.9739;
            -83    0.9745;
            -82    0.9844;
            -81    0.9854;
            -80    0.9903;
            -79    1.0000 
        ];
    



%medium access initialization
Td=10; %delay budget
Ntc=16; % Total number of channels
beta=4; % blacklisting co-efficient
Ncc=floor(Ntc/beta); % Number of clear channels




%iteration for random packet transmission over wireless medium
N=10000; %Number of packets to transmit from each user
%whitelist iteration
%if beta<=4
%    wl=4;
%else
%    wl=floor(Ntc/beta);
%end
%M=T;
WC=zeros(2,T);
ave=zeros(2,T);
for z=1:T
M=z;   
npwl=floor(Td./ceil((M/4))); %maximum transmission of whitelist in slots before deadline
npbl=floor(Td./ceil((beta*M/Ntc))); %maximum transmission of blacklist in slots before deadline
npsl=floor(Td./ceil((M)./Ntc));  %maximum transmission of static list in slots  before deadline

%fix RSSI calculation at initialization
locations=rand(2,M)*squaresize;
distances=sqrt((locations(1,:)-((squaresize/2)*ones(1,M))).^2+(locations(2,:)-((squaresize/2)*ones(1,M))).^2);
fspl=(SPEED_OF_LIGHT./(4*pi*distances*TWO_DOT_FOUR_GHZ));
pr = txPower*ones(1,M) + antennaGain*ones(1,M) + recantennaGain*ones(1,M) + (20*log10(fspl));
mu = pr-PISTER_HACK_LOWER_SHIFT/2;    
    
    
    
    

fsucwl=zeros(N,M);
for k=1:N
for l=1:npwl

rssi = floor(mu + PISTER_HACK_LOWER_SHIFT.*rand(1,M) - (PISTER_HACK_LOWER_SHIFT*ones(1,M))/2);
suc=zeros(1,M);
pdr=zeros(1,M);
comp=rand(1,M);
for i=1:M
    if rssi(i)<min(rssitable(:,1))
        pdr(i)=0;
        suc(i)=0;
    elseif rssi(i)>max(rssitable(:,1))
        pdr(i)=1;
        suc(i)=1;
    else
        j=1;
        while rssi(i)~=rssitable(j,1)
            j=j+1;            
        end
        pdr(i)=rssitable(j,1);
        if pdr(i)> comp(i)
            suc(i)=1;
        else
            suc(i)=0;
        end
    end
end

fsucwl(k,:)=or(fsucwl(k,:),suc(1,:));
end

end

%staticlist iteration
W=floor((floor(Td./ceil((beta.*M)/Ntc)))/beta);

fsucsl=zeros(N,M);
for k=1:N
for l=1:npsl
%add interference with a %50 probability "--> See tsch measurements paper" to the non whitened combinations.
if l>W
    rssi = floor(mu + PISTER_HACK_LOWER_SHIFT.*rand(1,M) - (PISTER_HACK_LOWER_SHIFT*ones(1,M))/2);
else
    rssi = floor(mu + PISTER_HACK_LOWER_SHIFT.*rand(1,M) - (PISTER_HACK_LOWER_SHIFT*ones(1,M))/2);
    if rand(1,1)>0.5
    	rssi = rssi + interference;
    end
end
suc=zeros(1,M);
pdr=zeros(1,M);
comp=rand(1,M);
for i=1:M
    if rssi(i)<min(rssitable(:,1))
        pdr(i)=0;
        suc(i)=0;
    elseif rssi(i)>max(rssitable(:,1))
        pdr(i)=1;
        suc(i)=1;
    else
        j=1;
        while rssi(i)~=rssitable(j,1)
            j=j+1;            
        end
        pdr(i)=rssitable(j,1);
        if pdr(i)> comp(i)
            suc(i)=1;
        else
            suc(i)=0;
        end
    end
end

fsucsl(k,:)=or(fsucsl(k,:),suc);
end

end

WC(1,z)=min(sum(fsucwl)/N);
WC(2,z)=min(sum(fsucsl)/N);

ave(1,z)=sum(sum(fsucwl)/N)/z;
ave(2,z)=sum(sum(fsucsl)/N)/z;
end