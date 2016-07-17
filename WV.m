[TFR2,T2,F2] = tfrwv(postChNonHT_WSN,1:length(postChNonHT_WSN),length(postChNonHT_WSN),1);

[r2,c2]=size(TFR2);
freq2 = linspace(2.402,2.422,r2);
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
max_ngb_t_WV2 = zeros(1,(c2-149));
%t_total = 0;
for tm = 150 : (c2)
    count = 0;
    adjacent = zeros(1,ceil((j-i)));
    %adjacent = zeros(1,ceil((r2)/2));
    k = 1;
    for fr = i : j % 1722 : 3380
    %for fr = 1 : r2 % 1722 : 3380
        if abs(TFR2(fr,tm)) <= 1e-9
            count = count + 1;
            %t_total = t_total + 1;
        else
            adjacent(1,k) = count;
            k = k + 1;
            count = 0;
        end
    end
    max_ngb_t_WV2(1,(tm-149)) = max(adjacent);
    %if count > max(adjacent)
      %max_ngb_t_WV2(1,tm) = count;
    %end
end
%max_ngb_t_WV2 = max_ngb_t_WV2/t_total;
max_ngb_t_WV2 = max_ngb_t_WV2/(j-i);
clear adjacent;
figure;
x2 = linspace(0,time(length(time)),length(max_ngb_t_WV2));
plot(x2,max_ngb_t_WV2);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
