function [dst, dstGry] = dxdy2imgMinMax( dx, dy, refGry, lpfGry, ker, ep, beta, crm, eta, itr, eps )

if( ~exist('eta', 'var') || isempty(eta) ); eta = 0.1; end
if( ~exist('itr', 'var') || isempty(itr) ); itr = 1E3; end
if( ~exist('eps', 'var') || isempty(eps) ); eps = 1; end

Gmin = 1;
Gmax = (255+1) ./ max( crm, [], 3 );

Gmin = Gmin;
Gmax = Gmax;

if( numel(Gmin) == 1 )
 Gmin = ones(size(refGry)) * Gmin;
end

if( numel(Gmax) == 1 )
 Gmax = ones(size(refGry)) * Gmax;
end

wx = ( 1 + abs(dx) ) .^ (-beta);
wy = ( 1 + abs(dy) ) .^ (-beta);

dstGry = refGry;

for i=1:itr
 dstGry0 = dstGry;

 % laplacian update
 grad = laplacian_grad( dstGry, dx, dy, wx, wy );
 
 if( ~isempty( ker ) )
  L = imfilter( dstGry, ker, 'replicate' );
  g = imfilter( L - lpfGry, ker, 'replicate' ); % ker should be symmetry
 else
  g = dstGry - lpfGry;
 end
 
 dstGry = dstGry - eta * ( grad + ep * g );
 
 % proximal of indicator
 dstGry = prox_minmax( dstGry, Gmin, Gmax );
 
 dif = abs( dstGry - dstGry0 );
 if( max(dif(:)) < eps ) 
     break;
 end
 
end

dst = bsxfun(@times, crm, dstGry);
%dst = dst - 1;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function grad = laplacian_grad( u, duh, duv, wh, wv )
 KDx = [ 0,-1, 1 ];
 KDy = [ 0;-1; 1 ];
 dh = imfilter( u, KDx, 'replicate' );
 dv = imfilter( u, KDy, 'replicate' );

 dduh = ( dh - duh ) .* wh;
 dduv = ( dv - duv ) .* wv;
 
 % calc laplacian
 grad = circshift(dduh,[0,1]) + circshift(dduv,[1,0]) - dduh - dduv;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function u = prox_minmax( u, umin, umax )
 ind = (u<umin);
 u(ind) = umin(ind);
 
 ind = (u>umax);
 u(ind) = umax(ind);
end

