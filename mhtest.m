% minhash experiment
%% Funções
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

function sig = calcMinHash(Set,datasize, K)

    sig = Inf(K, datasize);
    bar = waitbar(0,'running minhash...');
    for k=1:K
        waitbar(k/K,bar,'running minhash...');
        for indurl=1:datasize
            conteudo = Set{indurl};
            for indelem=1:length(conteudo)
                shingle = conteudo{indelem};
                hash = hashy(shingle, 2^32-1,k);
    
                if hash < sig(k,indurl)
                    sig(k,indurl) = hash;
                end
            end
    
            if (mod(indurl,12345) == 0)
                waitbar(k/K,bar,['running minhash... k= ' num2str(k) ' url=' num2str(indurl)]);
            end
        end
    end
    delete(bar);

end

function sigLSH = CriarLSH(urlsize,sig,b,r,K)

sigLSH = zeros(b,urlsize);
prime = 986693;

bar=waitbar(0,'A Preparar LSH...');
for indurl=1:urlsize

    ib = 1;
    for indband=1:r:K
        band=sig(indband:indband+r-1, indurl);
        sigLSH(ib,indurl) = hashy(num2str(band(:)'),prime,1);
        ib = ib +1;
    end

    if mod(indurl, 12345) == 0
        waitbar(indurl/urlsize,bar, ['A Preparar LSH... indurl= ' num2str(indurl)]);
    end
end
delete(bar)

end


%% Obter Dados

load('dados.mat','urls')

shingLen = 4;

Set = fetchData(urls,shingLen);
urlsize = length(urls);

clear urls
%% Calcular Matriz Assinaturas
tic

K = 14;

sig = calcMinHash(Set,urlsize,K);

toc

 % Por questões técnicas do matlab, antes de apagar a variável
 % "limpamos" todos os seus elementos para assegurar a libertação
 % de RAM!
clear Set

%% Determinar Pares Candidatos

b = 7;
r = 2;

sigLSH = CriarLSH(urlsize,sig,b,r,K);

%% POUPA ALGUMA MEMÓRIA

sigLSH = sparse(sigLSH);


%% Encontrar Similares

% colocamos url
% passamos para Set
% calculamos assinatura
% comparamos similaridade iterando pelas sig's


limiar = .4;

%urlNovo = 'https://web.whatsapp.com/';
urlNovo = inputdlg("Insira um URL:");
setNovo = fetchData(urlNovo, shingLen);

MS = zeros(1,urlsize);

bar2 = waitbar(0,['A calcular SIMILARIDADE de Jaccard para ' urlNovo '...']);

sigNovo = calcMinHash(setNovo,urlNovo,K);

sigNovoLSH = CriarLSH(1,sigNovo,b,r,K);

for icol = 1:urlsize

    similaridade = sum(sigNovoLSH == sigLSH(:,icol))/b;

    if similaridade ~= 0
        MS(icol) = similaridade;
    end

    if (mod(icol,1234) == 0)
        waitbar(icol/urlsize,bar2,['A calcular SIMILARIDADE de Jaccard para ' urlNovo '... icol1= ' num2str(icol)]);
    end

end
delete(bar2)

% Apresentar similares

load('dados.mat','urls','classes');
urls = string(urls);

INDsimilares = MS>limiar;
URLresults = urls(INDsimilares);
CLASSresults = classes(INDsimilares);

totalResult = length(URLresults);

fprintf("Expressão providenciada: %s\n\n\tResultados:\n%40s | CLASSE\n\n",cell2mat(urlNovo),'URL')

for indurl=1:totalResult
    fprintf("%40s | %s\n",URLresults{indurl},string(CLASSresults(indurl)))
end
fprintf("\n\n")

