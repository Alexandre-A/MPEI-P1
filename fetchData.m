function Set = fetchData(data, shingLen)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Pré-alocamos o total de linhas
% para um aumento substancial de velocidade
    Set = cell(length(data),1);
    
    % Iterar por cada url
    for indrow=1:length(data)
        url = data{indrow};
        lastIndex = length(url) - shingLen +1;
        rowSet = cell(1,lastIndex);
        
        % Criação de shingles do URL
        for indcol=1:lastIndex
            rowSet{indcol} = url(indcol:indcol+shingLen-1);
        end
    
        Set{indrow} = rowSet;
    end
end