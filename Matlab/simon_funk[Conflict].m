function ratings = simon_funk(original_ratings, dimensions)

% See: http://www.timelydevelopment.com/demos/NetflixPrize.aspx

% Variables
global max_features;    max_features = dimensions;
global init;            init = 0.1;

min_epochs = 2;
max_epochs = 16;
min_improvement = 0.001;
lrate = 0.01;
k = 0.015;

respondent_count = size(original_ratings, 1);
item_count = size(original_ratings, 2);
rating_count = 0;

data = [];
for r=1:respondent_count
    for i=1:item_count
        rating = original_ratings(r,i);
        if(rating > 0)
            data = [data; [r, i, rating, 0]];
            rating_count = rating_count + 1;
        end    
     end
end

ratings = zeros(respondent_count, item_count);
global item_features;       item_features = zeros(max_features, item_count);
global respondent_features; respondent_features = zeros(max_features, respondent_count);

% Init
item_features(:,:) = init;
respondent_features(:,:) = init;

% CalcFeatures
rmse_last = 2.0;
rmse = 2.0;

for f=1:max_features
    for e=1:max_epochs
        sq = 0;
        rmse_last = rmse;
        
        
        for r=1:rating_count
           % for i=1:item_count
           
           respondent = data(r,1);
           item = data(r,2);
           rating = data(r,3);
               
            % Predict rating
            p = simon_funk_predict_rating(data(r,:), f, 1);
            err = (1.0 * rating - p);
            sq = sq + err*err;

            rf = respondent_features(f,respondent);
            mf = item_features(f, item);

            % Cross-train the features
            respondent_features(f, respondent) = respondent_features(f,respondent) + (lrate * (err * mf - k * rf));
            item_features(f, item) = item_features(f, item) + (lrate * (err * rf - k * mf));
           % end
        end
        
        rmse = sqrt(sq/rating_count);

        %if (e >= min_epochs && rmse > (rmse_last - min_improvement))
        if ((e >= min_epochs) && ((rmse_last - rmse) < min_improvement))
            break;
        end
    end
    % Caching
    for r=1:rating_count
        data(r, 4) = simon_funk_predict_rating(data(r,:), f, 0);
    end 
end

% return new ratings set
for r=1:respondent_count
    for i=1:item_count
        sum = 1;
        
        for f=1:max_features
            sum = sum + item_features(f,i) * respondent_features(f,r);
            if(sum > 10)
            %    sum = 10;
            end
            
            if(sum < 1)
             %   sum = 1;
            end
            
        end
        ratings(r,i) = sum;
    end
end
