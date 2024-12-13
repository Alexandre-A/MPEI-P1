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

BF_malign2 = BloomInit(m_Malign);
BF_benign2 = BloomInit(m_Benign);



% Assume Urls_MTr and kOtimoM are already defined
% Urls_MTr: List of URLs to insert into Bloom filters
% kOtimoM: Optimal number of hash functions for BF_malign

% Initialize the Bloom filters
BF_malign = BloomInit(m_Malign);  % Bloom filter using BloomAdd1
BF_malign2 = BloomInit(m_Malign); % Bloom filter using BloomAdd2

% Populate BF_malign using BloomAdd1
for i = 1:length(Urls_MTr)
    BF_malign = BloomAdd1(Urls_MTr{i}, BF_malign, kOtimoM);
end

% Populate BF_malign2 using BloomAdd2
for i = 1:length(Urls_MTr)
    BF_malign2 = BloomAdd2(Urls_MTr{i}, BF_malign2, kOtimoM);
end

% ----------------- Uniformity Analysis -----------------
% Define the number of regions for analysis
numRegions = 10;

% Calculate the size of each region
regionSize = floor(length(BF_malign) / numRegions);

% Initialize arrays to store counts of 1s in each region
regionCounts1 = zeros(1, numRegions);
regionCounts2 = zeros(1, numRegions);

% Compute the number of 1s in each region for both Bloom filters
for i = 1:numRegions
    startIdx = (i-1)*regionSize + 1;
    endIdx = min(i*regionSize, length(BF_malign)); % Ensure we don't go out of bounds
    
    regionCounts1(i) = sum(BF_malign(startIdx:endIdx));
    regionCounts2(i) = sum(BF_malign2(startIdx:endIdx));
end

% Plot the distributions
figure;

subplot(2,1,1);
bar(regionCounts1, 'FaceColor', [0.2 0.6 0.8]); % BF_malign distribution
title('Uniformity of BF\_malign');
xlabel('Region');
ylabel('Number of 1s');
grid on;

subplot(2,1,2);
bar(regionCounts2, 'FaceColor', [0.8 0.4 0.2]); % BF_malign2 distribution
title('Uniformity of BF\_malign2');
xlabel('Region');
ylabel('Number of 1s');
grid on;

% Calculate variance and standard deviation
variance1 = var(regionCounts1);
variance2 = var(regionCounts2);

stdDev1 = std(regionCounts1);
stdDev2 = std(regionCounts2);

% Display statistics
fprintf('Variance of BF_malign: %.4f\n', variance1);
fprintf('Standard Deviation of BF_malign: %.4f\n', stdDev1);
fprintf('Variance of BF_malign2: %.4f\n', variance2);
fprintf('Standard Deviation of BF_malign2: %.4f\n', stdDev2);
%{
% Bloom Add1 Teste
for i=1:length(Urls_MTr)
    %BF_malign = BloomAdd1(Urls_MTr{i},BF_malign,kOtimoM);
    BF_malign2 = BloomAdd2(Urls_MTr{i},BF_malign2,kOtimoM);
end
for i=1:length(Urls_MTr)
    %result = BloomCheck(Urls_MTr{i},BF_malign,kOtimoM);
    result2 = BloomCheck2(Urls_MTr{i},BF_malign2,kOtimoM);

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
        %result = BloomCheck(Urls_MTst{i},BF_malign,kOtimoM);
        %if result == true
        %    falsoPos = falsoPos +1;
        %end
        result2 = BloomCheck2(Urls_MTst{i},BF_malign2,kOtimoM);
        if result2 == true
            falsoPos2 = falsoPos2 +1;
        end
end
%falsoPosPercent = falsoPos*100/length(Urls_MTst);
falsoPosPercent2 = falsoPos2*100/length(Urls_MTst);



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

falsoPosPercentB = falsoPosB*100/length(Urls_BTst);
falsoPosPercent2B = falsoPos2B*100/length(Urls_BTst);
%}