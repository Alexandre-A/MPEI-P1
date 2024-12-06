function mOut = nextprime(mIn)
    % nextprime - Finds the next prime number greater than or equal to mIn
    % Input: mIn - the input number
    % Output: mOut - the next prime number
    if (mod(mIn,2)==0)
        mIn = mIn+1;
    end
    
    while ~isprime(mIn)
        mIn = mIn +2;
    end
    
    mOut = mIn;
end