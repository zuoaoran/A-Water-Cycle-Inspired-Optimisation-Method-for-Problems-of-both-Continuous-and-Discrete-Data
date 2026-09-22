function [g] =type_3(I,thresh)
thresh = round(thresh);%取整
thresh = sort(thresh);
n=max(size(thresh));%  %阈值个数
[X, Y] = size(I);
[hist,count] = imhist(I);
M=max(count);
%[count, x] = imhist( i ) 获取直方图信息
%count为每一级灰度像素个数，x为灰度级，x也可以在imhist（i，x）中指定，可以通过stem（x，count）画相应直方图；
p= hist/(X*Y); % 各灰度概率
x=0;s=0;y=0;m=0; xx=0; yy=0;t=0;
u=zeros(1,256);
uu=zeros(1,256);
w=zeros(1,256);
ww=zeros(1,256);
x_x=zeros(1,256);
y_y=zeros(1,256);
G=zeros(1,256);
for k=1:n
    t=thresh(k);
        if t>255|t<=0
       g=inf; 
     return;
    end
 x=0;s=0;y=0;m=0;
for i=1:t
    x=x+p(i);
    s=s+i*p(i);
end
w(t)=x; %目标部分比例
ww(t)=s/w(t);%目标均值
for j=t+1:M
    y=y+p(j);%背景部分比例
    m=m+j*p(j);
end
u(t)=y;
uu(t)=m/u(t);%背景均值
x_x(t)=w(t)*ww(t)+u(t)*uu(t);   
G(t)=w(t)*(ww(t)-x_x(t))*(ww(t)-x_x(t))+u(t)*(uu(t)-x_x(t))*(uu(t)-x_x(t));
end
g=max(G);
g=-g;
end
