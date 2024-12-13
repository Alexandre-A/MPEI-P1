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

urls_train = urls(shuffler(1:train_size));
urls_test = urls(shuffler(train_size:end));

classes_train = classes(shuffler(1:train_size));
classes_test = classes(shuffler(train_size:end));

X_train = X(shuffler(1:train_size),:);
X_test = X(shuffler(train_size:end),:);

%------------------------------------------------------------------%

%% NB implementation (preconditions)
condMalign = classes_train == 'malign';
condBenign = classes_train == 'benign';

numM = sum(condMalign);
numB = sum(condBenign);
[n_ele_train,~] = size(X_train);

P_M = numM/n_ele_train;
P_B = numB/n_ele_train;

non_zero_features = find(sum(X_train) ~= 0); 
X_Urls_MTr = X_train(condMalign,:);
X_Urls_BTr = X_train(condBenign,:);

Urls_MTr = urls_train(condMalign);
Urls_BTr = urls_train(condBenign);

Urls_MTst = urls_test(classes_test == 'malign');
Urls_BTst = urls_test(classes_test == 'malign');


ocorrenciaM = sum(X_Urls_MTr);
ocorrenciaB = sum(X_Urls_BTr);

total_Malign = sum(X_Urls_MTr(:)); 
p_url_dado_M = (ocorrenciaM +1)/(total_Malign+size(X_train, 2));

total_Benign = sum(X_Urls_BTr(:));
p_url_dado_B = (ocorrenciaB+ 1)/(total_Benign + size(X_train, 2));

%% CHECK IF FEATURES ARE GOOD
correlations = zeros(1, size(X_train, 2));
correlations2 = zeros(1, size(X_train, 2));

for i = 1:size(X_train, 2)
    correlations(i) = corr(X_train(:, i), double(classes_train == 'malign'));
    correlations2(i) = corr(X_train(:, i), double(classes_train == 'benign'));

end

disp('Correlation of each feature with the target class:');
disp(correlations);
disp(correlations2);


% Example: Analyze probabilities in Naive Bayes
disp('Top features influencing malign class:');
[~, top_malign_features] = sort(p_url_dado_M, 'descend');
disp(top_malign_features(1:5));

disp('Top features influencing benign class:');
[~, top_benign_features] = sort(p_url_dado_B, 'descend');
disp(top_benign_features(1:5));

%% Bloom Filters -> Implementation and tests
% Values Init
% Number of inserted elements
n_BF_Malign = length(Urls_MTr);
n_BF_Benign = length(Urls_BTr);

p_false_positives_wanted = 0.01;
% Number of elements of the filter
m_Malign = ceil(-n_BF_Malign * log(p_false_positives_wanted) / (log(2)^2));
m_Benign = ceil(-n_BF_Benign * log(p_false_positives_wanted) / (log(2)^2));

m_Malign = nextprime(m_Malign); %To ensure each BF has a prime number of elements
m_Benign = nextprime(m_Benign);

%k ≃ 0.693 * number of elements of the filter/ number of inserted elements
kOtimoM = ceil(0.693*m_Malign/n_BF_Malign); 
kOtimoB = ceil(0.693*m_Benign/n_BF_Benign);

% ------------------BloomFilter setup---------------------------
%BF_malign = BloomInit(m_Malign);
%BF_benign = BloomInit(m_Benign);

BF_malign2 = BloomInit(m_Malign);
BF_benign2 = BloomInit(m_Benign);

% Bloom Add2 Teste
for i=1:length(Urls_MTr)
    %BF_malign = BloomAdd3(Urls_MTr{i},BF_malign,kOtimoM);
    BF_malign2 = BloomAdd3(Urls_MTr{i},BF_malign2,kOtimoM);
end
for i=1:length(Urls_MTr)
    %result = BloomCheck3(Urls_MTr{i},BF_malign,kOtimoM);
    result2 = BloomCheck3(Urls_MTr{i},BF_malign2,kOtimoM);

    %if result == false
    %    falsoNeg = falsoNeg +1;
    %end
    if result2 == false
        falsoNeg2 = falsoNeg +1;
    end
end

%falsoPos = 0;
falsoPos2 = 0;
for i=1:length(Urls_MTst)
        %result = BloomCheck3(Urls_MTst{i},BF_malign,kOtimoM);
        %if result == true
        %    falsoPos = falsoPos +1;
        %end
        result2 = BloomCheck3(Urls_MTst{i},BF_malign2,kOtimoM);
        if result2 == true
            falsoPos2 = falsoPos2 +1;
        end
end
%falsoPosPercent = falsoPos*100/length(Urls_MTst);
falsoPosPercent2 = falsoPos2*100/length(Urls_MTst);



%----------------------------------------------------------------%
for i=1:length(Urls_BTr)
    %BF_benign = BloomAdd3(Urls_BTr{i},BF_benign,kOtimoB);
    BF_benign2 = BloomAdd3(Urls_BTr{i},BF_benign2,kOtimoB);
end
for i=1:length(Urls_BTr)
    %result = BloomCheck3(Urls_BTr{i},BF_benign,kOtimoB);
    result2 = BloomCheck3(Urls_BTr{i},BF_benign2,kOtimoB);

    %if result == false
    %    falsoNeg = falsoNeg +1;
    %end
    if result2 == false
        falsoNeg2 = falsoNeg +1;
    end
end

%falsoPosB = 0;
falsoPos2B = 0;
for i=1:length(Urls_BTst)
        %result = BloomCheck3(Urls_BTst{i},BF_benign,kOtimoB);
        %if result == true
        %    falsoPosB = falsoPosB +1;
        %end
        result2 = BloomCheck3(Urls_BTst{i},BF_benign2,kOtimoB);
        if result2 == true
            falsoPos2B = falsoPos2B +1;
        end
 end

%falsoPosPercentB = falsoPosB*100/length(Urls_BTst);
falsoPosPercent2B = falsoPos2B*100/length(Urls_BTst);

%% Manual testing
%{
[UrlOutput,classesOutput,~] = UrlInput('BF')
[N_urlsTeste,~] = size(UrlOutput);

output_esperado = [];
for i = 1:N_urlsTeste

result = BloomCheck3(UrlOutput{i},BF_malign2,kOtimoM);
result2 = BloomCheck3(UrlOutput{i},BF_benign2,kOtimoB);

    if bitxor(result,result2) == 1
        if result == 1
            contadorMalignos=contadorMalignos+1;
            output_esperado = [output_esperado, 'malign'];
            continue;
        elseif result2 == 1
            contadorBenignos=contadorBenignos+1;
            output_esperado = [output_esperado, 'benign'];
            continue;
        end
    else
        output_esperado = [output_esperado, 'unknown'];
    end
end


size(output_esperado(~strcmp(output_esperado, 'unknown')))
size(classesOutput(~strcmp(output_esperado, 'unknown')))

output_esperadoFiltrado = output_esperado(~strcmp(output_esperado, 'unknown'))';

output_esperadoFiltrado = categorical(cellstr(output_esperadoFiltrado));
erradas = sum(output_esperadoFiltrado ~= classesOutput(~strcmp(output_esperado, 'unknown')))
error_percent = erradas/(length(classesOutput(~strcmp(output_esperado, 'unknown'))))
%}
%%
urls_presentes = urls_test(1:4)
classes_presentes = classes_test(1:4)
%%
% Step 1: Fetch test data from user input
[UrlOutput, classesOutput, ~] = UrlInput('BF');
[N_urlsTeste, ~] = size(UrlOutput);

% Initialize performance counters
truePositivesMalign = 0;
falsePositivesMalign = 0;
trueNegativesMalign = 0;
falseNegativesMalign = 0;

truePositivesBenign = 0;
falsePositivesBenign = 0;
trueNegativesBenign = 0;
falseNegativesBenign = 0;
noneCount =0;

output_esperado = strings(N_urlsTeste, 1);

for i = 1:N_urlsTeste
    % Check URL against Bloom Filters
    resultMalign = BloomCheck3(UrlOutput{i}, BF_malign2, kOtimoM);
    resultBenign = BloomCheck3(UrlOutput{i}, BF_benign2, kOtimoB);

    if xor(resultMalign, resultBenign)
        if resultMalign == 1
            output_esperado(i) = 'malign';
        elseif resultBenign == 1
            output_esperado(i) = 'benign';
        end
    else
        if (resultMalign == 0 &&resultBenign == 0)
            noneCount = noneCount +1;
        end
        output_esperado(i) = 'unknown';
    end
end

% Step 2: Filter "unknown" results for performance metrics
isKnown = ~strcmp(output_esperado, 'unknown');
filteredExpected = categorical(output_esperado(isKnown));
filteredActual = classesOutput(isKnown);

% Step 3: Compute Performance Metrics
confMatrix = confusionmat(filteredActual, filteredExpected);
disp('Confusion Matrix:');
disp(confMatrix);

% Extract counts from confusion matrix
truePositivesMalign = confMatrix(1,1);
falseNegativesMalign = sum(confMatrix(1, :)) - truePositivesMalign;
falsePositivesMalign = sum(confMatrix(:, 1)) - truePositivesMalign;

truePositivesBenign = confMatrix(2,2);
falseNegativesBenign = sum(confMatrix(2, :)) - truePositivesBenign;
falsePositivesBenign = sum(confMatrix(:, 2)) - truePositivesBenign;

% Accuracy
accuracy = sum(diag(confMatrix)) / sum(confMatrix(:));

% Precision, Recall, F1 Score for malign URLs
precisionMalign = truePositivesMalign / (truePositivesMalign + falsePositivesMalign);
recallMalign = truePositivesMalign / (truePositivesMalign + falseNegativesMalign);
f1Malign = 2 * (precisionMalign * recallMalign) / (precisionMalign + recallMalign);

% Precision, Recall, F1 Score for benign URLs
precisionBenign = truePositivesBenign / (truePositivesBenign + falsePositivesBenign);
recallBenign = truePositivesBenign / (truePositivesBenign + falseNegativesBenign);
f1Benign = 2 * (precisionBenign * recallBenign) / (precisionBenign + recallBenign);

% Step 4: Display Results
disp('Performance Metrics:');
fprintf('Accuracy: %.2f%%\n', accuracy * 100);
fprintf('Malign URLs - Precision: %.2f, Recall: %.2f, F1 Score: %.2f\n', precisionMalign, recallMalign, f1Malign);
fprintf('Benign URLs - Precision: %.2f, Recall: %.2f, F1 Score: %.2f\n', precisionBenign, recallBenign, f1Benign);



%%
% Urls presentes nos de treino -> mostrar que estão presentes
% Correr urls de teste com menos urls que o total, para acelerar o processo
% Testagem manual -> se der 0 nos 2 filters: comportamento desejado
%                 -> se de 1 num dos filters: Explicar falsos positivos, e
%                 ver se por acaso acertava a classificação
%                 -> se der 1 em ambos os filters: unknown, por ser ambíguo