function BF = BloomInit(n)
% Inicializar o array de bits com zeros
% Input: n - tamanho
% Output: BF - array de bits

BF = false(1, n); % It is prefered to use a logical array instead of an
                    %uint one, as it is better memory-wise
end