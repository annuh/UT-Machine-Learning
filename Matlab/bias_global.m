function result = bias_global(original_ratings)

% http://stackoverflow.com/questions/12398003/row-normalize-a-sparse-matrix-into-zero-mean-in-matlab
%bias = sum(original_ratings(:))/nnz(original_ratings);
bias = mean(original_ratings(~isnan(original_ratings)));

result = original_ratings;
result(:,:) = bias;