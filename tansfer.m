gt= load('./mall_dataset/mall_gt.mat') ;
gt_count = gt.count ;
% gt_filename = cell(length(gt_count),1)  ;
% sufix = 'seq_00' ;
% for i=1:2000
%     index = num2str(i) ;
%     range = i ;
%     while(range<1000)
%         index = ['0',index] ;
%         range = range * 10 ;
%     end
%     full_name =  [sufix,index] ;
%     gt_filename{i} = full_name ;
% end
% gt_filename = cell2mat(gt_filename) ;
% gt_countWithFilename = strcat(gt_filename,',',num2str(gt_count)) ;
% gt_count = num2str(gt_count) ;                                      
%dlmwrite('gt1.txt',gt_count);
fid = fopen('gt.txt','w') ;
fprintf(fid,'%d\r\n',gt_count) ;
fclose(fid) ;
type gt.txt ;