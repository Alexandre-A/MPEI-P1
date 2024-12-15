function [p_url_dado_M, p_url_dado_B, P_M, P_B, non_zero_features, stats] = ...
    NaiveBayesTrain(X_train, y_train, binary_features,numeric_features)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin == 3
    numeric_features = 'None';
end

% Separate classes
    X_M = X_train(y_train == 'malign', :);
    X_B = X_train(y_train == 'benign', :);

    % Prior probabilities
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

    if ~strcmp(numeric_features,'None')
    % Gaussian parameters for numeric features
    meanM = mean(X_M(:, numeric_features), 1);
    varM = var(X_M(:, numeric_features), 1);
    meanB = mean(X_B(:, numeric_features), 1);
    varB = var(X_B(:, numeric_features), 1);

    % Store means and variances in a matrix
    stats = [meanM; meanB; varM; varB];
    else
    stats = [];
    end

end