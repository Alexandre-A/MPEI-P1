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

%% Bloom Filters
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
    BF_malign = BloomAdd2(Urls_MTr{i},BF_malign,kOtimoM);
end

for i=1:length(Urls_BTr)
    BF_benign = BloomAdd2(Urls_BTr{i},BF_benign,kOtimoB);
end

%% Naive bayes algorithm
output_esperado = {};
[N_urlsTeste,~] = size(urls_test);
contadorMalignos = 0;
contadorBenignos = 0;


for i = 1:N_urlsTeste
    result = BloomCheck(urls_test{i},BF_malign,kOtimoM);
    result2 = BloomCheck2(urls_test{i},BF_benign,kOtimoB);

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



%% Bloom Filters
%{
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

BF_malign2 = BloomInit(m_Malign);
BF_benign2 = BloomInit(m_Benign);
falsoNeg2 = 0;
% Bloom Add1 Teste
for i=1:length(Urls_MTr)
    BF_malign = BloomAdd1(Urls_MTr{i},BF_malign,kOtimoM);
    BF_malign2 = BloomAdd2(Urls_MTr{i},BF_malign2,kOtimoM);
end
for i=1:length(Urls_MTr)
    result = BloomCheck(Urls_MTr{i},BF_malign,kOtimoM);
    result2 = BloomCheck2(Urls_MTr{i},BF_malign2,kOtimoM);

    if result == false
        falsoNeg = falsoNeg +1;
    end
    if result2 == false
        falsoNeg2 = falsoNeg2 +1;
    end
end

falsoPos = 0;
falsoPos2 = 0;
for i=1:length(Urls_MTst)
    result = BloomCheck(Urls_MTst{i},BF_malign,kOtimoM);
    if result == true
        falsoPos = falsoPos +1;
    end
    result2 = BloomCheck2(Urls_MTst{i},BF_malign2,kOtimoM);
    if result2 == true
        falsoPos2 = falsoPos2 +1;
    end
end
falsoPosPercent = falsoPos*100/length(Urls_MTst)
falsoPosPercent2 = falsoPos2*100/length(Urls_MTst)



%----------------------------------------------------------------%
for i=1:length(Urls_BTr)
    BF_benign = BloomAdd1(Urls_BTr{i},BF_benign,kOtimoB);
    BF_benign2 = BloomAdd2(Urls_BTr{i},BF_benign2,kOtimoB);
end
for i=1:length(Urls_BTr)
    result = BloomCheck(Urls_BTr{i},BF_benign,kOtimoB);
    result2 = BloomCheck2(Urls_BTr{i},BF_benign2,kOtimoB);

    if result == false
        falsoNeg = falsoNeg +1;
    end
    if result2 == false
        falsoNeg2 = falsoNeg +1;
    end
end

falsoPosB = 0;
falsoPos2B = 0;
for i=1:length(Urls_BTst)
    result = BloomCheck(Urls_BTst{i},BF_benign,kOtimoB);
    if result == true
        falsoPosB = falsoPosB +1;
    end
    result2 = BloomCheck2(Urls_BTst{i},BF_benign2,kOtimoB);
    if result2 == true
        falsoPos2B = falsoPos2B +1;
    end
end

falsoPosPercentB = falsoPosB*100/length(Urls_BTst)
falsoPosPercent2B = falsoPos2B*100/length(Urls_BTst)

%}


