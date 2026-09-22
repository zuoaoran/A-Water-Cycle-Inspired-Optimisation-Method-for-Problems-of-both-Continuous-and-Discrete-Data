function [Iout]=YuZhiplot(I,thresh)
thresh = sort(thresh);
Iout=zeros(size(I));
n=max(size(thresh));
if(n==1)
Iout(I<thresh(1))=0;
Iout(I>=thresh(1))=1;
else
    for i=1:n+1
        if(i==1)
            Iout(I<thresh(i))=i;
         elseif(i==n+1)
             Iout(I>=thresh(i-1))=i;
        else
             Iout(I<thresh(i)&I>=thresh(i-1))=i;
         end
    end
end
imshow(Iout,[]);
%imwrite(Iout,'E:\xinguan\201821013157-薛晓玲-毕设材料\薛晓玲-毕设代码\AOA-图像分割\sky\data\1-7.jpg');
end