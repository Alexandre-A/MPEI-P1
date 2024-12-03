function [out] = partialBayesClassifier(classes,selection,teste,trndat,words,binary)
%partialBayesClassifier - The Bayes classifier is the classifier having the 
%   smallest probability of misclassification of all classifiers using the 
%   same set of features. (Source: Wikipedia)
%
%   This function in particular does *NOT* perform comparisons between
%   classifiers (hence 'partial'), therefore requiring external comparisons
%   for the sake of simplicity (for now...).
%   
%   Syntax
%     P = classiBayes(classes,selection,teste,mat,words)
%     P = classiBayes(classes,selection,teste,mat,words,1)
%
%   Input Arguments
%     classes - classes assigned for training data
%       cell row of character vectors
%     selection - selected class to calculate the classifier c_selection
%       scalar string
%     teste - given occurrence row
%       numeric array | string
%     trndat - training data
%       matrix
%     words - (unique) words avaiable to process from training data
%       cell row of character vectors
%     binary - whether we're handling binary Naïve Bayes or not
%       0 -> false | other number -> true

if nargin == 5
    binary = 0;
end

psel = sum(strcmp(classes,selection))/length(classes);

rowsfromsel = trndat(strcmp(classes,selection),:); % rows that possess the wanted class
gdtotal = sum(rowsfromsel(:));

probabilities = [];
%for wrd=split(teste)' used in case if they were strings, which was now updated
for iwrd=1:length(teste)
    clgw = rowsfromsel(:,iwrd); % column with word occurrence for each row
    if binary == 0
        if isempty(clgw +1)
            continue
        end
        pred = sum(clgw)+1; % we sum it all to get n_k
        probabilities(end+1) = ((pred)/(gdtotal+length(words)))^(teste(iwrd)); % P(w_k|c_j)
    else
        if teste(iwrd) == 0
            continue
        end
        pred = sum(clgw); % we sum it all to get n_k
        probabilities(end+1) = (pred)/(gdtotal); % P(w_k|c_j)
    end
end

out = prod(probabilities)*psel;

end