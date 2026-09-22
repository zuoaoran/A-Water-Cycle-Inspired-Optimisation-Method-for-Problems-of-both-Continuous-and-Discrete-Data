function objval=objfun(index,trainigdata ,testingdata,trainiglabels,testinglabels,N)%N代表的是dim
index=round(index);%将index中的每一元素都四舍五入取最接近的整数
index = checkempty(index,N);%利用checkempty函数把数组index中某一行全部为0的进行替换，保证每一行中至少有一个元素不为0，1*dim
newtrainigdata=trainigdata(:,find(index));%find函数的作用是把数组index中不为零的元素所在位置按照列向量排列
newtestingdata=testingdata(:,find(index));
%A =
 %     8     1     6
 %     3     5     7
  %    4     9     2
%index=[0,4,1]
%find(index)=2 3
%newtrainigdata=A(:,find(index))
%newtrainigdata =取lA的第二列和第三列
     %1     6
     %5     7
     %9     2 
Mdl = fitcknn(newtrainigdata,trainiglabels,'NumNeighbors',5,'Standardize',1);%knn分类器
%Mdl是经过训练的ClassificationKNN分类器，其某些属性显示在“命令窗口”中。
%训练5个最近邻居分类器。 标准化非分类预测数据。
Y=predict(Mdl,newtestingdata);%预测命令预测在测量数据的时间跨度内的输出响应
%相比之下，预测将在超出测量数据最后一瞬间的时间范围内对未来进行预测。 使用预测可在测量数据的时间范围内验证Mdl。
cp=classperf(testinglabels,Y);%cp = classperf（groundTruth，classifierOutput）使用真实标签groundTruth创建一个类性能对象cp，
%然后根据分类器classifierOutput的结果更新对象属性。
%使用真实标签testinglabels创建一个类性能对象cp,然后根据分类器Mdl的结果Y更新对象属性
err=cp.ErrorRate;%已知分类器的分类错误率
R=numel(find(index==1));%数组index中等于1的个数
alpha=0.99;
beta=1-alpha;
objval=alpha*err+beta*(R/N);%适应度函数公式