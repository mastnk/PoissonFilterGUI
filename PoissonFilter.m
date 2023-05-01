function [dst, Param, dx, dy, dstGry, lpfGry, ker, crm] = PoissonFilter(src, gsig, gamp, glpf, ith, iamp, median, black, ep, rho, Param)

s = size(src);

if ~exist('glpf', 'var') || isempty(glpf)
 glpf = 0;
end

if ~exist('black', 'var') || isempty(ep)
 black = 0;
end

if ~exist('ep', 'var') || isempty(ep)
 ep = 1E-8;
end

if ~exist('median', 'var') || isempty(median)
	median = 0;
end

if ~exist('rho', 'var') || isempty(rho)
	rho = 1;
end


if ~exist('Param', 'var') || isempty(Param)
 Param = buildModPoissonParam(s);
else
 sk = size(Param);
 if( s(1) ~= sk(1) || s(2) ~= sk(2) )
  Param = buildModPoissonParam(s);
 end
end

gryBias = 1;

if( numel(s) >= 3 )
    gry = max(src,[],3);
else
    gry = src;
end


dst = zeros(size(src));

crm = bsxfun(@rdivide, src, gry+gryBias );
crm = crm .^ rho;

if( glpf > 0 )
 ker = fspecial('gaussian', 2*floor(glpf*2.5)+1, glpf);
 lpfGry = imfilter( gry, ker, 'replicate');
else
 ker = [];
 lpfGry = gry;
end

refGry = gry;

KDx = [ 0,-1, 1 ];
KDy = [ 0;-1; 1 ];
KAx = [ 0, 1/2, 1/2 ];
KAy = [ 0; 1/2; 1/2 ];

gryDx = imfilter(refGry,KDx,'replicate');
gryDy = imfilter(refGry,KDy,'replicate');
gryAx = imfilter(lpfGry,KAx,'replicate');
gryAy = imfilter(lpfGry,KAy,'replicate');

if( median > 0 )
 gryDx = gradXMedian( gryDx, median );
 gryDy = gradYMedian( gryDy, median );
 gryAx = gradXMedian( gryAx, median );
 gryAy = gradYMedian( gryAy, median );
end

gIX = calcIgain(gryAx,ith,iamp);
gIY = calcIgain(gryAy,ith,iamp);

dx = gryDx .* gIX;
dy = gryDy .* gIY;

gGX = calcGgain(dx,gsig,gamp);
gGY = calcGgain(dy,gsig,gamp);

dx = dx .* gGX;
dy = dy .* gGY;

if( black ~= 0 )
 lpfGry = lpfGry * ( ( 255.0 - black ) / 255.0 ) + black;
end

if( glpf > 0 )
 dstGry = dxdy2imgLPF( dx, dy, lpfGry, Param, ep, ker );
else
 dstGry = dxdy2img( dx, dy, lpfGry, Param, ep );
end

dst = bsxfun(@times, crm, dstGry);

