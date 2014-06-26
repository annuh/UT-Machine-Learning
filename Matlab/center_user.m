function ratings = center_user(original_ratings)

ratings = original_ratings;

for r = 1:size(ratings, 1) % foreach respondent
    bias = nanmean(original_ratings(r,:));
    
    for i = 1:size(ratings, 2) % foreach item
        if(~isnan(original_ratings(r,i)))
            ratings(r,i) = ratings(r,i) - bias;
        end
    end
end