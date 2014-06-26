function ratings = center_global(original_ratings)

% http://stackoverflow.com/questions/12398003/row-normalize-a-sparse-matrix-into-zero-mean-in-matlab
%bias = sum(original_ratings(:))/nnz(original_ratings);
bias = mean(original_ratings(~isnan(original_ratings)));
ratings = original_ratings;

for r = 1:size(original_ratings, 1) % foreach respondent
    for i = 1:size(original_ratings, 2) % foreach item
        if(~isnan(original_ratings(r,i)))
            ratings(r,i) = ratings(r,i) - bias;
        end
    end
end