function gain = calcGgain(grad, gsig, gamp)

if( gsig == 0 )
 gain = ones(size(grad)) * gamp;
else
 gain = ( 1 - exp(- grad .* grad /(2*gsig*gsig) ) ) * gamp;
end
