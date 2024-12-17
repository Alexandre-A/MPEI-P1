function MS = CalcularSimilaridade(datasize, smallsig, sig, entry)

b = size(sig,1);

MS = zeros(1,datasize);

bar2 = waitbar(0,['A calcular SIMILARIDADE para ' cell2mat(entry) '...']);

for icol = 1:datasize
    
    for indsignovo=1:size(smallsig,2)
        similaridade = sum(smallsig(:,indsignovo) == sig(:,icol))/b;
    
        if similaridade ~= 0
            MS(icol) = similaridade;
        end

    end
    
        if (mod(icol,1234) == 0)
            waitbar(icol/datasize,bar2,['A calcular SIMILARIDADE para ' cell2mat(entry) '... icol1= ' num2str(icol)]);
        end

end
delete(bar2)
end