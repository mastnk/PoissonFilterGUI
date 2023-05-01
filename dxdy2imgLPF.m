function dstGry = dxdy2imgLPF( dx, dy, refGry, Param, ep, ker )

 ParamKer = buildModPoissonParamKernel( ker, size(refGry) );

 L = circshift(dx,[0,1]) + circshift(dy,[1,0]) - dx - dy;
 Ldct = dct2(L);

 dstGry = idct2( ( Ldct + ep * dct2(refGry) ) ./ (Param + ep * ParamKer) );

end
