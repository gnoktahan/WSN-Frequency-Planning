[TFR2R,T2R,F2R] = tfrwv(postChNonHT,1:length(postChNonHT),length(postChNonHT),1);

[r2R,c2R]=size(TFR2R);
freq2R = linspace(2.402,2.422,r2R);
for i = 1 : length(freq2R)
    if freq2R(i) >= 2.404
      break
    end
end
for j = i : length(freq2R)
    if freq2R(j) >= 2.406
      break
    end
end
max_ngb_t_WV2R = zeros(1,(c2R));
%t_total = 0;
for tm = 1 : (c2R)
    count = 0;
    %adjacent = zeros(1,ceil((j-i)/2));
    adjacent = zeros(1,ceil((r2R)));
    k = 1;
    %for fr = i : j % 1722 : 3380
    for fr = 1 : r2R % 1722 : 3380
        if abs(TFR2R(fr,tm)) <= 1e-8
            count = count + 1;
            %t_total = t_total + 1;
        else
            adjacent(1,k) = count;
            k = k + 1;
            count = 0;
        end
    end
    max_ngb_t_WV2R(1,(tm)) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_t_WV2R(1,tm) = count;
    %end
end
%max_ngb_t_WV2R = max_ngb_t_WV2R/t_total;
max_ngb_t_WV2R = max_ngb_t_WV2R/(j-i);
clear adjacent;
figure;
plot(time,max_ngb_t_WV2R);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
