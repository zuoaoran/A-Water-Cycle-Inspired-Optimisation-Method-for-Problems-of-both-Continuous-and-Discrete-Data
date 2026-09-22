clc
clear
close all
%%
%nPop=50; % 种群数
Materials_no=50;
Max_iter=500; % 最大迭代次数

dim = 30; % 可选 2, 10, 30, 50, 100
C3=1;C4=2;  %standard Optimization functions
Scorebest_5=1:1:30;
%%  选择函数

Function_name=30; % 函数名： 1 - 30 别跑2啦啊啊啊
[lb,ub,dim,fobj] = Get_Functions_cec2017(Function_name,dim);

for i=1:5
%% 调用算法
tic
%[Best_score,Best_pos,cg_curve]=WOA(nPop,Max_iter,lb,ub,dim,fobj);
[Xbest, Scorebest,cg_curve]=oil_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
[Xbest_1, Scorebest_1,cg_curve_1]=plant_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
[Xbest_2, Scorebest_2,cg_curve_2]=ocean_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
[Xbest_3, Scorebest_3,cg_curve_3]=atmo_rain(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
[Xbest_4, Scorebest_4,cg_curve_4]=ground_runoff(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
toc
Scorebest_5(i)=Scorebest_4;
end

STD=std(Scorebest_5);
disp(STD);

%% plot
figure('Position',[400 200 300 250])
semilogy(cg_curve_4,'Color','r','Linewidth',1)
%     plot(cg_curve,'Color','r','Linewidth',1)
title(['Convergence curve, Dim=' num2str(dim)])
xlabel('Iteration');
ylabel(['Best score F' num2str(Function_name) ]);
axis tight
grid on
box on
set(gca,'color','none')
legend('WTCOA')

result = cg_curve_4';
xlswrite('6.xlsx',result,1,'D1:D500')%将变量按行导入表格指定位置