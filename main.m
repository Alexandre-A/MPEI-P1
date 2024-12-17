versao = inputdlg("Escolha o tipo de features a usar (binárias (1) ou mistas(2): ");
if strcmp(versao,'1')
    ficheiro = "urlDataset.csv";
else
    ficheiro = "urlDatasetMisto.csv";
end
%%
% Automatization of the gather of csv data
%CORRIGIR ORDEM DESTA PARTE
dataSetDate = datevec(dir(ficheiro).date);
matfileDate = datevec(dir('dados.mat').date);

comparison = ~(dataSetDate == matfileDate);
difDateSet = dataSetDate(comparison);
difMatFile = matfileDate(comparison);
if (~isfile('dados.mat') || (difMatFile(1) < difDateSet(1)))
    csv_extraction(ficheiro,'dados')
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
X_train(:, numeric_features) = log(X_train(:, numeric_features) + 1);
X_test(:, numeric_features) = log(X_test(:, numeric_features) + 1);

% Standardize features 
X_train(:, numeric_features) = zscore(X_train(:, numeric_features));
X_test(:, numeric_features) = zscore(X_test(:, numeric_features));

[p_url_dado_M, p_url_dado_B, P_M, P_B, non_zero_features, stats] = ...
    NaiveBayesTrain(X_train, classes_train, binary_features,numeric_features);
end

%% Bloom Filters (Inicialização)
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
BF_malign = BloomInit(m_Malign);
BF_benign = BloomInit(m_Benign);

for i=1:length(Urls_MTr)
    BF_malign = BloomAdd3(Urls_MTr{i},BF_malign,kOtimoM);
end

for i=1:length(Urls_BTr)
    BF_benign = BloomAdd3(Urls_BTr{i},BF_benign,kOtimoB);
end

%% Main logic
probsArray =[p_url_dado_B; p_url_dado_M];
probsArrayClasses =[P_M;P_B];
utput_esperado = {};
[N_urlsTeste,~] = size(urls_test);
contadorMalignos = 0;
contadorBenignos = 0;


for i = 1:N_urlsTeste
    result = BloomCheck3(urls_test{i},BF_malign,kOtimoM);
    result2 = BloomCheck3(urls_test{i},BF_benign,kOtimoB);

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
        if strcmp(versao,'1')
            output_esperado = NaiveBayesOutput(i,non_zero_features,X_test,probsArray,probsArrayClasses,output_esperado);
        else
            output_esperado = NaiveBayesOutput(i,non_zero_features,X_test,probsArray,probsArrayClasses,output_esperado,stats,'mixed',numeric_features);
        end

        %{
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
        %}
    end
end

size(output_esperado)
size(classes_test)

output_esperado = output_esperado';

output_esperado = categorical(output_esperado);
erradas = sum(output_esperado ~= classes_test)
error_percent = erradas/(length(classes_test))


C = confusionmat(classes_test,output_esperado)

accuracy = (C(1) +C(end))/ sum(C(:))
precision = (C(1))/(C(1)+C(2))
recall = (C(1))/ (C(1)+C(3))

F1 = 2*precision*recall/(precision+recall)
