% minhash experiment

%% Obtenção dos dados CSV
if ~isfile('dadosMH.mat')
    csv_extraction('urlDatasetMH.csv','dadosMH')
else
    dataSetDate = datevec(dir('urlDatasetMH.csv').date);
    matfileDate = datevec(dir('dadosMH.mat').date);
    
    comparison = ~(dataSetDate == matfileDate);
    difDateSet = dataSetDate(comparison);
    difMatFile = matfileDate(comparison);
    if difMatFile(1) < difDateSet(1)
        csv_extraction('urlDatasetMH.csv','dadosMH')
    end
end
vars = {'dataSetDate','matfileDate','comparison','difDateSet','difMatFile'};
clear(vars{:})
%Disclaimer: In case this is executed, it can take up to 3 minutes
% to load the entire dataset (max of 3 mins when we use the whole dataset)
%--------------------------------------------------------------------------%



% Obter Dados

load('dadosMH.mat','urls')

shingLen = 4;

Set = fetchData(urls,shingLen);
urlsize = length(urls);

clear urls
%% Calcular Matriz Assinaturas
tic

K = 14;

sig = CalcMinHash(Set,urlsize,K);

toc

clear Set

% Determinar Pares Candidatos

b = 7;
r = 2;

sigLSH = CriarLSH(urlsize,sig,b,r,K);

% POUPA ALGUMA MEMÓRIA

sigLSH = sparse(sigLSH);


%% Encontrar Similares a uma entrada

% O valor do limiar foi calculado a partir da fórmula indica
% no ponto 3.4.3 do livro Mining Massive Datasets
limiar = .4;
% para b= 7 e r= 2, seguindo a formulação dada, temos (1/7)^(1/2)

urlNovo = inputdlg("Insira um URL:");
setNovo = fetchData(urlNovo, shingLen);

sigNovo = CalcMinHash(setNovo,length(urlNovo),K);

sigNovoLSH = CriarLSH(1,sigNovo,b,r,K);

MS = CalcularSimilaridade(urlsize, sigNovoLSH, sigLSH, urlNovo);

% Apresentar similares

NumResultados = 3;

oldLimiar = limiar;
oldLimIndexes = sum(MS > limiar);
novoLimiar = false;

load('dadosMH.mat','urls','classes');
urls = string(urls);

[~,IndicesMSOrdenado] = sort(MS);
IndicesResultsOrdenado = IndicesMSOrdenado(end:-1:end-NumResultados+1);

while sum(MS > limiar) < NumResultados || sum(MS > limiar) == 0
    if novoLimiar == false
        novoLimiar = true;
    end
    if limiar - 0.05 > 0
        limiar = limiar - 0.05;
    else
        limiar = 0;
        break
    end
end


MostrarSimilares(IndicesResultsOrdenado,limiar,novoLimiar,oldLimiar,oldLimIndexes,urlNovo,urls,classes,NumResultados,MS)
