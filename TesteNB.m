%%
versao = inputdlg("Escolha o tipo de features a usar (binárias (1) ou mistas(2): ");
if strcmp(versao,'1')
    ficheiro = "urlDataset.csv";
else
    ficheiro = "urlDatasetMisto.csv";
end
%%
% Automatization of the gather of csv data
if ~isfile('dados.mat')
    csv_extraction(ficheiro,'dados')
else
dataSetDate = datevec(dir(ficheiro).date);
matfileDate = datevec(dir('dados.mat').date);

comparison = ~(dataSetDate == matfileDate);
difDateSet = dataSetDate(comparison);
difMatFile = matfileDate(comparison);
if (~isfile('dados.mat') || (difMatFile(1) < difDateSet(1)))
    csv_extraction(ficheiro,'dados')
end
end
vars = {'dataSetDate','matfileDate','comparison','difDateSet','difMatFile'};
clear(vars{:})
%Disclaimer: In case this is executed, it can take up to 3 minutes 
% to load the entire dataset (max of 3 mins when we use the whole dataset)
%--------------------------------------------------------------------------%

% Data splitting
%valuesOutputs = [];
%for i=1:10
load('dados.mat')
percent = 0.8;
train_size = round(length(urls)*percent);
shuffler = randperm(length(urls));

%

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

%% NB implementation (Training)

% Train NBB
if strcmp(versao,'1')
binary_features = 1:length(features);

[p_url_dado_M, p_url_dado_B, P_M, P_B, non_zero_features, ~] = ...
  NaiveBayesTrain(X_train, classes_train, binary_features);

else

% Train NBMisto
numeric_features = [1,4,5,6,7,8,9,10,11,12,13,14,15,16,17]
binary_features = setdiff(1:length(features),numeric_features);

% Log transformation 
% A maioria dos dados numéricos está concentrada na "lower-end"
% (right-skewed). por isso foi aplicada o log, para comprimir o range de
% valores
X_train(:, numeric_features) = log(X_train(:, numeric_features) + 1);
X_test(:, numeric_features) = log(X_test(:, numeric_features) + 1);

% Standardize features 
% Faz com que os dados transformados apresentem média de 0 e desvio padrão
% de 1, removendo diferenças de escalas
X_train(:, numeric_features) = zscore(X_train(:, numeric_features));
X_test(:, numeric_features) = zscore(X_test(:, numeric_features));

[p_url_dado_M, p_url_dado_B, P_M, P_B, non_zero_features, stats] = ...
    NaiveBayesTrain(X_train, classes_train, binary_features,numeric_features);
end
%% Naive bayes algorithm -> Logic and testing
probsArray =[p_url_dado_B; p_url_dado_M];
probsArrayClasses =[P_M;P_B];
output_esperado = {};
[urlsTeste,~] = size(urls_test);

for i = 1:urlsTeste
    if strcmp(versao,'1')
    output_esperado = NaiveBayesOutput(i,non_zero_features,X_test,probsArray,probsArrayClasses,output_esperado);
    else
    output_esperado = NaiveBayesOutput(i,non_zero_features,X_test,probsArray,probsArrayClasses,output_esperado,stats,'mixed',numeric_features);
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

valuesOutputs = [valuesOutputs;accuracy precision2 recall F1];
%end
%VALORES = round(valuesOutputs,4)
%% Naive bayes algorithm -> Manual testing

[UrlOutput, ~, ~] = UrlInput('NB');
dataTable = cell2table(UrlOutput, 'VariableNames', {'url','type'});
writetable(dataTable, 'urlDatasetTest.csv');

disp('CSV file created: urlDatasetTest.csv');

if strcmp(versao,'1')
system('python3 getDataManual.py');
else
system('python3 getDataManualMixed.py');
end


data_test = readcell('urlDatasetTest.csv');
urls_test_manual = data_test(2:end,1);
classes_test_manual = categorical(data_test(2:end,2));

X_test_manual = cell2mat(data_test(2:end,3:end));


output_esperado2 = {};
[tamanho,~] = size(urls_test_manual);

for i = 1:tamanho

    if strcmp(versao,'1')
    output_esperado2 = NaiveBayesOutput(i,non_zero_features,X_test_manual,probsArray,probsArrayClasses,output_esperado2);
    else
    output_esperado2 = NaiveBayesOutput(i,non_zero_features,X_test_manual,probsArray,probsArrayClasses,output_esperado2,stats,'mixed',numeric_features);
    end
end


output_esperado2 = output_esperado2';

output_esperado2 = categorical(output_esperado2);
erradas2 = sum(output_esperado2 ~= classes_test_manual)
error_percent2 = erradas2/(length(classes_test_manual))

C2 = confusionmat(classes_test_manual,output_esperado2)
        
accuracy2 = (C2(1) +C2(end))/ sum(C2(:))
precision2 = (C2(1))/(C2(1)+C2(2))
recall2 = (C2(1))/ (C2(1)+C2(3))

F1_2 = 2*precision2*recall2/(precision2+recall2)

