function [UrlOutput, classesOutput, X] = UrlInput(modulo)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

UrlOutput = [];
classesOutput = [];
X = [];
while 1
    url = inputdlg("Insira o url: ");
    if isempty(url)  
        break;
    end

    % Requirements for NB/BF:
    if strcmp(modulo, 'NB') == 1
        url = url{1};
        typeChoice = inputdlg("Insira o tipo (1 para maligno ou 2 para benigno):");
        type = '';
        while strcmp(typeChoice, '1') == 0 && strcmp(typeChoice, '2') == 0
            typeChoice = inputdlg("Insira o tipo (1 para maligno ou 2 para benigno)");
        end
        if strcmp(typeChoice, '1') == 1
            type = 'malign';
        elseif strcmp(typeChoice, '2') == 1
            type = 'benign';
        else
            continue;
        end
        
        UrlOutput = [UrlOutput; {url, type}];

    elseif strcmp(modulo, 'BF') == 1
        typeChoice = inputdlg("Insira o tipo (1 para maligno ou 2 para benigno)");
        type = '';
        while strcmp(typeChoice, '1') == 0 && strcmp(typeChoice, '2') == 0
            typeChoice = inputdlg("Insira o tipo (1 para maligno ou 2 para benigno)");
        end
        if strcmp(typeChoice, '1') == 1
            type = 'malign';
        elseif strcmp(typeChoice, '2') == 1
            type = 'benign';
        end
        classesOutput = [classesOutput; type];
        UrlOutput = [UrlOutput; url];
    end
    %-------------------------------------------------------------%

    % Loop Decision
    decision = inputdlg("Deseja continuar (1 para sim ou 2 para não)");

    while strcmp(decision, '1') == 0 && strcmp(decision, '2') == 0
        decision = inputdlg("Deseja continuar (1 para sim ou 2 para não) ");
    end

    if strcmp(decision, '2') == 1
        if strcmp(modulo, 'BF') == 1
            UrlOutput = cellstr(UrlOutput);
            classesOutput = categorical(cellstr(classesOutput));
        end
        break;
    end
    %-----------------------------------------------------------%
end

end
