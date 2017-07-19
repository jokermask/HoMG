%init
close all ;
load('./mall_dataset/mall_gt.mat')
path = './mall_dataset/frames/'; 
numofImages = 100 ;
image_cells = cell(numofImages,1) ;
E = cell(numofImages,1) ;
Em = cell(numofImages,1) ;

%param
Wh = 10 ;%人高
Ww = 5 ;%人宽
defualtLenOfList = 5 ;%前景差分时默认的队列长度
var_t = 5 ; %方差阈值
dif_t = 60 ;%差分阈值

%kenel
gaussian_kenel = fspecial('gaussian',3,0.5) ;

%program
for i=1:numofImages
    temp = i ;
    prefix = 'seq_00' ;
    while temp < 1000
        prefix = strcat(prefix,'0') ;
        temp = temp*10 ;
    end
    prefix = strcat(prefix,num2str(i)) ;
    I=imread([path,prefix,'.jpg']); %依次读取每一幅图像
    I = rgb2gray(I);
    I = imfilter(I,gaussian_kenel) ;
    %I = uint8(I) ;
    [Gmag,Gdir] = imgradient(I) ;
    E{i}.Gmag =  Gmag;
    E{i}.Gdir = Gdir ;
    full_path = [path,prefix,'.jpg'] ;
    %[~, E{i}.sift, ~] = sift(full_path) ;%sift特征提取
    image_cells{i} = I ;
    %todo strip高=wp/W？ 不一定好
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
            Gmean = Gmean + (E{j}.Gmag ./ lenoflist) ;
        end
        
        Lmean = 0 ;
        Lvar = 0 ;
        if lenoflist>=defualtLenOfList
            for k=Lstart:Ltail
                Lmean = Lmean + (E{k}.Gmag./lenoflist) ;
            end
            for k=Lstart:Ltail
                Lvar = Lvar+((E{k}.Gmag-Lmean).^2)./lenoflist ;
            end
            %Gmean = Gmean + max(Gmean(:)).*(Lvar<var_t) ;
            %Gmean = Gmean.*(Lvar<var_t)  ;
        end 
        
        Gmoving = E{i}.Gmag - Gmean ;
        Gmoving = Gmoving .* (Gmoving>dif_t) ;
        G = uint8(Gmoving);
        pre_hog = single(Gmoving) ;
        E{i}.hog = hog(pre_hog) ;
        %imshow(G) ;
    end
end

%train
train_data_num = floor((numofImages-1)*0.75) ;
test_data_num = numofImages - 1 - train_data_num ;
train_cell_x = cell(train_data_num,1) ;
test_cell_x = cell(test_data_num,1) ;
train_data_y = zeros(train_data_num,1) ;
test_data_y = zeros(test_data_num,1) ;
train_i = 1 ;
test_i = 1 ;
for i=2:numofImages
    temp_x = E{i}.hog ;
%     [pc,score,latent,tsquare] = princomp(temp_x) ;
%     myans = cumsum(latent)./sum(latent) ;
%     disp(sum((myans<0.95))) ;
%     temp_x = score(:,1:54) ;
    if i <= train_data_num+1
        train_cell_x{train_i} = temp_x(:)' ;
        train_data_y(train_i,:) = count(i) ;
        train_i = train_i + 1 ;
    else
        test_cell_x{test_i} = temp_x(:)' ;
        test_data_y(test_i) = count(i) ;
        test_i = test_i + 1 ;
    end
end

%predict
train_data_x = cell2mat(train_cell_x) ;
test_data_x = cell2mat(test_cell_x) ;
disp('predicting') ;
ensemble = fitensemble(train_data_x,train_data_y,'LSBoost',100,'Tree','LearnRate',0.1) ;
predict_y = predict(ensemble,test_data_x) ;
disp(sum(abs(test_data_y-predict_y)./test_data_y)/length(test_data_y)) ;

