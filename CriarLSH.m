function sigLSH = CriarLSH(urlsize,sig,b,r,K)

sigLSH = zeros(b,urlsize);
prime = 986693;

bar=waitbar(0,'A Preparar LSH...');
for indurl=1:urlsize

    ib = 1;
    for indband=1:r:K
        band=sig(indband:indband+r-1, indurl);
        sigLSH(ib,indurl) = hashy(num2str(band(:)'),prime,1);
        ib = ib +1;
    end

    if mod(indurl, 12345) == 0
        waitbar(indurl/urlsize,bar, ['A Preparar LSH... indurl= ' num2str(indurl)]);
    end
end
delete(bar)

end