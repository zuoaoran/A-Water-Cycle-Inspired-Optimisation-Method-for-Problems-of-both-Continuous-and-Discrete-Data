%% 微信公众号：优化算法侠，Swarm-Opti
clc;clear;close all
%% 获取优化问题的信息
% type = 1:选择优化拉力/压缩弹簧设计问题
% type = 2:选择优化压力容器设计问题
% type = 6:选择优化齿轮系设计问题
% type = 10:选择优化步锥滑轮问题
% type = 12:选择优化机器人抓手问题

iteration=12;
Scorebest_1=1:1:30;
Scorebest_2=1:1:30;
Scorebest_3=1:1:30;
Scorebest_4=1:1:30;
Scorebest_5=1:1:30;
Scorebest_6=1:1:30;
Scorebest_7=1:1:30;

type = 1;
[lb,ub,dim,fobj] = Engineering_Problems(type);

%% 调用算法
nPop=50; % 种群数
Max_iter=500; % 最大迭代次数

Optimal_results={}; % 保存Optimal results
index = 1;

% TWCOA
for i = 1:iteration
tic
[Best_score,Best_x,cg_curve]=TWCOA(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,index}="TWCOA";
Optimal_results{2,index}=cg_curve;
Optimal_results{3,index}=Best_score;
score7=Best_score;
Optimal_results{4,index}=Best_x;
Optimal_results{5,index}=toc;
index = index +1;
Scorebest_7(i)=Best_score;
end
STD7=std(Scorebest_5,0,2);
disp(STD7);

% FA
for i = 1:iteration
tic
[Best_score,Best_x,cg_curve]=DBO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,index}="DBO";         % 算法名字
Optimal_results{2,index}=cg_curve;      % 收敛曲线
Optimal_results{3,index}=Best_score;   % 最优函数值
score1=Best_score;
Optimal_results{4,index}=Best_x;          % 最优变量
Optimal_results{5,index}=toc;               % 运行时间
index = index +1;
Scorebest_1(i)=Best_score;
end
STD1=std(Scorebest_5,0,2);
disp(STD1);

% HHO
for i = 1:iteration
tic
[Best_score,Best_x,cg_curve]=HHO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,index}="HHO";
Optimal_results{2,index}=cg_curve;
Optimal_results{3,index}=Best_score;
score2=Best_score;
Optimal_results{4,index}=Best_x;
Optimal_results{5,index}=toc;
index = index +1;
Scorebest_2(i)=Best_score;
end
STD2=std(Scorebest_5,0,2);
disp(STD2);

% GWO
for i = 1:iteration
tic
[Best_score,Best_x,cg_curve]=GWO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,index}="GWO";
Optimal_results{2,index}=cg_curve;
Optimal_results{3,index}=Best_score;
score3=Best_score;
Optimal_results{4,index}=Best_x;
Optimal_results{5,index}=toc;
index = index +1;
Scorebest_3(i)=Best_score;
end
STD3=std(Scorebest_5,0,2);
disp(STD3);

% SO
for i = 1:iteration
tic
[Best_score,Best_x,cg_curve]=SO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,index}="SO";
Optimal_results{2,index}=cg_curve;
Optimal_results{3,index}=Best_score;
score4=Best_score;
Optimal_results{4,index}=Best_x;
Optimal_results{5,index}=toc;
index = index +1;
Scorebest_4(i)=Best_score;
end
STD4=std(Scorebest_5,0,2);
disp(STD4);

% DO
for i = 1:iteration
tic
[Best_score,Best_x,cg_curve]=DO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,index}="DO";
Optimal_results{2,index}=cg_curve;
Optimal_results{3,index}=Best_score;
score5=Best_score;
Optimal_results{4,index}=Best_x;
Optimal_results{5,index}=toc;
index = index +1;
Scorebest_5(i)=Best_score;
end
STD5=std(Scorebest_5,0,2);
disp(STD5);

% WFO
for i = 1:iteration
tic
[Best_score,Best_x,cg_curve]=WFO(nPop,Max_iter,lb,ub,dim,fobj);
Optimal_results{1,index}="WFO";
Optimal_results{2,index}=cg_curve;
Optimal_results{3,index}=Best_score;
score6=Best_score;
Optimal_results{4,index}=Best_x;
Optimal_results{5,index}=toc;
index = index +1;
Scorebest_6(i)=Best_score;
end
STD6=std(Scorebest_5,0,2);
disp(STD6);



%% plot绘图
figure
for i = 1:size(Optimal_results, 2)
    if type == 6 || 9
        Optimal_results{4, i}= round(Optimal_results{4, i});
    end
    if type==7
        Optimal_results{2, i}=-Optimal_results{2, i};
        Optimal_results{3, i}=-Optimal_results{3, i};
        Optimal_results{4, i}(3) = round(Optimal_results{4, i}(3));
    end
%     plot(Optimal_results{2, i},'Linewidth',2)
    semilogy(Optimal_results{2, i},'Linewidth',2)
    hold on
end
title(['Convergence curve'])
xlabel('Iteration');
ylabel(['Best score']);
ax = gca;
set(ax,'Tag',char([100,105,115,112,40,39,20316,32773,58,...
    83,119,97,114,109,45,79,112,116,105,39,41]));
grid on
box on
set(gcf,'Position',[400 200 400 250]);
eval(ax.Tag)
legend(Optimal_results{1, :})

