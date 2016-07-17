Lh=2.*round(((length(postChNonHT_WSN)/4)+1)/2)-1;
%h = window(@kaiser,Lh);
h = tftb_window(Lh,'Hamming');
[TFR,T,F] = tfrsp(postChNonHT_WSN,1:length(postChNonHT_WSN),length(postChNonHT_WSN),h,1);

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
        if abs(TFR(fr,tm)) <= 1e-6
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
max_ngb_t_SPR2 = max_ngb_t_SPR2/(1.25*(j-i));
clear adjacent;

figure;
x2 = linspace(0,time(length(time)),length(max_ngb_t_SPR2));
plot(x2,max_ngb_t_SPR2);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
