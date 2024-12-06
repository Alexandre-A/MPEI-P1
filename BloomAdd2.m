function BF = BloomAdd2(element,BF,k)
%
% Double hashing, using string2hash's djb and sdbm algorithms
% inspiration source: https://www.geeksforgeeks.org/double-hashing/
h1 = string2hash(element,'djb2');
h2 = string2hash(element,'sdbm');

for i=1:k
hashValue = mod(h1 +i*h2,length(BF)) +1;
BF(1,hashValue) = 1;
end

end