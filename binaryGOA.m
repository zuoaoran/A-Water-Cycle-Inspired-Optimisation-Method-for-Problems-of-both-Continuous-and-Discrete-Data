% The Grasshopper Optimization Algorithm
function [TargetFitness,TargetPosition,Convergence_curve]=binaryGOA(N, Max_iter, lb,ub, dim,...
                                              trainData,testData,trainlabel,testlabel)
 
disp('GOA is now estimating the global optimum for your problem....')
flag=0;
if size(ub,1)==1%如果ub是一个单独的数
    ub=ones(dim,1)*ub;%创建一个dim*1的数组，数组里的每个数都为ub
    lb=ones(dim,1)*lb;%创建一个dim*1的数组，数组里的每个数都为lb
end
 
if (rem(dim,2)~=0) % this algorithm should be run with a even number of variables. 
    %This line is to handle odd number of variables
     %该算法应使用偶数个变量运行。 该行用于处理奇数个变量
    dim = dim+1;
    ub = [ub; 100];%改变数组ub，最后一行是100
    lb = [lb; -100];%改变数组lb，最后一行是-100
    flag=1;%开始是奇数，更新后变为偶数
end
 
%Initialize the population of grasshoppers初始化蝗虫种群
 
GrassHopperPositions=round(initialization(N,dim,ub,lb));%利用函数initialization初始化蝗虫位置，N*dim的矩阵
GrassHopperFitness = zeros(1,N);%c初始化蝗虫适应值为1*N的0矩阵
Convergence_curve=zeros(1,Max_iter);%收敛曲线为1*最大迭代次数的0数组

cMax=1;%c的最大值为1
cMin=0.00001;%c的最小值为0.00001

%Calculate the fitness of initial grasshoppers计算初始蝗虫的适应度
for i=1:size(GrassHopperPositions,1)%for(i=1;i<=N;i++)
    if flag == 1%开始是奇数，更新后变为偶数
        GrassHopperPositions(i,1:end-1) =checkempty(GrassHopperPositions(i,1:end-1),dim,flag);%检查0，GrassHopperPositions是N*dim的矩阵
   %所以GrassHopperPositions的每一行是1*dim的矩阵，因为代码中处理的是偶数的dim，所以flag=1，表明原来的dim是奇数，+1才变成的偶数，所以要让列数减1
        GrassHopperFitness(1,i)=objfun(GrassHopperPositions(i,1:end-1),...
                                trainData,testData,trainlabel,testlabel,dim);%GrassHopperFitness是1*N的矩阵
                            %利用objfun里的适应度函数，更新每个蝗虫的适应度值
 %A(i,1:end-1)的意思是A数组=A数组的第i行从第一列到第end-1列。
    else
        GrassHopperPositions(i,:) = checkempty(GrassHopperPositions(i,:),dim,flag);
        GrassHopperFitness(1,i)=objfun(GrassHopperPositions(i,:),...
                                trainData,testData,trainlabel,testlabel,dim);
    end
end
 
[sorted_fitness,sorted_indexes]=sort(GrassHopperFitness);%GrassHopperFitness是1*N的矩阵
%把数组GrassHopperFitness按照从小到大的顺序排列得到sorted_fitness，对应的下标组成的数组sorted_indexes
% A=[3,1,4,6]
%sorted_fitness = 1     3     4     6
%sorted_indexes = 2     1     3     4
% Find the best grasshopper (target) in the first population 在第一个种群中找到最好的蝗虫（目标）
for newindex=1:N
    Sorted_grasshopper(newindex,:)=GrassHopperPositions(sorted_indexes(newindex),:);%GrassHopperPositions是N*dim的矩阵
   %Sorted_grasshopper是N*dim的矩阵
    %sorted_indexes(newindex)的意思是取数组sorted_indexes的第newindex个数
end
TargetPosition=Sorted_grasshopper(1,:);%TargetPosition是1*dim的矩阵
TargetFitness=sorted_fitness(1);%sorted_fitness(1)的意思是取数组sorted_fitness的第1个数

% Main loop
l=2; % Start from the second iteration since the first iteration was 
       %dedicated to calculating the fitness of antlions
%%
while l<Max_iter+1
 c=(cMax-l*((cMax-cMin)/Max_iter)); 
    for i=1:size(GrassHopperPositions,1)%for(i=1;i<=N;i++)
        temp= GrassHopperPositions';%temp数组是GrassHopperPositions数组的转置以后的结果,temp是dim*N的矩阵
        for k=1:2:dim%for(k=1;k<=dim;k=k+2)
            S_i=zeros(2,1);%S_i是2*1的0矩阵
            for j=1:N%for(j=1;j<=N;j++)
                if i~=j%if(i!=j)
                    % Calculate the distance between two grasshoppers
                    Dist=distance(temp(k:k+1,j), temp(k:k+1,i)); 
                    %temp(k:k+1,j)取矩阵temp的的（k,j）和（k+1,j）组成的矩阵，2*1的矩阵
                    r_ij_vec=(temp(k:k+1,j)-temp(k:k+1,i))/(Dist+eps); % xj-xi/dij in Eq.8
                    xj_xi=2+rem(Dist,2); % |xjd - xid| in Eq. (2.7) 
                    %rem(a,b)返回a除以b后的余数，其中a是被除数，b是除数。
                    s_ij=((ub(k:k+1) - lb(k:k+1))*c/2)*S_func(xj_xi).*r_ij_vec; % The first part inside the big bracket in Eq.8，大括号的第一部分
                    S_i=S_i+s_ij;
                end
            end
            S_i_total(k:k+1, :) = S_i;
            %数组S_i_total k行 k+1行用s_i替换
            %S_i_total是dim*1的矩阵
        end
       
       deltaX= c * S_i_total'+(TargetPosition);  % Eq.8 in the paper， TargetPosition是1*dim的矩阵，S_i_total'是1*dim的矩阵
        for tt=1:size(deltaX,2)
        T_deltaX(tt)=1/(1+exp(-deltaX(tt)));
          if rand<T_deltaX(tt)
           X_new(tt) =1;
         else
          X_new(tt)=0;
          end
      end%101~116更新第i蝗虫蝗虫在各个维度的位置
        GrassHopperPositions_temp(i,:)=X_new'; % GrassHopperPositions_temp数组是N*dim
    end%完成N个蝗虫在各个维度的位置，生成新的GrassHopperPositions
    % GrassHopperPositions
    GrassHopperPositions=(GrassHopperPositions_temp);%得到的数组GrassHopperPositions_temp是N*dim的矩阵
 
    %
  for i=1:size(GrassHopperPositions,1)%for(i=1;i<=N;i++)
        % Calculating the objective values for all grasshoppers计算所有蝗虫的目标值
        if flag == 1%开始是奇数，更新后变为偶数
            GrassHopperPositions(i,1:end-1) = checkempty(GrassHopperPositions(i,1:end-1),dim,flag);
            %检查全0，GrassHopperPositions是N*dim的矩阵
 %GrassHopperPositions每一行是1*dim的矩阵，因为代码处理的是偶数的dim，所以flag=1，表明原来的dim是奇数，+1以后变为了偶数，所以是end-1
            GrassHopperFitness(1,i)=objfun(GrassHopperPositions(i,1:end-1),...
                                trainData,testData,trainlabel,testlabel,dim);
     %GrassHopperFitness是1*N的矩阵，利用objfun里的适应度函数，更新每个蝗虫的适应度值
        else
            GrassHopperPositions(i,:) = checkempty(GrassHopperPositions(i,:),dim,flag);
            GrassHopperFitness(1,i)=objfun(GrassHopperPositions(i,:),...
                                trainData,testData,trainlabel,testlabel,dim);
        end %计算适应度值
        
        % Update the target
      if GrassHopperFitness(1,i)<TargetFitness%GrassHopperFitness是1*N的矩阵//如果第i只蝗虫的适应度小于目标适应度
            TargetPosition=GrassHopperPositions(i,:);%TargetPosition是1*dim的矩阵，GrassHopperPositions是N*dim
            %更新最优位置
            TargetFitness=GrassHopperFitness(1,i);%TargetFitness是一个数，更新目标适应度为当前蝗虫的适应度值
        end
    end 
    Convergence_curve(l)=TargetFitness;%1*Max_iter,Convergence_curve是记录每次迭代的TargetFitness
    disp(['In GOA iteration #', num2str(l), ' , target''s objective = ', num2str(TargetFitness)]);
    l = l + 1;
end

if (flag==1)%经过+1以后变为偶数
    TargetPosition = TargetPosition(1:dim-1);%TargetPosition是1*dim的矩阵,所以dim要减1
end


