function ratings = shrinkage_user(original_ratings)

ratings = original_ratings;
global_mean = mean(original_ratings(~isnan(original_ratings)));
degree = 1;

for r = 1:size(ratings, 1) % foreach respondent
    %bias = nanmean(original_ratings(r,:));
    user_mean = nanmean(original_ratings(r,:));
    ratings_size = sum(~isnan(original_ratings(r,:)));
    bias = degree/(degree+ratings_size) * global_mean + ratings_size/(degree+ratings_size)*user_mean; 
    for i = 1:size(ratings, 2) % foreach item
        if(~isnan(original_ratings(r,i)))
            ratings(r,i) = ratings(r,i) - bias;
        end
    end
end