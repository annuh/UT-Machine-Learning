function result = bias_shrinkage_user(original_ratings, degree)

result = original_ratings;
global_mean = mean(original_ratings(~isnan(original_ratings)));

for r = 1:size(result, 1) % foreach respondent
    user_mean = nanmean(original_ratings(r,:));
    ratings_size = sum(~isnan(original_ratings(r,:)));
    bias = degree/(degree+ratings_size) * global_mean + ratings_size/(degree+ratings_size)*user_mean; 

    result(r,:) = bias;
end