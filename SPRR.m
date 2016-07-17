Lh=2.*round(((length(postChNonHT)/4)+1)/2)-1;
%h = window(@kaiser,Lh);
h = tftb_window(Lh,'Hamming');
[TFRR,TR,FR] = tfrsp(postChNonHT,1:length(postChNonHT),length(postChNonHT),h,1);

[r3R,c3R]=size(TFRR);
freqR = linspace(2.402,2.422,r3R);

%Free Spectrum Holes
for i = 1 : length(freqR)
    if freqR(i) >= 2.404
      break
    end
end
for j = i : length(freqR)
    if freqR(j) >= 2.406
      break
    end
end
max_ngb_t_SPR2R = zeros(1,(c3R-149));
%t_total = 0;
for tm = 150 : (c3R)
    count = 0;
    %adjacent = zeros(1,ceil((j-i)/2));
    adjacent = zeros(1,ceil(r3R));
    k = 1;
    %for fr = i : j
    for fr = 1 : r3R %446 : 899
        if abs(TFRR(fr,tm)) <= 1e-7
            count = count + 1;
            %t_total = t_total + 1;
        else
          adjacent(1,k) = count;
          k = k + 1;
          count = 0;
        end
    end
    max_ngb_t_SPR2R(1,(tm-149)) = max(adjacent);
end
%max_ngb_t_SPR2 = max_ngb_t_SPR2/t_total;
max_ngb_t_SPR2R = max_ngb_t_SPR2R/(r3R);
clear adjacent;

figure;
x2R = linspace(0,time(length(time)),length(max_ngb_t_SPR2R));
plot(x2R,max_ngb_t_SPR2R);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
