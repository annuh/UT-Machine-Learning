function sum = simon_funk_predict_rating(rating, f, bTrailing)
global item_features;
global respondent_features;
global max_features;
global init;
respondent = rating(1,1);
item = rating(1,2);
cache_value = rating(1,4);

sum = 1;
if(cache_value > 0)
    sum = cache_value;
end

sum = sum + (item_features(f,item) * respondent_features(f,respondent));

if (sum > 10) 
    %sum = 10;
end

if (sum < 1) 
    %sum = 1;
end


if (bTrailing == 1)
    sum = sum + (max_features - f - 1) * (init * init);
    if (sum > 10) 
        %sum = 10;
    end
    if (sum < 1) 
        %sum = 1;
    end
end