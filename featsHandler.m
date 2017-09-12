function [ Feats ] = featsHandler(numofImages,defualtLenOfList,patchsz,dif_t)

    load('./mall_dataset/mall_gt.mat') ;
    load('./mall_dataset/roi.dat') ;
    load('./mall_dataset/pmap.dat') ;
    path = './mall_dataset/frames/'; 
    dotted_path = './mall_dataset/dottedImgs/'; 
    
    image_cells = cell(numofImages,1) ;
    GtImgs = cell(numofImages,1) ;
    Feats = cell(numofImages,1) ;

    gaussian_kenel = fspecial('gaussian',3,0.5) ;
    
    for i=1:numofImages

        temp = i ;
        prefix = 'seq_00' ;
        while temp < 1000
            prefix = strcat(prefix,'0') ;
            temp = temp*10 ;
        end
        prefix = strcat(prefix,num2str(i)) ;
        I=imread([path,prefix,'.jpg']); %���ζ�ȡÿһ��ͼ��
        GtImgs{i} = imread([dotted_path,prefix,'.png']); 
        %rgbת�Ҷ�
        I = rgb2gray(I);
        %��˹ƽ��
        I = imfilter(I,gaussian_kenel) ;
        %�Ը���Ȥ����ü�
        roi = uint8(roi) ;
        I = I.*roi ;
        %I = uint8(I) ;
        %�����ݶ�
        [Gmag,Gdir] = imgradient(I) ;
        Feats{i}.Gmag =  Gmag;
        Feats{i}.Gdir = Gdir ;
        %full_path = [path,prefix,'.jpg'] ;
        %[~, Feats{i}.sift, ~] = sift(full_path) ;%sift������ȡ
        image_cells{i} = I ;
        %��ִ���
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
            %G = uint8(Gmoving);
            %imshow(G) ;
            
            %calculate every single patch's hog
            [Feats{i}.patchHog,Feats{i}.gt] = patchHog(Feats{i}.Gdiff,patchsz,GtImgs{i}) ;
            disp(i) ;
        end

    end

    save feats Feats ;

    %todo ��һ��������ô�죿
    Feats{1}.Gdiff = Feats{2}.Gdiff ;
    Feats{1}.patchHog = Feats{2}.patchHog ;
    Feats{1}.gt = Feats{2}.gt ;

end

