function [ dmap,countmap] = sumDesityMap(Blocksz,Gdiff,predict_y )

    dsize = 5 ;
    [M,N] = size(Gdiff) ;
    dmap = zeros(M,N) ;
    countmap = zeros(M,N) ;
    gaussian_kenel = fspecial('gaussian',dsize,0.5) ;
    count_ones = ones(dsize) ;
    
    if length(Blocksz)<2
        m = 10 ; 
        n = 10 ;
    else
        m = Blocksz(1,1) ;
        n = Blocksz(1,2) ;
    end
    % interval is m/2 and n/2
    mInterval = floor(m/2) ;
    nInterval = floor(n/2) ;

%calculation
    k = 1 ;
    
    for i=1:mInterval:(M-m+1)
        for j=1:nInterval:(N-n+1)
            
            if predict_y(k)==0
                k = k+1 ;
                continue ;
            end
            
            patch = Gdiff(i:i+m-1,j:j+n-1) ;
            [row,col] = find(patch>0) ;
            locs = [row col] ;
            %todo 预测出来的数值不为0是，patch不应该是黑的，而且基本没有预测出1以上的数值
            if length(locs)<predict_y(k)
                k = k+1 ;
                continue ;
            end
            %
            [~,centers] = kmeans(locs,predict_y(k)) ;
            k = k+1 ;
            
            for l=1:size(centers,1) 
                
                c = round(centers(l,:)) ;
                %相对坐标转化为绝对坐标
                x_bias = ones(size(c,1),1)*i-1 ;
                y_bias = ones(size(c,1),1)*j-1 ;
                bias = [x_bias,y_bias] ;
                c = c + bias ; 
                
                x_start = c(1)-floor(dsize/2) ;
                y_start = c(2)-floor(dsize/2) ;
                %judge edge
                if c(1)-floor(dsize/2)<1
                    x_start = 1 ;
                end
                if c(1)+floor(dsize/2)>N
                    x_start = N-dsize ;
                end
                
                if c(2)-floor(dsize/2)<1
                    y_start = 1 ;
                end
                if c(2)+floor(dsize/2)>M
                    y_start = M-dsize ;
                end
                x_tail = x_start+dsize-1 ;
                y_tail = y_start+dsize-1 ;
                dmap(x_start:x_tail,y_start:y_tail) = dmap(x_start:x_tail,y_start:y_tail)  + gaussian_kenel ;
                countmap(x_start:x_tail,y_start:y_tail) = countmap(x_start:x_tail,y_start:y_tail) + count_ones ;
                imshow(dmap*100) ;
                %imshow(countmap) ;
            end
        end
    end

end

