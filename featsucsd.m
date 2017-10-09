function [ Feats ] = feats_ucsd(numofImages,defualtLenOfList,patchsz,dif_t)

    path = './UCSD/originImgs/'; 
    dotted_path = './UCSD/dottedImgs/'; 
    
    image_cells = cell(numofImages,1) ;
    GtImgs = cell(numofImages,1) ;
    Feats = cell(numofImages,1) ;
    load('./UCSD/vidf-cvpr/vidf1_33_roi_mainwalkway.mat') ;
    roi = uint8(roi.mask) ;
    counts = zeros(numofImages,1) ;

    gaussian_kenel = fspecial('gaussian',3,0.5) ;
    
    %gt
    for i=1:9
        gt_path_prefix = './UCSD/vidf-cvpr/vidf1_33_00' ;
        gt_path_subfix = '_count_roi_mainwalkway.mat' ;
        gt_path = strcat(gt_path_prefix,num2str(i),gt_path_subfix) ;
        count_cell{i} = load(gt_path) ;
    end
    
    for i=1:numofImages

        temp = i ;
        prefix = 'vidf1_33_00' ;
        set_i = floor(i/200) ;
        prefix = strcat(prefix,num2str(set_i),'_f') ;
        while temp < 100
            prefix = strcat(prefix,'0') ;
            temp = temp*10 ;
        end
        prefix = strcat(prefix,num2str(mod(i,200))) ;
        I=imread([path,prefix,'.png']); %依次读取每一幅图像
        GtImgs{i} = imread([dotted_path,prefix,'_dots.png']); 
        %记录该帧的gt
        one_img_count_l = cell2mat(count_cell{set_i+1}.count(1)) ;
        one_img_count_r = cell2mat(count_cell{set_i+1}.count(2)) ;
        counts(i) = one_img_count_l(i) + one_img_count_r(i) ;

        %高斯平滑
        I = imfilter(I,gaussian_kenel) ;
        %对感兴趣区域裁剪
        I = I.*roi ;
        %I = uint8(I) ;
        %计算梯度
        [Gmag,Gdir] = imgradient(I) ;
        Feats{i}.Gmag =  Gmag;
        Feats{i}.Gdir = Gdir ;
        %full_path = [path,prefix,'.jpg'] ;
        %[~, Feats{i}.sift, ~] = sift(full_path) ;%sift特征提取
        image_cells{i} = I ;
        %差分处理
        Gmean = 0 ;
        if i~=1

            if i>defualtLenOfList
                lenoflist = defualtLenOfList ;
            else
                lenoflist = i-1 ;
            end

            Lstart = i-lenoflist ;
            Ltail = i-1 ;
            for j=Lstart:Ltail
                Gmean = Gmean + (Feats{j}.Gmag ./ lenoflist) ;
            end

            Lmean = 0 ;
            Lvar = 0 ;
            if lenoflist>=defualtLenOfList
                for k=Lstart:Ltail
                    Lmean = Lmean + (Feats{k}.Gmag./lenoflist) ;
                end
                for k=Lstart:Ltail
                    Lvar = Lvar+((Feats{k}.Gmag-Lmean).^2)./lenoflist ;
                end
                %Gmean = Gmean + max(Gmean(:)).*(Lvar<var_t) ;
                %Gmean = Gmean.*(Lvar<var_t)  ;
            end 

            Gmoving = Feats{i}.Gmag - Gmean ;
            Gmoving = Gmoving .* (Gmoving>dif_t) ;
            Feats{i}.Gdiff = single(Gmoving) ;
            G = uint8(Gmoving);
            G = insertText(G,[3,4],num2str(counts(i)),'TextColor','white') ;
            imshow(G) ;
            
            
            %calculate every single patch's hog
            [Feats{i}.train_patchHog,Feats{i}.all_patchHog,Feats{i}.train_gt,Feats{i}.all_gt] = patchHog(Feats{i}.Gdiff,patchsz,GtImgs{i}) ;
            disp(i) ;
        end

    end

    save ucsd_gt counts ;

    %todo 第一个样本怎么办？
    Feats{1} = Feats{2} ;
end

