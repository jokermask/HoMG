function [ mae ] = train_ucsd( total_fold, numofImages, Feats ,patchsz )

    load ucsd_gt ;
   
    mae = 0 ;
    
    for fold=1:total_fold
        
        train_data_num = floor(numofImages/total_fold*(total_fold-1)) ;
        test_data_num = numofImages - train_data_num ; 
        test_data_start = floor((numofImages)*(fold-1)/total_fold)+1 ;
        
        train_i = 1 ;
        test_i = 1 ;
             
         for i=1:numofImages
       
            if i>=test_data_start && i< (test_data_start+test_data_num)
                patchHog = Feats{i}.all_patchHog ;
                gt = Feats{i}.all_gt ;
                numofPatches = length(gt) ;
                for j=1:numofPatches ;
                    tempHog = patchHog(j,:) ;
                    test_cell_x{test_i,:} = tempHog(:)' ;
                    test_data_y(test_i,:) = gt(j) ;
                    test_i = test_i + 1;
                end
            else
                patchHog = Feats{i}.train_patchHog ;
                gt = Feats{i}.train_gt ;
                numofPatches = length(gt) ;
               for j=1:numofPatches ; 
                    tempHog = patchHog(j,:) ;
                    train_cell_x{train_i,:} = tempHog(:)' ;
                    train_data_y(train_i,:) = gt(j) ;
                    train_i = train_i + 1;
                end
            end

        end


        train_data_x = cell2mat(train_cell_x) ;
        test_data_x = cell2mat(test_cell_x) ;
        
        disp('predicting') ;
        ensemble = fitensemble(train_data_x,train_data_y,'LSBoost',100,'Tree','LearnRate',0.1) ;
       %todo 一张一张进行预测
        predict_y = predict(ensemble,test_data_x) ;
        predict_y = round(predict_y) ;
%         disp([predict_y test_data_y]) ;
%         disp('mae') ;
%         disp(sum(predict_y~=test_data_y)/length(test_data_y)) ;
%         
        %todo getDesityMap
        ae = 0 ;
        numofPatches = length(Feats{1}.all_gt) ;
        disp('patchnum') ;
        disp(numofPatches) ;
        for i=1:test_data_num
            sub_index = (i-1) * numofPatches+1 ;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
            sub_predict_y = predict_y(sub_index:sub_index+numofPatches-1) ;
            [dmap,countmap] = sumDesityMap(patchsz,Feats{i}.Gdiff,sub_predict_y) ;
            predict_num = 0 ;
            for row=1:size(dmap,1)
                for col=1:size(dmap,2)
                    if(dmap(row,col)>0)
                        predict_num = predict_num + dmap(row,col)/countmap(row,col) ;
                    end
                end
            end
            %predict_num = sum(sum(damp./countmap)) ;
            disp(i) ;
            disp([count(i) predict_num]) ;
            ae = ae+abs(count(i)-predict_num)/test_data_num ;
        end

        disp(ae) ;
        
        mae = mae + ae ;
       
    end
    mae = mae/total_fold ;
    disp('final mae') ;
    disp(mae) ;

end

