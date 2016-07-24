%CSV oluştururken bu sütunu sona ekle bir de başlık satırı ekle
row = [];
for i = 1 : length(T)
  count = 0;
  for j = 1 : length(T)
    if abs(T(i,j)) <= 144
      count = count + 1;
    end
  end
  row = [row;count];
end
