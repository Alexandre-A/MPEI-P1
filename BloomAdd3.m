function BF = BloomAdd3(element,BF,k)
% BloomAdd2 Adds an element to the Bloom Filter using Double Hashing.

    BFSize = length(BF);

    h1 = string2hash(element, 'sdbm'); % primary hash
    h2 = string2hash(element, 'djb2'); % secondary hash

    % Ensure positive and within range
    h1 = abs(h1);
    h2 = abs(h2);
    h1 = mod(h1, BFSize);
    h2 = mod(h2 + 1, BFSize); % Shift hash by 1 to avoid zero

    % double hashing formula: h(i) = (h1 + i * h2) mod BFSize

    for i = 0:(k-1)
        hashValue = mod(h1 + i * h2 + i^2, BFSize) + 1; % +1 for MATLAB indexing
        BF(hashValue) = 1; % Set the bit in the Bloom Filter
    end
end