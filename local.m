%init
close all ;

%param
numofImages = 10 ;
defualtLenOfList = 5 ;%ǰ�����ʱĬ�ϵĶ��г���
dif_t = 60 ;%�����ֵ
total_fold = 5 ; %k-fold,k=5
patchsz = [70 40] ;

[ Feats ] = featsHandler(numofImages, defualtLenOfList, patchsz, dif_t) ;


%train and predict
[ mae ] = trainAndPredict( total_fold, numofImages, Feats ,patchsz ) ;
