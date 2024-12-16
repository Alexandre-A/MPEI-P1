% Automatization of the gather of csv data

dataSetDate = datevec(dir('urlDataset.csv').date);
matfileDate = datevec(dir('dados.mat').date);

comparison = ~(dataSetDate == matfileDate);
difDateSet = dataSetDate(comparison);
difMatFile = matfileDate(comparison);
if (~isfile('dados.mat') || (difMatFile(1) < difDateSet(1))) 
    csv_extraction('urlDataset.csv','dados')
end

vars = {'dataSetDate','matfileDate','comparison','difDateSet','difMatFile'};
clear(vars{:})
%Disclaimer: In case this is executed, it can take up to 3 minutes 
% to load the entire dataset (max of 3 mins when we use the whole dataset)
%--------------------------------------------------------------------------%

%% Data splitting
load('dados.mat')
percent = 0.8;
train_size = round(length(urls)*percent);
shuffler = randperm(length(urls));

%% 
load('dados.mat')
%%

urls_train = urls(shuffler(1:train_size));
urls_test = urls(shuffler(train_size:end));

classes_train = classes(shuffler(1:train_size));
classes_test = classes(shuffler(train_size:end));

X_train = X(shuffler(1:train_size),:);
X_test = X(shuffler(train_size:end),:);

condMalign = classes_train == 'malign';
condBenign = classes_train == 'benign';

Urls_MTr = urls_train(condMalign);
Urls_BTr = urls_train(condBenign);

Urls_MTst = urls_test(classes_test == 'malign');
Urls_BTst = urls_test(classes_test == 'malign');

%------------------------------------------------------------------%

%% NB implementation (preconditions)
%{
numM = sum(condMalign);
numB = sum(condBenign);
[n_ele_train,~] = size(X_train);

P_M = numM/n_ele_train;
P_B = numB/n_ele_train;

non_zero_features = find(sum(X_train) ~= 0); 
X_Urls_MTr = X_train(condMalign,:);
X_Urls_BTr = X_train(condBenign,:);

ocorrenciaM = sum(X_Urls_MTr);
ocorrenciaB = sum(X_Urls_BTr);

total_Malign = sum(X_Urls_MTr(:)); 
p_url_dado_M = (ocorrenciaM +1)/(total_Malign+size(X_train, 2));

total_Benign = sum(X_Urls_BTr(:));
p_url_dado_B = (ocorrenciaB+ 1)/(total_Benign + size(X_train, 2));
%}


% Teste NBB
binary_features = 1:length(features);

[p_url_dado_M, p_url_dado_B, P_M, P_B, non_zero_features, ~] = ...
  NaiveBayesTrain(X_train, classes_train, binary_features);


%{
% Teste NBMisto
numeric_features = [1,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
binary_features = setdiff(1:length(features),numeric_features);

% Log transformation (handles skewed data)
X_train(:, numeric_features) = log(X_train(:, numeric_features) + 1);
X_test(:, numeric_features) = log(X_test(:, numeric_features) + 1);

% Standardize features (zero mean, unit variance)
X_train(:, numeric_features) = zscore(X_train(:, numeric_features));
X_test(:, numeric_features) = zscore(X_test(:, numeric_features));

[p_url_dado_M, p_url_dado_B, P_M, P_B, non_zero_features, stats] = ...
    NaiveBayesTrain(X_train, classes_train, binary_features,numeric_features);
%}
%% Naive bayes algorithm -> Logic and testing
%{
output_esperado = {};
[urlsTeste,~] = size(urls_test);


for i = 1:urlsTeste
    probM = log(P_M);
    probB = log(P_B);

    for p = 1:length(non_zero_features) 
        index = non_zero_features(p);
        if X_test(i, index) == 1  
            if index <= length(p_url_dado_M) && index <= length(p_url_dado_B) 
                probM = probM + log(p_url_dado_M(index));  
                probB = probB + log(p_url_dado_B(index));    
            end  
        end
    end
    
    if probM > probB
        output_esperado = [output_esperado, 'malign'];
    else
        output_esperado = [output_esperado, 'benign'];
    end
end

output_esperado = output_esperado';

output_esperado = categorical(output_esperado);
erradas = sum(output_esperado ~= classes_test)
error_percent = erradas/(length(classes_test))


C = confusionmat(classes_test,output_esperado)
        
accuracy = (C(1) +C(end))/ sum(C(:))
precision2 = (C(1))/(C(1)+C(2))
recall = (C(1))/ (C(1)+C(3))

F1 = 2*precision2*recall/(precision2+recall)
%}

%%
probsArray =[p_url_dado_B; p_url_dado_M];
probsArrayClasses =[P_M;P_B];
output_esperado = {};
[urlsTeste,~] = size(urls_test);

for i = 1:urlsTeste
    output_esperado = NaiveBayesOutput(i,non_zero_features,X_test,probsArray,probsArrayClasses,output_esperado);
    %output_esperado = NaiveBayesOutput(i,non_zero_features,X_test,probsArray,probsArrayClasses,output_esperado,stats,'mixed',numeric_features);
end
output_esperado = output_esperado';

output_esperado = categorical(output_esperado);
erradas = sum(output_esperado ~= classes_test)
error_percent = erradas/(length(classes_test))


C = confusionmat(classes_test,output_esperado)
        
accuracy = (C(1) +C(end))/ sum(C(:))
precision2 = (C(1))/(C(1)+C(2))
recall = (C(1))/ (C(1)+C(3))

F1 = 2*precision2*recall/(precision2+recall)

%%

[UrlOutput, ~, ~] = UrlInput('NB');
dataTable = cell2table(UrlOutput, 'VariableNames', {'url','type'});
writetable(dataTable, 'urlDatasetTest.csv');

disp('CSV file created: urlDatasetTest.csv');
system('python3 getDataManual.py');

data_test = readcell('urlDatasetTest.csv');
urls_test_manual = data_test(2:end,1);
classes_test_manual = categorical(data_test(2:end,2));

X_test_manual = cell2mat(data_test(2:end,3:end));


output_esperado2 = {};
[tamanho,~] = size(urls_test_manual);

for i = 1:tamanho
    probM = log(P_M);
    probB = log(P_B);

    for p = 1:length(non_zero_features) 
        index = non_zero_features(p);
        if X_test_manual(i, index) == 1  
            if index <= length(p_url_dado_M) && index <= length(p_url_dado_B) 
                probM = probM + log(p_url_dado_M(index));  
                probB = probB + log(p_url_dado_B(index));    
            end  
        end
    end
    
    if probM > probB
        output_esperado2 = [output_esperado2, 'malign'];
    else
        output_esperado2 = [output_esperado2, 'benign'];
    end
end


output_esperado2 = output_esperado2';

output_esperado2 = categorical(output_esperado2);
erradas2 = sum(output_esperado2 ~= classes_test_manual)
error_percent2 = erradas2/(length(classes_test_manual))
%%
C2 = confusionmat(classes_test_manual,output_esperado2)
        
accuracy2 = (C2(1) +C2(end))/ sum(C2(:))
precision2 = (C2(1))/(C2(1)+C2(2))
recall2 = (C2(1))/ (C2(1)+C2(3))

F1_2 = 2*precision2*recall2/(precision2+recall2)

%{
cell2csv('UrlOutput.csv', UrlOutput);
py_lista = py.list(); % Initialize an empty Python list

for i = 1:size(UrlOutput, 1)
    % Append each row of UrlOutput as a Python list
    py_lista.append(py.list(cellstr(UrlOutput(i, :))));
end
py_result = py.getDataManual.testUrlsFeatures(py_lista);
%}

%%
% Example cell array
cellData = {
    'Name', 'Age', 'Score';
    'Alice', 25, 88;
    'Bob', 30, 95;
    'Charlie', 22, 79
};

% Convert the cell array to a table
dataTable = cell2table(cellData(2:end, :), 'VariableNames', cellData(1, :));

% Write the table to a CSV file
writetable(dataTable, 'output.csv');

disp('CSV file created: output.csv');
