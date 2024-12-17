%function hash = hashy(urlSet,tamanho_shingle,M)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    tamanho_shingle = 4;
    data = Set{end,:};
    M = 2^32-1;
    
    prime = 969869;
    hashes = zeros(size(data));

    for i=1:length(data)
        hash = 1;
        elem = data{i};
        for ichar=1:tamanho_shingle
            hash = mod(hash * prime + elem(ichar),M)+1;
        end
        hashes(i) = hash;
    end

subplot(1,3,1)
hist(hashes,unique(hashes(:)));
length(hashes) - length(unique(hashes))
%axis([0 4.5e9 0 50]);


    tamanho_shingle = 4;
    data = Set{end,:};
    M = 2^32-1;
    
    prime = 969869;
    hashes2 = zeros(size(data));

    for i=1:length(data)
        elem = data{i};
      
        hashes2(i) = string2hash(elem)+1;
    end

subplot(1,3,2)
hist(hashes2,unique(hashes2(:)));
length(hashes2) - length(unique(hashes2))
%axis([0 4.5e9 0 50]);



    tamanho_shingle = 4;
    data = Set{end,:};
    M = 2^32-1;
    
    prime = 969869;
    hashes3 = zeros(size(data));

    for i=1:length(data)
        hash = 0;
        elem = data{i};
        for ichar=1:tamanho_shingle
            hash = mod(hash * 10^floor(log10(hash)) + elem(ichar),M)+1;
        end
        hashes3(i) = hash;
    end

subplot(1,3,3)
hist(hashes3,unique(hashes3(:)));
length(hashes3) - length(unique(hashes3))

%axis([0 4.5e9 0 50]);

%end