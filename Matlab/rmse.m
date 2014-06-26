function rmse_value = rmse(computed_ratings, original_ratings) 
n = 0; e = 0; 

for u=1:size(computed_ratings(:,1), 1)     % for every user 
    for i=1:size(computed_ratings(1,:), 2)     % for every item 
        if(~isnan(original_ratings(u,i))) 
            n = n+1; 
            e = e+(original_ratings(u,i) - computed_ratings(u,i))^2; 
        end
    end
end
if(n == 0)
    rmse_value = 0;
else
    rmse_value = sqrt(e/n);
end