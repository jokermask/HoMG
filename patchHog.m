function [ B,Gt] = patchHog( A, Blocksz ,GtImg)
%output B is mat with (M-m+1)*(N-n+1) rows
%输入图像A,以blocksz为窗口大小，gt为真值，输出A转化成的patch的hog和对应patch的人数
%parm
    [M,N] = size(A) ;
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
    
    B = cell(patchNum,1) ;
    Gt = zeros(patchNum,1) ;
   
%calculation
    k = 1 ;
    for i=1:mInterval:(M-m+1)
        for j=1:nInterval:(N-n+1)
            patch = A(i:i+m-1,j:j+n-1) ;
            patchGt = GtImg(i:i+m-1,j:j+n-1) ;
            imshow(patch) ;
            patchWithHog = fhog(patch) ;
            
            B{k,:} = patchWithHog(:)' ;
            Gt(k) = sum(patchGt(:)>1) ;
            k = k+1 ;
        end
    end
    disp('one img done') ;
    B = cell2mat(B) ;
end

