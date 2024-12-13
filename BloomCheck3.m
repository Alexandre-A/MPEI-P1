function pertence = BloomCheck3(x,BF,k)
%{
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
pertence = true;


upperlimit = primes(length(BF)-1);
prime = upperlimit(ceil(length(upperlimit/2)));

key = string2hash(x, 'djb2');
h1 = mod(key, length(BF));

h2 = prime - mod(key, prime);

for i = 0:k-1
    hashValue = mod(h1 + i * h2 + (i^3 - i) / 6, length(BF)) + 1;

    if (BF(hashValue)==0)
        pertence = false;
        break;
    end
end
%}
pertence = true;
% Get the size of the Bloom Filter
    BFSize = length(BF);

    % Generate two independent hash values
    h1 = string2hash(x, 'sdbm'); % Uniform primary hash
    h2 = string2hash(x, 'djb2'); % Uniform secondary hash

    % Ensure positive and within range
    h1 = abs(h1);
    h2 = abs(h2);
    h1 = mod(h1, BFSize);
    h2 = mod(h2 + 1, BFSize); % Shift hash by 1 to avoid zero, then apply modulo

    % Enhanced double hashing formula: h(i) = (h1 + i * h2) mod BFSize
    for i = 0:(k-1)
        hashValue = mod(h1 + i * h2 + i^2, BFSize) + 1; % +1 for MATLAB indexing
    if (BF(hashValue)==0)
            pertence = false;
            break;
    end    
    end

end