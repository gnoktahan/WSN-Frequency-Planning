Lh=2.*round(((length(preChNonHT)/4)+1)/2)-1;
%h = window(@kaiser,Lh);
h = tftb_window(Lh,'Hamming');
[TFRT,TT,FT] = tfrsp(preChNonHT,1:length(preChNonHT),length(preChNonHT),h,1);

[r3T,c3T]=size(TFRT);
freqT = linspace(2.402,2.422,r3T);

%Free Spectrum Holes
for i = 1 : length(freqT)
    if freqT(i) >= 2.404
      break
    end
end
for j = i : length(freqT)
    if freqT(j) >= 2.406
      break
    end
end
max_ngb_t_SPR2T = zeros(1,(c3T-149));
%t_total = 0;
for tm = 150 : (c3T)
    count = 0;
    %adjacent = zeros(1,ceil((j-i)/2));
    adjacent = zeros(1,ceil(r3T/2));
    k = 1;
    %for fr = i : j
    for fr = 1 : r3T %446 : 899
        if abs(TFRT(fr,tm)) <= 1e-7
            count = count + 1;
            %t_total = t_total + 1;
        else
          adjacent(1,k) = count;
          k = k + 1;
          count = 0;
        end
    end
    max_ngb_t_SPR2T(1,(tm-149)) = max(adjacent);
end
%max_ngb_t_SPR2 = max_ngb_t_SPR2/t_total;
max_ngb_t_SPR2T = max_ngb_t_SPR2T/(r3T);
clear adjacent;

figure;
x2T = linspace(0,time(length(time)),length(max_ngb_t_SPR2T));
plot(x2T,max_ngb_t_SPR2T);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
