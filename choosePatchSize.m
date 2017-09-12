%init
close all ;
load('./mall_dataset/mall_gt.mat')
path = './mall_dataset/frames/'; 


%program

prefix = 'seq_000005' ;

I=imread([path,prefix,'.jpg']); %依次读取每一幅图像

Blocksz = [90 40] ;

    [M,N] = size(I) ;
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
    patchNum = ceil((M-m+1)/mInterval)*ceil((N-n+1)/nInterval) ;
    

   
%calculation
    k = 1 ;
    for i=1:mInterval:(M-m+1)
        for j=1:nInterval:(N-n+1)
            patch = I(i:i+m-1,j:j+n-1) ;
            imshow(patch) ;
        end
    end
