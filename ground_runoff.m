function [ Scorebest, Xbest,Convergence_curve]=ground_runoff(Materials_no, Max_iter, lb,ub, dim,C3,C4,...
                                              trainData,testData,trainlabel,testlabel)
%function [Xbest, Scorebest,Convergence_curve] = AOA(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4)
disp('ground_runoff is now estimating the global optimum for your problem....')
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


%% Initialization初始化
C1=2;C2=6;
u=.9;l=.1;   %paramters in Eq. (12)
X=round(initialization(Materials_no,dim,ub,lb));%initial positions Eq. (4)
den=rand(Materials_no,dim); % Eq. (5)
vol=rand(Materials_no,dim);
acc=round(initialization(Materials_no,dim,ub,lb));% Eq. (6)
Convergence_curve=zeros(1,Max_iter);
for i=1:Materials_no
%     Y(i)=fobj(X(i,:));
     if flag == 1%开始是奇数，更新后变为偶数
    X(i,1:end-1) =checkempty(X(i,1:end-1),dim,flag);%检查0，GrassHopperPositions是N*dim的矩阵
   %所以GrassHopperPositions的每一行是1*dim的矩阵，因为代码中处理的是偶数的dim，所以flag=1，表明原来的dim是奇数，+1才变成的偶数，所以要让列数减1
        Y(1,i)=objfun(X(i,1:end-1),...
                                trainData,testData,trainlabel,testlabel,dim);%GrassHopperFitness是1*N的矩阵
                            %利用objfun里的适应度函数，更新每个蝗虫的适应度值
 %A(i,1:end-1)的意思是A数组=A数组的第i行从第一列到第end-1列。
     else
          X(i,:) =checkempty(X(i,:),dim,flag);
        Y(1,i)=objfun(X(i,:),...
                                trainData,testData,trainlabel,testlabel,dim);
    end
end
[Scorebest, Score_index] = min(Y);
Xbest = X(Score_index,:);
den_best=den(Score_index,:);
vol_best=vol(Score_index,:);
acc_best=acc(Score_index,:);
acc_norm=acc;


%%
for t = 1:Max_iter
    TF=exp(((t-Max_iter)/(Max_iter)));   % Eq. (8)
    if TF>1
        TF=1;
    end
    d=exp((Max_iter-t)/Max_iter)-(t/Max_iter); % Eq. (9)
    acc=acc_norm;
    r=rand();
    for i=1:Materials_no
        den(i,:)=den(i,:)+r*(den_best-den(i,:));   % Eq. (7)
        vol(i,:)=vol(i,:)+r*(vol_best-vol(i,:));
        if TF<.45%collision
            mr=randi(Materials_no);
            acc_temp(i,:)=(den(mr,:)+(vol(mr,:).*acc(mr,:)))./(rand*den(i,:).*vol(i,:));   % Eq. (10)
        else
            acc_temp(i,:)=(den_best+(vol_best.*acc_best))./(rand*den(i,:).*vol(i,:));   % Eq. (11)
        end
    end
    
    acc_norm=((u*(acc_temp-min(acc_temp(:))))./(max(acc_temp(:))-min(acc_temp(:))))+l;   % Eq. (12)
    
    
Lsum=0;
L1=0;
L2=0;
L3=0;
L4=0;
L5=0;
L6=0;
L7=0;
L8=0;
L9=0;
xbest=[0 0 0 0 0 1 0 1 0];
    for i=1:Materials_no
        if TF<.4
            for j=1:size(X,2)
                mrand=randi(Materials_no);
                Xnew(i,j)=X(i,j)+C1*rand*acc_norm(i,j).*(X(mrand,j)-X(i,j))*d;  % Eq. (13)
            end
        else
            for j=1:size(X,2)
                p=2*rand-C4;  % Eq. (15)
                T=C3*TF;
                if T>1
                    T=1;
                end
                if p<.5
                    Xnew(i,j)=Xbest(j)+C2*rand*acc_norm(i,j).*(T*Xbest(j)-X(i,j))*d;  % Eq. (14)
                else
                    Xnew(i,j)=Xbest(j)-C2*rand*acc_norm(i,j).*(T*Xbest(j)-X(i,j))*d;
                end
            end
        end
        
deltaX=Xnew; 
for tt=1:size(deltaX,2)
 T_deltaX(tt)=0.64*abs(atan(deltaX(tt))*(i/(sqrt((1+deltaX(tt)*deltaX(tt))))));
 %T_deltaX(tt)=0.56*abs(atan(deltaX(tt))*(i/(sqrt((1+deltaX(tt)*deltaX(tt))))));
 %T_deltaX(tt)=0.48*abs(atan(deltaX(tt))*(i/(sqrt((1+deltaX(tt)*deltaX(tt))))));
 %T_deltaX(tt)=0.40*abs(atan(deltaX(tt))*(i/(sqrt((1+deltaX(tt)*deltaX(tt))))));
 %T_deltaX(tt)=0.32*abs(atan(deltaX(tt))*(i/(sqrt((1+deltaX(tt)*deltaX(tt))))));
 %T_deltaX(tt)=0.24*abs(atan(deltaX(tt))*(i/(sqrt((1+deltaX(tt)*deltaX(tt))))));
 %T_deltaX(tt)=0.16*abs(atan(deltaX(tt))*(i/(sqrt((1+deltaX(tt)*deltaX(tt))))));
 %T_deltaX(tt)=0.08*abs(atan(deltaX(tt))*(i/(sqrt((1+deltaX(tt)*deltaX(tt))))));
   if rand<T_deltaX(tt)
   X_new(tt) =1;
   else
   X_new(tt)=0;
   end
   if tt==1
       if X_new(tt) ==1||xbest(tt)==1
       L1=1;
       else
       L1=0;
       end
   end
   if tt==2
       if X_new(tt) ==1||xbest(tt)==1
       L2=1;
       else
       L2=0;
       end
   end
   if tt==3
       if X_new(tt) ==1||xbest(tt)==1
       L3=1;
       else
       L3=0;
       end
   end
   if tt==4
      if X_new(tt) ==1||xbest(tt)==1
       L4=1;
       else
       L4=0;
       end
   end
   if tt==5
      if X_new(tt) ==1||xbest(tt)==1
       L5=1;
       else
       L5=0;
       end
   end
   if tt==6
      if X_new(tt) ==1||xbest(tt)==1
       L6=1;
       else
       L6=0;
       end
   end
   if tt==7
       if X_new(tt) ==1||xbest(tt)==1
       L7=1;
       else
       L7=0;
       end
   end
   if tt==8
      if X_new(tt) ==1||xbest(tt)==1
       L8=1;
       else
       L8=0;
       end
   end
   if tt==9
       if X_new(tt) ==1||xbest(tt)==1
       L9=1;
       else
       L9=0;
       end
   end
  Lsum=Lsum+L1+L2+L3+L4+L5+L6+L7+L8+L9;
 end%更新第i物体在各个维度的位置
GrassHopperPositions_temp(i,:)=X_new'; % GrassHopperPositions_temp数组是N*dim
Xnew=(GrassHopperPositions_temp);
end
    
%      Xnew=checkempty(Xnew(i,:),dim);
    for i=1:Materials_no
         if flag == 1%开始是奇数，更新后变为偶数
         Xnew(i,1:end-1) =checkempty(Xnew(i,1:end-1),dim,flag);
            %检查全0，GrassHopperPositions是N*dim的矩阵
 %GrassHopperPositions每一行是1*dim的矩阵，因为代码处理的是偶数的dim，所以flag=1，表明原来的dim是奇数，+1以后变为了偶数，所以是end-1
            v=objfun(Xnew(i,1:end-1),...
                                trainData,testData,trainlabel,testlabel,dim);
     %GrassHopperFitness是1*N的矩阵，利用objfun里的适应度函数，更新每个蝗虫的适应度值
         else
            Xnew(i,:) =checkempty(Xnew(i,:),dim,flag);
            v=objfun(Xnew(i,:),...
                                trainData,testData,trainlabel,testlabel,dim);
        end
%         
%         v=fobj( Xnew(i,:));
        if v<Y(i)
            X(i,:)=Xnew(i,:);
            Y (i)=v;
        end
        
    end    %更新适应度值  
    [var_Ybest,var_index] = min(Y);
  
    if var_Ybest<Scorebest
        Scorebest=var_Ybest;
        Score_index=var_index;
        Xbest = X(var_index,:);
        den_best=den(Score_index,:);
        vol_best=vol(Score_index,:);
        acc_best=acc_norm(Score_index,:);
    end  %更新最优适应度值
  Convergence_curve(t)=Scorebest; 
 disp(['In AOA iteration #', num2str(t), ' , target''s objective = ', num2str( Scorebest)]);
 L=Lsum/Materials_no;
 disp(L);
end

if (flag==1)%经过+1以后变为偶数
     Xbest =  Xbest (1:dim-1);%TargetPosition是1*dim的矩阵,所以dim要减1
end
end

% function vec_pos=fun_checkpositions(dim,vec_pos,var_no_group,lb,ub)
% for i=1:var_no_group
%     isBelow1 = vec_pos(i,:) < lb;
%     isAboveMax = (vec_pos(i,:) > ub);
%     if isBelow1 == true
%         vec_pos(i,:) =lb;
%     elseif find(isAboveMax== true)
%         vec_pos(i,:) = ub;
%     end
% end
% end


