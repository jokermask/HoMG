path = './mall_dataset/frames'; 
numofImages = 200 ;
for i=1:numofImages
    I=imread([str,num2str(i),'.jpg']); %依次读取每一幅图像
    %todo 存到cell 灰度转化 strip？
end