function sig = CalcMinHash(Set,datasize, K)

    sig = Inf(K, datasize);
    bar = waitbar(0,'A calcular MinHash...');
    for k=1:K
        waitbar(k/K,bar,'A calcular MinHash...');
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
                waitbar(k/K,bar,['A calcular MinHash... k= ' num2str(k) ' url=' num2str(indurl)]);
            end
        end
    end
    delete(bar);

end