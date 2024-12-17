function hash = hashy(str,M,k)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    tamanho_shingle = length(str);
    prime = 969869;
    hash = 0;
    
    for ichar=1:tamanho_shingle
        hash = mod(hash * 10^floor(log10(hash)) + str(ichar) + k + prime,M)+1;
    end

end