clear all; close all; clc
load('dataset.mat');

dataset = dataset(1:300,:); % use only good respondents
original_dataset = dataset; % Original dataset - Never changes!
original_dataset(original_dataset==0) = NaN;

% k_options = number of dimensions (X-axis on the plot)
k_options = 1:5:50;

% - Init
rmse_values = zeros(size(k_options,2), 2);

% Split data in trainingset
[trainInd, valInd, testInd] = dividerand(size(original_dataset,1), 0.67, 0, 0.33);
trainingset = original_dataset(trainInd,:);
testset = original_dataset(testInd,:);
  
    % For every dimension (as there are artists = minimum dimension size)
iteration = 1

iters = 3;        
user_count = size(trainingset, 1);


for k = k_options
    rmse_value = 0;

    for iter = 1:iters
       random_ids = randperm(98,10);

        for r=1:user_count
            lou_training = trainingset; % trainingset for this leave-one-out iteration

            lou_training(r,random_ids)=NaN;
            bias = bias_shrinkage_user(lou_training, k);
            lou_training = lou_training - bias;
            lou_training(isnan(lou_training)) = 0;
            [U, S, V, status] = lansvd(sparse(lou_training), 10);
            matrix_US = U*(sqrt(S))';
            matrix_SV = sqrt(S)*V';

            for item = 1:98
                rating = bias(r,item) + matrix_US(r,:) * matrix_SV(:,item);
                computed_dataset(r,item) = rating;
            end
            rmse_value = rmse_value + rmse(computed_dataset(r,random_ids), trainingset(r,random_ids));

        end
    end
    %rmse_value = rmse_value/(user_count*iters);

    iteration = iteration + 1

    rmse_values(iteration,:) = [k, rmse_value];
end 
    

      
   
   