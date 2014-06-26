function ratings = center_item(original_ratings)

ratings = original_ratings;

for i = 1:size(ratings, 2)
    bias = nanmean(ratings(:,i));
    for r = 1:size(ratings, 1) % foreach respondent
        if ~isnan(original_ratings(r,i))
            ratings(r,i) = ratings(r,i) - bias;
        end
    end
end

%{
for r = 1:size(ratings, 1) % foreach respondent
    
    for i = 1:size(ratings, 2) % foreach item
        non_zero_count = nnz(original_ratings(:,i));
        bias = 0;
        if(non_zero_count > 0)
            bias = sum(original_ratings(:,i))/non_zero_count;
        end
        
        if(original_ratings(r,i) ~= 0)
            ratings(r,i) = ratings(r,i) - bias;
        end
    end
end
%}