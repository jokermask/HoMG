path = './mall_dataset/frames/'; 
numofImages = 20 ;
image_cells = cell(numofImages,1) ;
E = cell(numofImages,1) ;
for i=1:numofImages
    temp = i ;
    prefix = 'seq_00' ;
    while temp < 1000
        prefix = strcat(prefix,'0') ;
        temp = temp*10 ;
    end
    prefix = strcat(prefix,num2str(i)) ;
    I=imread([path,prefix,'.jpg']); %���ζ�ȡÿһ��ͼ��
    I=rgb2gray(I);
    [Gmag,Gdir] = imgradient(I) ;
    E{i}.Gmag = Gmag ;
    E{i}.Gdir = Gdir ;
    image_cells{i} = I ;
    %todo strip��=wp/W�� ��һ����
    
end