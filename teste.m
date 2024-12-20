% Automatization of the gather of csv data
if ~isfile('dados.mat')
    csv_extraction('urlDataset.csv','dados')
else
dataSetDate = datevec(dir('urlDataset.csv').date);
matfileDate = datevec(dir('dados.mat').date);

comparison = ~(dataSetDate == matfileDate);
difDateSet = dataSetDate(comparison);
difMatFile = matfileDate(comparison);
if (~isfile('dados.mat') || (difMatFile(1) < difDateSet(1))) 
    csv_extraction('urlDataset.csv','dados')
end
end
vars = {'dataSetDate','matfileDate','comparison','difDateSet','difMatFile'};
clear(vars{:})
%Disclaimer: In case this is executed, it can take up to 3 minutes 
% to load the entire dataset (max of 3 mins when we use the whole dataset)
%--------------------------------------------------------------------------%

% Data splitting
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

condMalign = classes_train == 'malign';
condBenign = classes_train == 'benign';

numM = sum(condMalign);
numB = sum(condBenign);

X_Urls_MTr = X_train(condMalign,:);
X_Urls_BTr = X_train(condBenign,:);

Urls_MTr = urls_train(condMalign);
Urls_BTr = urls_train(condBenign);

Urls_MTst = urls_test(classes_test == 'malign');
Urls_BTst = urls_test(classes_test == 'malign');
%------------------------------------------------------------------%

%% Bloom Filters -> Implementation and tests
% Values Init
% Number of inserted elements
falsoNeg2 = 0;
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


BF_malign2 = BloomInit(m_Malign);
BF_benign2 = BloomInit(m_Benign);

% Bloom Add2 Teste
for i=1:length(Urls_MTr)
    BF_malign2 = BloomAdd3(Urls_MTr{i},BF_malign2,kOtimoM);
end
for i=1:length(Urls_MTr)
    result2 = BloomCheck3(Urls_MTr{i},BF_malign2,kOtimoM);

    if result2 == false
        falsoNeg2 = falsoNeg +1;
    end
end


%----------------------------------------------------------------%
for i=1:length(Urls_BTr)
    BF_benign2 = BloomAdd3(Urls_BTr{i},BF_benign2,kOtimoB);
end
for i=1:length(Urls_BTr)
    result2 = BloomCheck3(Urls_BTr{i},BF_benign2,kOtimoB);

    if result2 == false
        falsoNeg2 = falsoNeg +1;
    end
end


%% Uniformidade de funções de hash
BF_malignteste = BloomInit(m_Malign);  % Bloom filter using BloomAdd1
BF_malignteste2 = BloomInit(m_Malign); % Bloom filter using BloomAdd2

%Using BloomAdd1 (old version)
for i = 1:length(Urls_MTr)
    BF_malignteste = BloomAdd1(Urls_MTr{i}, BF_malignteste, kOtimoM);
end

%Using BloomAdd3
for i = 1:length(Urls_MTr)
    BF_malignteste2 = BloomAdd3(Urls_MTr{i}, BF_malignteste2, kOtimoM);
end

numRegions = 100;

regionSize = floor(length(BF_malignteste) / numRegions);

regionCounts1 = zeros(1, numRegions);
regionCounts2 = zeros(1, numRegions);

% Número de 1s por região
for i = 1:numRegions
    startIdx = (i-1)*regionSize + 1;
    endIdx = min(i*regionSize, length(BF_malignteste)); 
    
    regionCounts1(i) = sum(BF_malignteste(startIdx:endIdx));
    regionCounts2(i) = sum(BF_malignteste2(startIdx:endIdx));
end

figure(1);

subplot(2,2,1);
bar(regionCounts1, 'FaceColor', [0.2 0.6 0.8]); % BF_malign 
title('Uniformidade do BF\_malign');
xlabel('Região');
ylabel('Número de 1s');
grid on;

subplot(2,2,2);
bar(regionCounts2, 'FaceColor', [0.8 0.4 0.2]); % BF_malign2 
title('Uniformidade do BF\_malign2');
xlabel('Região');
ylabel('Número de 1s');
grid on;

figure(2);
subplot(2,1,2);
bar(regionCounts2, 'FaceColor', [0.8 0.4 0.2]); % BF_malign2 
title('Uniformidade do BF\_malign2');
xlabel('Região');
ylabel('Número de 1s');
grid on;

% Comparação de uniformidade das funções de hash - benign
BF_benignteste = BloomInit(m_Benign);  % Bloom filter using BloomAdd1
BF_benignteste2 = BloomInit(m_Benign); % Bloom filter using BloomAdd3

%Using BloomAdd1 (old version)
for i = 1:length(Urls_BTr)
    BF_benignteste = BloomAdd1(Urls_BTr{i}, BF_benignteste, kOtimoB);
end

%Using BloomAdd3
for i = 1:length(Urls_BTr)
    BF_benignteste2 = BloomAdd3(Urls_BTr{i}, BF_benignteste2, kOtimoB);
end


numRegions = 100;

regionSize = floor(length(BF_benignteste) / numRegions);

regionCounts1 = zeros(1, numRegions);
regionCounts2 = zeros(1, numRegions);

% Número de 1s por região
for i = 1:numRegions
    startIdx = (i-1)*regionSize + 1;
    endIdx = min(i*regionSize, length(BF_benignteste)); 
    
    regionCounts1(i) = sum(BF_benignteste(startIdx:endIdx));
    regionCounts2(i) = sum(BF_benignteste2(startIdx:endIdx));
end

figure(1);

subplot(2,2,3);
bar(regionCounts1, 'FaceColor', [0.2 0.6 0.8]); % BF_benign 
title('Uniformidade do BF\_benign');
xlabel('Região');
ylabel('Número de 1s');
grid on;

subplot(2,2,4);
bar(regionCounts2, 'FaceColor', [0.8 0.4 0.2]); % BF_benign2
title('Uniformidade do BF\_benign2');
xlabel('Região');
ylabel('Número de 1s');
grid on;


% Comparação de uniformidade das funções de hash - malign vs benign
figure(2);
subplot(2,1,1);
bar(regionCounts2, 'FaceColor', [0.8 0.4 0.2]); % BF_benign2
title('Uniformidade do BF\_benign2');
xlabel('Região');
ylabel('Número de 1s');
grid on;


%% Testing Bloom Filter
% Testing Malign Bloom Filter only with malign URLs
falsoPos2 = 0;
for i=1:length(Urls_MTst)
        result2 = BloomCheck3(Urls_MTst{i},BF_malign2,kOtimoM);
        if result2 == true
            falsoPos2 = falsoPos2 +1;
        end
end
falsoPosPercent2M = falsoPos2*100/length(Urls_MTst)


% Testing Benign Bloom Filter only with benign URLs

falsoPos2B = 0;
for i=1:length(Urls_BTst)
        result2 = BloomCheck3(Urls_BTst{i},BF_benign2,kOtimoB);
        if result2 == true
            falsoPos2B = falsoPos2B +1;
        end
 end

falsoPosPercent2B = falsoPos2B*100/length(Urls_BTst)


%% Testing Both Bloom Filters with all test URLs
totalFP = 0;
[N_urlsTeste,~] = size(urls_test);
falsoPos2B =0;
falsoPos2M =0;

for i = 1:N_urlsTeste
    result = BloomCheck3(urls_test{i},BF_malign2,kOtimoM);
    result2 = BloomCheck3(urls_test{i},BF_benign2,kOtimoB);
    if result2 == true
        totalFP = totalFP +1;
        falsoPos2B = falsoPos2B +1;
    end
    if result == true
        totalFP = totalFP +1;
        falsoPos2M = falsoPos2M +1;
    end

end
falsoPosPercent2B = falsoPos2B*100/length(urls_test)
falsoPosPercent2M = falsoPos2M*100/length(urls_test)
totalFP

%% Manual testing
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

isKnown = ~strcmp(output_esperado, 'unknown') %Quantos eram identificados pelos BF
% na aplicação conjunta
filteredExpected = categorical(output_esperado(isKnown));
filteredActual = classesOutput(isKnown);

%Avaliar a prestação da classificação resultante da determinação direta
%pelos BF
if length(isKnown)>0
confMatrix = confusionmat(filteredActual, filteredExpected);
disp('Confusion Matrix:');
disp(confMatrix);

truePositivesMalign = confMatrix(1,1);
falseNegativesMalign = sum(confMatrix(1, :)) - truePositivesMalign;
falsePositivesMalign = sum(confMatrix(:, 1)) - truePositivesMalign;

truePositivesBenign = confMatrix(2,2);
falseNegativesBenign = sum(confMatrix(2, :)) - truePositivesBenign;
falsePositivesBenign = sum(confMatrix(:, 2)) - truePositivesBenign;

accuracy = sum(diag(confMatrix)) / sum(confMatrix(:));

fprintf('Accuracy: %.2f%%\n', accuracy * 100);
end

% Urls presentes nos de treino -> mostrar que estão presentes
% Correr urls de teste com menos urls que o total, para acelerar o processo
% Testagem manual -> se der 0 nos 2 filters: comportamento desejado
%                 -> se de 1 num dos filters: Explicar falsos positivos, e
%                 ver se por acaso acertava a classificação
%                 -> se der 1 em ambos os filters: unknown, por ser ambíguo