function MostrarSimilares(IndicesResultsOrdenado,limiar,novoLimiar,oldLimiar,oldLimIndexes,urlNovo,urls,classes,NumResultados,MS)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fprintf("\n\nExpressão providenciada: %s\n\n",cell2mat(urlNovo))

urlsize = length(urls);

if novoLimiar == true
    fprintf(" <strong> Não foram encontrados %d URL(s) similar(es) à expressão.\nAqui estão alguns resultados para limiares mais baixos:</strong>\n",NumResultados);
end

if limiar ~= 0

    URLresults = urls(IndicesResultsOrdenado);
    CLASSresults = classes(IndicesResultsOrdenado);

    if oldLimIndexes > 0 && oldLimIndexes < NumResultados   
        firstURLResults = URLresults(1:oldLimIndexes);
        firstCLASSresults = classes(1:oldLimIndexes);
        fprintf("\n\tResultados <strong>acima</strong> do limiar desejado:\n")
        fprintf("Limiar = %.3f\n",oldLimiar);
        fprintf("%40s | CLASSE\n\n",'URL')
         
        for indurl=1:length(firstURLResults)
            fprintf("%40s | %s\n",firstURLResults{indurl},string(firstCLASSresults(indurl)))
        end
        fprintf("\n\tResultados <strong>acima</strong> de um limiar <strong>inferior</strong> ao desejado:\n%40s | CLASSE\n\n",'URL')
        fprintf("Limiar = %.3f\n",limiar);
         
        for indurl=1:(length(URLresults)-length(firstURLResults))
            fprintf("%40s | %s\n",URLresults{oldLimIndexes + indurl},string(CLASSresults(oldLimIndexes + indurl)))
        end
    
    else
        totalResult = length(URLresults);
        fprintf("\tResultados:\n")
        fprintf("Limiar = %.3f\n",limiar);
        fprintf("%40s | CLASSE\n\n",'URL')
        
        for indurl=1:totalResult
            fprintf("%40s | %s\n",URLresults{indurl},string(CLASSresults(indurl)))
        end
    end
    fprintf("\n\n")
    
elseif ~isempty(MS(MS>limiar))
    fprintf("Foram <strong>apenas</strong> encontrados os seguintes similares, nos %d URL's:\n",urlsize);
    for ind=1:length(IndicesResultsOrdenado)
        if MS(IndicesResultsOrdenado(ind)) == 0
            IndicesResultsOrdenado(ind) = [];
        end
    end
    URLresults = urls(IndicesResultsOrdenado);
    CLASSresults = classes(IndicesResultsOrdenado);
    
    totalResult = length(URLresults);

    fprintf("%40s | CLASSE\n\n",'URL')
    
    for indurl=1:totalResult
        fprintf("%40s | %s\n",URLresults{indurl},string(CLASSresults(indurl)))
    end
else
    fprintf("Não foram encontrados resultados similares para a expressão providenciada!\n")
end
end