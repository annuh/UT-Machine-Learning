clear all; close all; clc
load('dataset.mat');
tic
dataset = dataset(1:300,:); % use only good respondents
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
ndcg_values = zeros(size(k_options,2), 2);
rmse_values = zeros(size(k_options,2), 2);
plotStyle = {'b','k','g','c', 'm'}; % add as many as you need

% Split data in trainingset
[trainInd, valInd, testInd] = dividerand(size(original_dataset,1), 0.67, 0, 0.33);
trainingset = original_dataset(trainInd,:);
testset = original_dataset(testInd,:);

% For every center method
for center_option = [1:5]
    fprintf('Starting center option %d \n', center_option);
    for k = k_options
        fprintf('-');
    end
    fprintf('\n');
    
    % For every dimension (as there are artists = minimum dimension size)
    for k = k_options
        %fprintf('%d for dimension %d \n', center_option, k); 

        rmse_value = 0;
        ndcg_value = 0; % Init ndcg-value, since we increment with every iteration in leave-one-out
         
        for iteration=1:iterations
           % Start training with leave-one-out
           lou_iteration = 0;
           for r=1:size(trainingset,1)
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
                    case 2
                        %lou_training = center_global(lou_training);
                        %original_center = center_global(original_dataset);
                        bias = bias_global(lou_training);
                    case 3
                        %lou_training = center_user(lou_training);
                        %original_center = center_user(original_dataset);
                        bias = bias_user(lou_training);
                    case 4
                        %lou_training = center_item(lou_training);
                        %original_center = center_item(original_dataset);
                        bias = bias_item(lou_training);
                    case 5
                        bias = bias_shrinkage_user(lou_training, 1);
                    otherwise
                        %original_center = original_dataset;
                        bias=lou_training;
                        bias(:,:) = 0;
                        % do nothing
                end
                
                lou_training = lou_training - bias;
                original_center = trainingset - bias;
                
                lou_training(isnan(lou_training)) = 0;

                %lou_training(r,random_ids)=0;
                [U, S, V, status] = lansvd(sparse(lou_training), k);
                %status
                %V = V';
                matrix_US = U*(sqrt(S))';
                matrix_SV = sqrt(S)*V';
                
                for item = 1:98
                    rating = bias(r,item) + matrix_US(r,:) * matrix_SV(:,item);
                    
                    if(rating < 1)
                        rating = 1;
                    elseif(rating > 10)
                        rating = 10;
                    end;
                    
                    computed_dataset(r,item) = rating;
                end
                
              %computed_dataset(r,random_ids)
              %trainingset(r,random_ids)
                
                %computed_dataset = U*S*V';
                %computed_dataset = (computed_dataset');
                %computed_dataset = simon_funk(lou_training, k);
              %  ndcg_value = ndcg_value + ndcg(computed_dataset(r,random_ids), original_center(r,random_ids), 10);
                rmse_value = rmse_value + rmse(computed_dataset(r,random_ids), trainingset(r,random_ids));

           end
           ndcg_value = ndcg_value/lou_iteration;
           rmse_value = rmse_value/lou_iteration;

        end
        ndcg_value = ndcg_value/iterations;
        rmse_value = rmse_value/iterations;

        % Compute avarage ndcg for current dimension
        ndcg_values(k,:) = [k, ndcg_value];
        rmse_values(k,:) = [k, rmse_value];
      %  fprintf('RMSE @ %d = %.2f \n', k, rmse(k)); 
      fprintf('.'); 
      
    end
    fprintf(' | Ready \n'); 

    %plot(ndcg_values(:,1), ndcg_values(:,2), plotStyle{center_option}); hold on;
    plot(rmse_values(:,1), rmse_values(:,2), plotStyle{center_option}); hold on;

end

legend('no', 'global', 'user', 'item', 'shrinkage', 'Location', 'SouthEast');

%plot(rmse_values(:,1), rmse_values(:,2))
toc