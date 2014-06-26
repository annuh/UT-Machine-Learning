clear all; close all; clc
load('dataset.mat');
tic 

%dataset = dataset(1:300,:); % use only good respondents
original_dataset = dataset; % Original dataset - Never changes!
original_dataset(original_dataset==0) = NaN;

% Iterations - Number of iterations inside every leave-one-out iteration
iterations = 1;

% center_options = different plots
center_options = ['no', 'global', 'user', 'item', 'shrinkage'];

% k_options = number of dimensions (X-axis on the plot)
k_options = 1:20;

% lou_iteration - Number of lou iteration, 0 for complete trainingset
lou_iterations = 0;

% - Init
rmse_values = zeros(size(k_options,2), 2);
plotStyle = {'b','k','g','c', 'm'}; % add as many as you need

% Split data in trainingset
[trainInd, valInd, testInd] = dividerand(size(original_dataset,1), 0.67, 0, 0.33);
trainingset = original_dataset(trainInd,:);
testset = original_dataset(testInd,:);
break;

item_count = size(trainingset, 2);
user_count = size(trainingset,1);


for center_option = 1:5 % For every center method
    
    fprintf('Starting center option %d \n', center_option);
    for k = k_options fprintf('-'); end; fprintf('\n');
    
    % For every dimension (as there are artists = minimum dimension size)
    for k = k_options
        rmse_value = 0;
        
        for iteration=1:iterations
           % Start training with leave-one-out
           lou_iteration = 0;
           for r=1:user_count
                lou_iteration = lou_iteration + 1;
                % Check if enough iterations have been made
                if(lou_iterations > 0 && lou_iteration > lou_iterations)
                    break;
                end
                
                lou_training = trainingset; % trainingset for this leave-one-out iteration
                % Reset 25 random ratings from users rating set
                random_ids = randperm(98,10);
                lou_training(r,random_ids)=NaN;

                switch center_option
                    case 2 % global
                        bias = mean(lou_training(~isnan(lou_training)));
                        bias = repmat(bias, user_count, item_count);
                    case 3 % user
                        bias = nanmean(lou_training, 2);
                        bias = repmat(bias, 1, item_count);
                    case 4 % item
                        bias = nanmean(lou_training, 1);
                        bias = repmat(bias, user_count, 1);
                    case 5 % shrinkage
                        bias = bias_shrinkage_user(lou_training, 1);
                    otherwise % do nothing
                        bias = zeros(user_count, item_count);
                end;
                lou_training = lou_training - bias;                
                
                lou_training(isnan(lou_training)) = 0; % Set all unknown and removed ratings to 0 for the sparse method
                options.tol = 0.0001;
                [U, S, V, status] = lansvd(sparse(lou_training), k, 'L', options);
                %[U, S, V, status] = lansvd(sparse(lou_training), k);
                matrix_US = U*(sqrt(S))';
                matrix_SV = sqrt(S)*V';
                
                computed_dataset=trainingset(r,:);
                %for item = 1:98
                for item = random_ids    
                    rating = bias(r,item) + matrix_US(r,:) * matrix_SV(:,item);
                    
                    if(rating < 1)
                        rating = 1;
                    elseif(rating > 10)
                        rating = 10;
                    end;
                    
                    computed_dataset(item) = rating;
                end
              %computed_dataset(r,random_ids)
              %trainingset(r,random_ids)
              rmse_value = rmse_value + rmse(computed_dataset(random_ids), trainingset(r,random_ids));

           end
           rmse_value = rmse_value/lou_iteration;

        end
        rmse_value = rmse_value/iterations;

        % Compute avarage ndcg for current dimension
        rmse_values(k,:) = [k, rmse_value];
        fprintf('.'); 
    end
    fprintf(' | Ready \n'); 

    plot(rmse_values(:,1), rmse_values(:,2), plotStyle{center_option}); hold on;
end
legend('no', 'global', 'user', 'item', 'shrinkage', 'Location', 'SouthEast');
toc
