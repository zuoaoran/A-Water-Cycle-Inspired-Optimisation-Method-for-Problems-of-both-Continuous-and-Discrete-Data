function BP(a)
[~,n]=size(a);
input=a(:,1:(n-1));%输入数据
output=a(:,n);%标签
output=output';
%% 设置训练数据和预测数据
k=rand(7607);
%k=rand(127);
%k=rand(1683);
[m,n]=sort(k);
input_train=input(n(1:7406),:)';%训练样本
output_train=output(n(1:7406));%训练标签
%disp(output_train);
input_test=input(n(7407:7607),:)';%测试样本
output_test=output(n(7407:7607));%测试标签
%input_train=input(n(1:100),:)';%训练样本
%output_train=output(n(1:100));%训练标签
%input_test=input(n(101:127),:)';%测试样本
%output_test=output(n(101:127));%测试标签
%input_train=input(n(1:100),:)';%训练样本
%output_train=output(n(1:100));%训练标签
%input_test=input(n(101:127),:)';%测试样本
%output_test=output(n(101:127));%测试标签
%% 输入数据归一化
[inputn,inputps]=mapminmax(input_train);
[outputn,outputs]=mapminmax(output_train);
%% BP网络训练
% %初始化网络结构
net=newff(inputn,outputn,10);
% %网络参数
net.trainParam.epochs=1000;%训练次数
net.trainParam.lr=0.1;%学习速率
net.trainParam.goal=0.00000001;%训练目标最小误差
%% 网络训练
net=train(net,inputn,outputn);
%% BP网络预测
%预测数据归一化
inputn_test=mapminmax('apply',input_test,inputps);

%网络预测输出
test_simu=sim(net,inputn_test);%预测标签
test_simu=mapminmax('reverse',test_simu,outputs);

test_simu(find(test_simu<1.5))=1;
test_simu(find(test_simu>1.5&test_simu<2.5))=2;
test_simu(find(test_simu>2.5&test_simu<3.5))=3;
test_simu(find(test_simu>3.5))=4;
%% 预测与实际对比图
hSpectra1=figure;
set(hSpectra1, 'color', 'w', 'Name', 'Feature difference Chart')
plot(test_simu,'og-')
hold on
plot(output_test,'r*--');
grid on
title('BP网络预测分类与实际类别比对','fontsize',12)
ylabel('类别标签','fontsize',12)
xlabel('样本数目','fontsize',12)
ylim([-0.5 4.5])
error=test_simu-output_test;
hold on
plot(error,'square','MarkerFaceColor','b');
legend('预测数据','实际数据','误差');
%% 混淆矩阵
cm = confusionmat(output_test, test_simu);
disp(cm);
xvalues =   {'ALLERGY','COLD','COVID','FLU'};
yvalues = xvalues;
%xvalues =   {'ALLERGY','COLD'};
%yvalues = xvalues;
% Plot confusion matrix
hCM = figure; set(hCM, 'Color', 'w', 'Name', 'Confusion Matrix')
h = heatmap(xvalues,yvalues,cm);
%colormap(gca, 'gray');
h.Title = 'Disease Case Classifications';
h.XLabel = 'Predicted Label';
h.YLabel = 'True Label';
h.FontSize = 11;
Accuracy=(cm(1,1)+cm(2,2)+cm(3,3)+cm(4,4))/(cm(1,1)+cm(1,2)+cm(1,3)+cm(1,4)+cm(2,1)+cm(2,2)+cm(2,3)+cm(2,4)+cm(3,1)+cm(3,2)+cm(3,3)+cm(3,4)+cm(4,1)+cm(4,2)+cm(4,3)+cm(4,4));
fprintf('\n 准确率= %g %%',Accuracy*100); fprintf('\n');