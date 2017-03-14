function dstGry = dxdy2img( dx, dy, refGry, Param, ep )

 L = circshift(dx,[0,1]) + circshift(dy,[1,0]) - dx - dy;
 Ldct = dct2(L);

 dstGry = idct2( ( Ldct + ep * dct2(refGry) ) ./ (Param + ep) );

end
