function [p_url_dado_M, p_url_dado_B, P_M, P_B, non_zero_features, stats] = ...
    NaiveBayesTrain(X_train, y_train, binary_features,numeric_features)
%[p_url_dado_M, p_url_dado_B, P_M, P_B, non_zero_features, stats] = ...
%NaiveBayesTrain(X_train, y_train, binary_features,numeric_features)

mode = 'Mixed';
if nargin == 3
    numeric_features = [];
    mode = 'None';
end

    X_M = X_train(y_train == 'malign', :);
    X_B = X_train(y_train == 'benign', :);

    numM = size(X_M, 1);
    numB = size(X_B, 1);
    total = size(X_train, 1);
    P_M = numM / total;
    P_B = numB / total;

    % Binary features probabilities
    non_zero_features = find(sum(X_train(:, binary_features)) ~= 0);
    ocorrenciaM = sum(X_M(:, binary_features));
    ocorrenciaB = sum(X_B(:, binary_features));
    total_Malign = sum(X_M(:, binary_features), 'all');
    total_Benign = sum(X_B(:, binary_features), 'all');
    p_url_dado_M = (ocorrenciaM + 1) / (total_Malign + length(binary_features));
    p_url_dado_B = (ocorrenciaB + 1) / (total_Benign + length(binary_features));

    if ~strcmp(mode,'None')
    meanM = mean(X_M(:, numeric_features), 1);
    stdM = std(X_M(:, numeric_features), 1);
    meanB = mean(X_B(:, numeric_features), 1);
    stdB = std(X_B(:, numeric_features), 1);

    stats = [meanM; meanB; stdM; stdB];
    else
    stats = [];
    end

end