clear all; close all; clc

load('dataset.mat');
original_dataset = dataset;
dataset = sparse(dataset);
spy(dataset)
break;
trainingsetsize=200;
inputsize=50;

trainingset = dataset(1:trainingsetsize,:);
testset = dataset(trainingsetsize+1:end,:);

shuffled_artist_ids = randperm(98);
input_ids=shuffled_artist_ids(1,1:inputsize);
output_ids=shuffled_artist_ids(1,inputsize+1:end);
train_input = trainingset(:,input_ids');
train_output = trainingset(:,output_ids');
test_input = testset(:,input_ids');
test_output = testset(:,output_ids');

%for i=1:50
 %   artist_names(input_ids(i))
  %  train_input(:,i)
   % test_input(:,i)
%end