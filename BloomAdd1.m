function BF = BloomAdd1(element,BF,k)
%
% repetir k vezes
    % aplicar a função de hash a elemento
    % .... obtendo indice
    
    % na posição indice do array igualar a 1

key = element;
for i=1:k
key = [key num2str(i)];
hashValue = mod(string2hash(key,'djb2'),length(BF)) +1;
BF(1,hashValue) = 1;
end

end