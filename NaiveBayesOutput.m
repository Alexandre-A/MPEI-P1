function output_esperado = NaiveBayesOutput(i,non_zero_features,X_test,probsArray,probsArrayClasses,output_esperado,option)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin == 4
    option = 'NBB';
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

if probM > probB
    output_esperado = [output_esperado, 'malign'];
else
    output_esperado = [output_esperado, 'benign'];
end
end
