%init
close all ;
path = './mall_dataset/frames/'; 
numofImages = 30 ;
image_cells = cell(numofImages,1) ;
E = cell(numofImages,1) ;
Em = cell(numofImages,1) ;

%param
Wh = 10 ;%人高
Ww = 5 ;%人宽
defualtLenOfList = 10 ;%前景差分时默认的队列长度
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
    I=rgb2gray(I);
    [Gmag,Gdir] = imgradient(I) ;
    E{i}.Gmag = imfilter(Gmag,gaussian_kenel) ;
    E{i}.Gdir = Gdir ;
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
        if lenoflist>=10
            for k=Lstart:Ltail
                Lmean = Lmean + (E{k}.Gmag./lenoflist) ;
            end
            for k=Lstart:Ltail
                Lvar = Lvar+((E{k}.Gmag-Lmean).^2)./lenoflist ;
            end
            Gmean = Gmean +  max(Gmean(:)).*(Lvar<var_t) ;
        end 
        
        Gmoving = E{i}.Gmag - Gmean ;
        Gmoving = Gmoving .* (Gmoving>dif_t) ;
        G = uint8(Gmoving);
        imshow(G) ;
    end
end