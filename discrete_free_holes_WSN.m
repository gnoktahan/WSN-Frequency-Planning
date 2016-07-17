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
max_ngb_t_WV2_ETSCH = zeros(1,(2561*3));
c = 1;
%t_total = 0;
for tm = 150 : (150+2560)
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
    max_ngb_t_WV2_ETSCH(1,c) = max(adjacent);
    c = c+1;
    %if count > max(adjacent)
      %max_ngb_t_WV2_ETSCH(1,tm) = count;
    %end
end
%max_ngb_t_WV2_ETSCH = max_ngb_t_WV2_ETSCH/t_total;
for tm = (150+6000) : (150+6000+2560)
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
    max_ngb_t_WV2_ETSCH(1,c) = max(adjacent);
    c = c+1;
    %if count > max(adjacent)
      %max_ngb_t_WV2_ETSCH(1,tm) = count;
    %end
end
for tm = (150+6000+6000) : (150+6000+6000+2560)
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
    max_ngb_t_WV2_ETSCH(1,c) = max(adjacent);
    c = c+1;
    %if count > max(adjacent)
      %max_ngb_t_WV2_ETSCH(1,tm) = count;
    %end
end
max_ngb_t_WV2_ETSCH = max_ngb_t_WV2_ETSCH/(j-i);
clear adjacent;
figure;
x2_E_TSCH = linspace(0,time(length(time)),length(max_ngb_t_WV2_ETSCH));
plot(x2_E_TSCH,max_ngb_t_WV2_ETSCH);
xlabel ('t [us]');
ylabel('Probability');
%title ('Time Domain');
