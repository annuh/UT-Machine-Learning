clear all; close all; clc
load('dataset.mat');
original_dataset = dataset; % Original dataset - Never changes!
original_dataset(original_dataset==0) = NaN;
%ratings= [2,3,2,8,9,9;2,3,2,8,9,9;2,3,2,8,9,9;2,3,2,8,9,9;2,3,2,8,9,9;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3;8,9,9,3,2,3.0921];
predicted_array(1)=0;
dimensions=10
for d=1:dimensions
    for j=1:length(original_dataset)
        j
        ratings=original_dataset;
        user_lo=j;
        ratings(user_lo,1)=NaN;
        user_avgs=nanmean(ratings');
        ratingsize=size(ratings);


        for i=1:ratingsize(2)
           centered_ratings(:,i)=ratings(:,i)-user_avgs';
        end
        centered_ratings(isnan(centered_ratings))=0;
        %centered_ratings=sparse(centered_ratings);
        [U,S,V] = svds(centered_ratings,d);

        US = U*(sqrt(S))';
        SV = sqrt(S)*V';

        predicted=user_avgs(user_lo)+(US(user_lo,d)*SV(d,1));
        predicted_array(j)=predicted;
    end

    error=original_dataset(:,1)-predicted_array';
    rmse(d)=sqrt(mse(error))
end
