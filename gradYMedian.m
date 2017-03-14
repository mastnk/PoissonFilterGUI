function dst = gradYMedian( src, range )

if( range > 0 )
    src = padarray( src, [0,range], 'replicate' );
    dst = medfilt2(src, [1,2*range+1]);
    s = size(dst);
    dst = dst(:,range+1:s(2)-range,:);
else
    dst = src;
end


