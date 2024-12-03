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

%Data splitting
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

%NB implementation
condMalign = classes_train == 'malign';
condBenign = classes_train == 'benign';

numM = sum(condMalign);
numB = sum(condBenign);
[n_ele_train,~] = size(X_train);

P_M = numM/n_ele_train;
P_B = numB/n_ele_train;

non_zero_features = find(sum(X_train) ~= 0); 
Urls_MTr = X_train(condMalign,:);
Urls_BTr = X_train(condBenign,:);

ocorrenciaM = sum(Urls_MTr);
ocorrenciaB = sum(Urls_BTr);

total_Malign = sum(Urls_MTr(:)); 
p_url_dado_M = (ocorrenciaM+1)/(total_Malign+size(X_train, 2));

total_Benign = sum(Urls_BTr(:));
p_url_dado_B = (ocorrenciaB +1)/(total_Benign + size(X_train, 2));




output_esperado = {};
[urlsTeste,~] = size(urls_test);

for i = 1:urlsTeste
    probM = log(P_M);
    probB = log(P_B);

    for p = 1:length(non_zero_features) 
        index = non_zero_features(p);
        if X(i, index) == 1  
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
precision = (C(1))/(C(1)+C(2))
recall = (C(1))/ (C(1)+C(3))

F1 = 2*precision*recall/(precision+recall)



