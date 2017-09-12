function [ mae ] = trainAndPredict( total_fold, numofImages, Feats ,patchsz )

    load('./mall_dataset/mall_gt.mat') ;
   
    mae = 0 ;
    
    for fold=1:total_fold
        
        train_data_num = floor(numofImages/total_fold*(total_fold-1)) ;
        test_data_num = numofImages - train_data_num ; 
        test_data_start = floor((numofImages)*(fold-1)/total_fold)+1 ;
        
        train_i = 1 ;
        test_i = 1 ;
        
        featSample = Feats{1} ;
        numofPatches = size(featSample.gt,1) ; 
        
        dmap = zeros(size(featSample.Gdiff)) ;
        countmap = zeros(size(featSample.Gdiff)) ;
        
         for i=1:numofImages
       
            patchHog = Feats{i}.patchHog ;
            gt = Feats{i}.gt ;

            if i>=test_data_start && i< (test_data_start+test_data_num)
                for j=1:numofPatches ;
                    tempHog = patchHog(j,:) ;
                    test_cell_x{test_i,:} = tempHog(:)' ;
                    test_data_y(test_i,:) = gt(j) ;
                    test_i = test_i + 1;
                end
            else
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
        predict_y = predict(ensemble,test_data_x) ;
        predict_y = round(predict_y) ;
        
        %todo getDesityMap
        ae = 0 ;
        for i=test_data_start:(test_data_start+test_data_num-1)
            sub_index = i - test_data_start+1 ;
            sub_predict_y = predict_y(sub_index:sub_index+numofPatches) ;
            [dmap_temp,countmap_temp] = sumDesityMap(patchsz,Feats{i}.Gdiff,sub_predict_y) ;
            dmap = dmap + dmap_temp ;
            countmap = countmap + countmap_temp ; 
            predict_num = 0 ;
            for row=1:size(dmap,1)
                for col=1:size(dmap,2)
                    predict_num = predict_num + dmap(row,col)/countmap(row,col) ;
                end
            end
            %predict_num = sum(sum(damp./countmap)) ;
            ae = ae+abs(count(i)-predict_num)/test_data_num ;
        end

        %ae = sum(abs(predict_y-test_data_y)) / length(predict_y) ;
        disp(ae) ;
        
        mae = mae + ae ;
       
    end
    mae = mae/total_fold ;

end

