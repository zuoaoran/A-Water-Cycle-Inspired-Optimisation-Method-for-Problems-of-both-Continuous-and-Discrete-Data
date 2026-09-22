function [MSE,PSNR]=result(I1,I2)
[m,n]=size(I1);
I1=double(I1);
I2=double(I2);
s=0;
for i=1:m
    for j=1:n
      s=s+(I1(i,j)-I2(i,j))^2;
    end
end
MSE=s/(m*n);
PSNR=10*log10(double(255^2/MSE));
fprintf('MSEÎª£º%f\n', MSE);
fprintf('PSNRÎª£º%f\n', PSNR);