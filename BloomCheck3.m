function pertence = BloomCheck3(x,BF,k)
pertence = true;
    BFSize = length(BF);

    h1 = string2hash(x, 'sdbm'); %primary hash
    h2 = string2hash(x, 'djb2'); %secondary hash

    h1 = abs(h1);
    h2 = abs(h2);
    h1 = mod(h1, BFSize);
    h2 = mod(h2 + 1, BFSize); % Shift hash by 1 to avoid zero

    % double hashing formula: h(i) = (h1 + i * h2) mod BFSize
    for i = 0:(k-1)
        hashValue = mod(h1 + i * h2 + i^2, BFSize) + 1; % +1 for MATLAB indexing
    if (BF(hashValue)==0)
            pertence = false;
            break;
    end    
    end

end