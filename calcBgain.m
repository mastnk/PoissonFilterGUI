function gain = calcBgain(val, black, maxv)

if ~exist('maxv', 'var') || isempty(maxv)
	maxv = 255;
end

b = black;
a = (maxv-black)/maxv;

gain = ( a * val + b ) ./ ( val + 1 );

%{
a = black/(2*maxv*maxv*maxv);
b = -(-2*maxv+3*black)/(2*maxv*maxv);
d = black;

val2 = val .* val;
val3 = val2 .* val;

gain = ( a * val3 + b * val2 + d ) ./ ( val + 1 );
%}