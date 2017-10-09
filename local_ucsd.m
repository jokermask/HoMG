%init
close all ;

%param
numofImages = 2000 ;
defualtLenOfList = 5 ;%前景差分时默认的队列长度
dif_t = 60 ;%差分阈值
total_fold = 5 ; %k-fold,k=5
patchsz = [30 30] ;

[ Feats ] = feats_ucsd(numofImages, defualtLenOfList, patchsz, dif_t) ;


%train and predict
[ mae ] = train_ucsd( total_fold, numofImages, Feats ,patchsz ) ;
