clc;
clear all;
close all
%I = imread('sky\data\0003.jpg'); 
% I = imread(['data\脑出血(有GT)\25.jpg']); 
% I = imread(['data\脑肿瘤\DWI\3.jpg']);
I = imread(['图片\4.jpg']); 
[rol,col,color] = size(I);%获取图像尺寸
if(color == 3)
    I = rgb2gray(I);
end    %如果是彩图 则转为灰度图
%fobj=@(thresh)type_3(I,thresh);%type_3最大类间方差法 
fobj=@(thresh)type_1(I,thresh);%type_1最大熵法
lb=0;  
ub=255;  %根据问题 图像的阈值为0-255
Materials_no=30;  %种群个数
Max_iter=10;  %最大迭代次数
dim=1;    %求一个值 
C3=1;C4=2;  %standard Optimization functions

%土壤蒸发过程  改为  海水经日晒第一次蒸发
[Xbest_1, Scorebest_1,Convergence_curve_1]=oil_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
%植物蒸腾作用  改为  蒸发后水蒸气遇冷凝结
[Xbest_2, Scorebest_2,Convergence_curve_2]=plant_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);

%海洋蒸发过程
[Xbest_3, Scorebest_3,Convergence_curve_3]=ocean_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
%大气降水过程
[Xbest_4, Scorebest_4,Convergence_curve_4]=ground_runoff(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
%地表/地下径流
[Xbest_5, Scorebest_5,Convergence_curve_5]=ground_runoff(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);

Best_Thresh =Xbest_2; %最大适应度值对应的阈值     %%%修改Xbest值
[Iout]=YuZhiplot(I,Best_Thresh);%将图像根据对应的阈值进行分割，得到分割图像Iout
display(['阿基米德获得最优阈值为 : ', num2str(Xbest_2)]);

% lable_img=im2bw(imread('sky\groundtruth\1-2.jpg'));
% lable_img=im2bw(imread('脑肿瘤图像\t2\2-1-1.jpg'));
% lable_img=im2bw(imread('data\脑肿瘤\DWI\3-1-1.jpg'));
lable_img=im2bw(imread('图片\gt-4.png'));
%III=im2bw(imread('sky\data\1-1.jpg'));
% III=im2bw(imread('脑肿瘤图像\t2\2-1-1.jpg'));
% III=im2bw(imread('data\脑肿瘤\DWI\3-1-1.jpg'));
III=im2bw(imread('图片\分割后\WCOA\4.jpg'));
[iou,yl] = Calc_IOU(lable_img,III);%计算交并比以及假阳率
[MSE,PSNR]=result(III,lable_img);%计算方差和信噪比

%lable_img=im2bw(imread('sky\groundtruth\0003_gt.pgm'));
%[iou,yl] = Calc_IOU(lable_img,Iout);%计算交并比以及假阳率
%[MSE,PSNR]=result(Iout,lable_img);%计算方差和信噪比
% figure(5)
% plot(Convergence_curve_2,'Color','b','linewidth',2) %显示迭代函数示意图
% title('适应度函数')
% xlabel('迭代次数');
% ylabel('适应度值');
% legend('Water-BAOA算法')