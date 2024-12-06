function pertence = BloomCheck(x,BF,k)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
pertence = true;
key = x;
for i=1:k
    key = [key num2str(i)];
    hashValue = mod(string2hash(key,'djb2'),length(BF)) +1;
    if (BF(hashValue)==0)
        pertence = false;
        break;
    end
end
end