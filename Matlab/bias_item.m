function result = bias_item(original_ratings)

result = original_ratings;

for i = 1:size(original_ratings, 2)
    bias = nanmean(original_ratings(:,i));
    result(:,i) = bias;
end
