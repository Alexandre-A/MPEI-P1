function pertence = BloomCheck2(x,BF,k)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
pertence = true;

h2 = string2hash(x,'djb2');
h1 = string2hash(x,'sdbm');

% Note: with sdbm as the first hash function, and djb2 as the 2nd, it
% produces better and more consistent values than the other way around
% -> Try to understand why <-

for i=1:k
    hashValue = mod(h1 +i*h2,length(BF)) +1;
    if (BF(hashValue)==0)
        pertence = false;
        break;
    end
end
end