function BF = BloomAdd2(element,BF,k)
%
% Double hashing, using string2hash's djb and sdbm algorithms
% inspiration source: https://www.geeksforgeeks.org/double-hashing/
h2 = string2hash(element,'djb2');
h1 = string2hash(element,'sdbm');

% Note: with sdbm as the first hash function, and djb2 as the 2nd, it
% produces better and more consistent values than the other way around
% -> Try to understand why <-

for i=1:k
hashValue = mod(h1 +i*h2,length(BF)) +1;
BF(1,hashValue) = 1;
end

end