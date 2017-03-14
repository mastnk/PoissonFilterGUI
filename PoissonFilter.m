function [dst, Param] = PoissonFilter(src, gsig, gamp, glpf, ith, iamp, median, black, ep, Param)

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

if ~exist('Param', 'var') || isempty(Param)
 Param = buildModPoissonParam(s);
else
 sk = size(Param);
 if( s(1) ~= sk(1) || s(2) ~= sk(2) )
  Param = buildModPoissonParam(s);
 end
end

src = src+1;

if( numel(s) >= 3 )
 if( s(3) == 3 )
  gry = 0.299 * src(:,:,1) + 0.587 * src(:,:,2) + 0.114 * src(:,:,3);
 else
  gry = src(:,:,1);
 end
else
 gry = src;
end

dst = zeros(size(src));

crm = bsxfun(@rdivide, src, gry );

if( glpf > 0 )
 h = fspecial('gaussian', 2*floor(glpf*2.5)+1, glpf);
 lpfGry = imfilter( gry, h, 'replicate');
 refGry = gry - lpfGry;
 if( black > 0 )
  lpfGry = ( 255 - black ) / 255 * lpfGry + black;
 end
else
 lpfGry = black;
 refGry = gry; 
end

KDx = [ 0,-1, 1 ];
KDy = [ 0;-1; 1 ];
KAx = [ 0, 1/2, 1/2 ];
KAy = [ 0; 1/2; 1/2 ];

gryDx = imfilter(refGry,KDx,'replicate');
gryDy = imfilter(refGry,KDy,'replicate');
gryAx = imfilter(gry,KAx,'replicate');
gryAy = imfilter(gry,KAy,'replicate');

if( median > 0 )
 gryDx = gradXMedian( gryDx, median );
 gryDy = gradYMedian( gryDy, median );
 gryAx = gradXMedian( gryAx, median );
 gryAy = gradYMedian( gryAy, median );
end

gIX = calcIgain(gryAx,ith,iamp);
gIY = calcIgain(gryAy,ith,iamp);

gGX = calcGgain(gryDx,gsig,gamp);
gGY = calcGgain(gryDy,gsig,gamp);

GX = gGX .* gIX;
GY = gGY .* gIY;
 
dx = gryDx .* GX;
dy = gryDy .* GY;
 
dstGry = dxdy2img( dx, dy, refGry, Param, ep ) + lpfGry;

dst = bsxfun(@times, crm, dstGry);

dst = dst - 1;
