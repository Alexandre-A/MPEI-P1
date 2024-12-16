function output_esperado = NaiveBayesOutput(i,non_zero_features,X_test, probsArray,probsArrayClasses,output_esperado,stats,option,numeric_features)
%function output_esperado = NaiveBayesOutput(i,non_zero_features,X_test, probsArray,probsArrayClasses,output_esperado,stats,option,numeric_features)


if nargin ==6
    option = 'NBB';
    stats = [];
    numeric_features = [];
end



P_M = probsArrayClasses(1,:);
P_B = probsArrayClasses(2,:);
p_url_dado_B = probsArray(1,:);
p_url_dado_M = probsArray(2,:);

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


if strcmp(option, 'mixed')
    meanM = stats(1,:);
    meanB = stats(2,:);
    stdM = stats(3,:);
    stdB = stats(4,:);
    for j = 1:length(numeric_features)
        feature_idx = numeric_features(j);
        value = X_test(i, feature_idx);

        probM = probM + logGaussianNB(value, meanM(j), stdM(j));
        probB = probB + logGaussianNB(value, meanB(j), stdB(j));
    end
end

if probM > probB
    output_esperado = [output_esperado, 'malign'];
else
    output_esperado = [output_esperado, 'benign'];
end
end
