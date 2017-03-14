function dst = gradXMedian( src, range )

if( range > 0 )
    src = padarray( src, [range,0], 'replicate' );
    dst = medfilt2(src, [2*range+1,1]);
    s = size(dst);
    dst = dst(range+1:s(1)-range,:,:);
else
    dst = src;
end


