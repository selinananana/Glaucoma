function [img]= jpgtojpg(i)
folderPath = 'C:\Users\lx\Desktop\Glaucoma\IdeaProject\Glaucoma\image\map\';  % 指定文件夹路径
k = 1;
%for i = 1:1
    str1 = i;
    str2 = '.jpg';
    fileName = sprintf('%d%s', str1, str2);
    filePath = [folderPath, fileName];  % 创建完整的文件路径
    Nmsi = imread(filePath);
    Nmsi = double(Nmsi) / 255;
  %  eye{k} = Nmsi;
  %  k = k + 1;
%end

%% 去噪参数固定

 [row, col, channel] = size(Nmsi);
 tsize  = [row, col, channel];

lambda_1   = 1;
lambda_2   = 35;
lambda_3   = 5;
N          = 3;
alpha      = [1/N, 1/N, 1/N];
beta       = [1,    1,    1];
myInitial_v=0.01;
factor = 1.25;
r1 = 1;
r2 = 0.4;
rho = 1e-6;
 [denoise_eye] = FTDTV_eye4D(Nmsi,lambda_1,lambda_2,lambda_3, alpha, beta, tsize, N, factor, myInitial_v, r1, r2, rho);

% 保存图像数据为.mat文件
save('C:\Users\lx\Desktop\Glaucoma\IdeaProject\Glaucoma\image\mat\data.mat', 'denoise_eye');
load('C:\Users\lx\Desktop\Glaucoma\IdeaProject\Glaucoma\image\mat\data.mat')
for i=1:1
     %img = FTDTV4D_eye1(:,:,:,i);
     img = denoise_eye;
    % img = img(:,:,:,i);
     filename = sprintf('%d.jpg', i); 
     savePath = 'C:\Users\lx\Desktop\Glaucoma\IdeaProject\Glaucoma\image\deblur\';
     filePath = [savePath, filename];
     imwrite(img, filePath);
end

end
