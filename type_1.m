function [g] = type_1(I,thresh)
 thresh = round(thresh);%取整
  thresh = sort(thresh);
n=max(size(thresh));%  %阈值个数
[X, Y] = size(I);
[hist,count] = imhist(I);
M=max(count);
%[count, x] = imhist( i ) 获取直方图信息
%count为每一级灰度像素个数，x为灰度级，x也可以在imhist（i，x）中指定，可以通过stem（x，count）画相应直方图；
p= hist/(X*Y); % 各灰度概率
sumP = cumsum(p);
%B = cumsum(A) 从 A 中的第一个其大小不等于 1 的数组维度开始返回 A 的累积和。
sumQ = 1-sumP;
%将256个灰度作为256个分割阈值，分别计算各阈值下的概率密度函数
c0 = zeros(256,256);
c1 = zeros(256,256);
for i = 1:n
   y0=thresh(i);
    for j = 1:y0
        if sumP(y0) > 0
            c0(y0,j) = p(j)/sumP(y0); %计算各个阈值下的前景概率密度函数
        else
            c0(y0,j) = 0;
        end
        for k = y0+1:256
            if sumQ(y0) > 0;
                c1(y0,k) = p(k)/sumQ(y0); %计算各个阈值下的背景概率密度函数
            else
                c1(y0,k) = 0;
            end
        end
    end 
end
 
%计算各个阈值下的前景和背景像素的累计熵
H0 = zeros(256,256);
H1 = zeros(256,256);
for i = 1:n
    y0=thresh(i);
   for j = 1:y0
       if c0(y0,j) ~=0
           H0(y0,j) =  - c0(y0,j).*log10(c0(y0,j));  %计算各个阈值下的前景熵
       end
       for k = y0+1:256
          if c1(y0,k) ~=0
              H1(y0,k) =  -c1(y0,k).*log10(c1(y0,k));  %计算各个阈值下的背景熵
          end
       end
   end  
end
HH0 = sum(H0,2);
HH1 = sum(H1,2);
H = HH0 + HH1; 
[value, Threshold] = max(H);
g=-value;
end