function result = bias_user(original_ratings)

result = original_ratings;

for r = 1:size(original_ratings, 1) % foreach respondent
    bias = nanmean(original_ratings(r,:));
    result(r,:) = bias;
end

