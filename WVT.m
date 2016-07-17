[TFR2T,T2T,F2T] = tfrwv(preChNonHT,1:length(preChNonHT),length(preChNonHT),1);

[r2T,c2T]=size(TFR2T);
freq2T = linspace(2.402,2.422,r2T);
for i = 1 : length(freq2T)
    if freq2T(i) >= 2.404
      break
    end
end
for j = i : length(freq2T)
    if freq2T(j) >= 2.406
      break
    end
end
max_ngb_t_WV2T = zeros(1,(c2T));
%t_total = 0;
for tm = 1 : (c2T)
    count = 0;
    %adjacent = zeros(1,ceil((j-i)/2));
    adjacent = zeros(1,ceil((r2T)));
    k = 1;
    %for fr = i : j % 1722 : 3380
    for fr = 1 : r2T % 1722 : 3380
        if abs(TFR2T(fr,tm)) <= 0.55e-3
            count = count + 1;
            %t_total = t_total + 1;
        else
            adjacent(1,k) = count;
            k = k + 1;
            count = 0;
        end
    end
    max_ngb_t_WV2T(1,(tm)) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_t_WV2T(1,tm) = count;
    %end
end
%max_ngb_t_WV2T = max_ngb_t_WV2T/t_total;
max_ngb_t_WV2T = max_ngb_t_WV2T/(j-i);
clear adjacent;
figure;
plot(time,max_ngb_t_WV2T);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
