function ndcg_value = ndcg(computed_ratings, original_ratings, at)
ndcg_value = 0; 

for r = 1:size(computed_ratings, 1) % foreach respondent
  
    count = size(computed_ratings(r,:), 2); % number of ratings

    item_computed_ratings = [1:1:count ; computed_ratings(r,:) ]'; % matrix in the form: ITEM : COMPUTED RATING
    item_original_ratings = [1:1:count ; original_ratings(r,:) ]'; % matrix in the form: ITEM : ORIGINAL RATING
    item_original_ratings = item_original_ratings(~any(isnan(item_original_ratings),2),:);
    
    item_computed_ratings = flipdim(sortrows(item_computed_ratings, 2), 1); % sorted, based on the rating, flipdim to sort descending

    dcg = item_original_ratings(item_computed_ratings(1,1), 2); % get 1st item from computed ratings and get original rating for that item
    for i=2:at % start at position 2
        dcg = dcg + item_original_ratings(item_computed_ratings(i,1), 2) / log2(i); % get ith item from computed ratings and get original rating for that item
    end
    
    %trick to calculate idcg:
    item_computed_ratings = flipdim(sortrows(item_original_ratings, 2), 1); % sorted, based on the rating, flipdim to sort descending
    
    idcg = item_original_ratings(item_computed_ratings(1,1), 2); % get 1st item from computed ratings and get original rating for that item
    for i=2:at % start at position 2
        idcg = idcg + item_original_ratings(item_computed_ratings(i,1), 2) / log2(i); % get ith item from computed ratings and get original rating for that item
    end
    if(idcg == 0)
        ndcg_value(r) = 1; % only zero's... Maximum NDCG? (Since all correct?)
    else    
        ndcg_value(r) = dcg/idcg;
    end
    %ndcg_value = ndcg_value + dcg/idcg;
end
ndcg_value = mean(ndcg_value);
%ndcg_value = ndcg_value / r;