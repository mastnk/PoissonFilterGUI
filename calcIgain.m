function gain = calcIgain(ix, ith, iamp)

if( iamp > 1 )
    a=(iamp-1)/(ith*ith);
    b=-2*(iamp-1)/ith;
    c=iamp;
    ix2 = ix .* ix;
    gain = a * (ix .* ix ) + b * ix + c;
    gain(ix>ith) = 1;
else
    gain = 1;
end
