clc
clear all
close all
while(1)
    clear
    clc
    sum=0;
    sum1=0;
    sum2=0;
    sum3=0;
    sum4=0;
    sum5=0;
    sum6=0;
    sum7=0;
    sum8=0;
    sum9=0;
    for m=1:1
        close all
        addpath(genpath(cd))
        %%载入数据集
        %load Cancer
        %load WDBC
        %load Parliment1984
        %load heartdata
        %load ionosphere
        %load covid-19
        %load severity
        %load Covid
        %load covid19-symptoms-dataset-1
        %load all_training6(1)
%         load data
%         load severity
%         load lungsound1972
%         load lungsound230
%         load data_315
        load 肺炎
%         load 肝炎
%         load 糖尿病
%         load 心脏病


        % preprocess data to remove Nan entries  移出非数字项Nan Not a Number
        for ii=1:size(Tdata,2)%for(ii=1;i<=Tdata的列数;ii++)
        %for ii=1:size(data_315,2)%for(ii=1;i<=Tdata的列数;ii++)
            nanindex=isnan(Tdata(:,ii));%返回一个与Tata所在的第ii列相同的大小的数组，如果元素为NaN则为1，其他为0
            %nanindex=isnan(data_315(:,ii));
            Tdata(nanindex,:)=[];%A(B,:)表示把A中B为1的那些行提取出来，比如B=logical（[1;0;1]),A(B,:)就是提取A的第1行和第3行
            %data_315(nanindex,:)=[];
            %A(B,:)=[]的意思就是把提取出来的行置空
        end
        labels=Tdata(:,end);%labels=Tdata数组的最后一列  是标签
        %labels=data_315(:,end);
        %classes  分类数：Tdata的行数
        attributesData=Tdata(:,1:end-1);      %把数组Tdata从第一列到倒数第二列提取出来，组成数组attributeData
        %attributesData=data_315(:,1:end-1);
        [rows,colms]=size(attributesData);  %size of data  数据大小
        [trainIdx,~,testIdx]=dividerand(rows,0.8,0,0.2);%按照行数将目标随机分为两组 8 2分组
        trainData=attributesData(trainIdx,:);   %training data 训练集
        testData=attributesData(testIdx,:);     %testing data  测试集
        trainlabel=labels(trainIdx);            %training labels 训练标签
        testlabel=labels(testIdx);              %testing labels 测试标签
        %% KNN classification
        Mdl = fitcknn(trainData,trainlabel,'NumNeighbors',5,'Standardize',1);%输入训练数据获得模型
        predictedLables_KNN=predict(Mdl,testData);%用模型对测试数据进行预测
        cp=classperf(testlabel,predictedLables_KNN);%创建classperformance对象cp
        err=cp.ErrorRate;%获得错误率
        accuracy=cp.CorrectRate;%获得正确率
        fprintf('\n knn accuracy: %g %%',accuracy*100); fprintf('\n');

        dim=size(attributesData,2);%dim=attribute的列数 维度
        lb=0;ub=1;
        %% BPSO
        feat= Tdata(:,1:end-1);
        %feat= data_315(:,1:end-1);
        label = Tdata(:,end);
        %label = data_315(:,end);

        % Set 20% data as validation set
        ho = 0.2;
        % Hold-out method
        HO = cvpartition(label,'HoldOut',ho);

        % Parameter setting
        N        = 10;
        max_Iter = 1;
        c1       = 1;     % cognitive factor
        c2       = 1;     % social factor
        w        = 3;     % inertia weight

        % Particle Swarm Optimization
        [sFeat,Sf,Nf,curve,fitG] = jPSO(feat,label,N,max_Iter,c1,c2,w,HO);

        % Accuracy 准确率
        Acc=jKNN(sFeat,label,HO);

        fprintf('\n Accuracy: %g %%',Acc*100); fprintf('\n');
        fprintf('Feature number: %g',Nf); fprintf('\n');

        % Plot convergence curve
        %plot(1:max_Iter,curve);
        %xlabel('Number of iterations');
        %ylabel('Fitness Value');
        %title('PSO'); grid on;


        % ddd1(m)=accuracy_GOA;sum1=sum1+ddd1(m); %BGOA准确率
        % % ddd2(m)=accuracy_SA;sum2=sum2+ddd2(m); %SA准确率
        ddd7(m)=Acc;sum7=sum7+ddd7(m); %准确率

        % ddd3(m)=Target_score; sum3=sum3+ddd3(m);%BGOA历史适应度
        % % ddd4(m)=fval;sum4=sum4+ddd4(m);%SA适应度值
        ddd8(m)=fitG; sum8=sum8+ddd8(m); %适应度

        % ddd5(m)=numel(find(Target_pos));sum5=sum5+ddd5(m);  %BGOA特征数
        % % ddd6(m)=numel(find(Target_pos_SA));sum6=sum6+ddd6(m); %SA特征数
        ddd9(m)=Nf;sum9=sum9+ddd9(m); %特征数



        % toc
        %if(m>=1)
        if (m>=10)
            %sum=(sum)/30
            % sum1=(sum1)/20
            %sum2=(sum2)/10
            % sum3=(sum3)/20
            %sum4=(sum4)/10
            % sum5=(sum5)/20
            %sum6=(sum6)/10
            % sum9=(sum9)/10
            break;
        end


        %% BGOA optimisation for feature selection
        SearchAgents_no=30; % Number of search agents
        Max_iteration=1; % Maximum numbef of iterations
        [Target_score,Target_pos,GOA_cg_curve]=binaryGOA(SearchAgents_no,Max_iteration,lb,ub,dim,...
            trainData,testData,trainlabel,testlabel);%利用binaryGOA算法处理数据得到特征子集
        %Target_score最优适应度值 Target_pos对应的位置 GOA_cg_curve历史适应度值变化
        % final evaluation for GOA tuned selected features
        [error_GOA,accuracy_GOA,predictedLables_GOA]=finalEval(Target_pos,trainData,testData,trainlabel,testlabel);
        %finalEval里有knn训练器，对GOA算法的选出的特征子集进行准确性的评估
      
        %% AOA optimisation for feature selection
        SearchAgents_no=30;
        Max_iteration=1;
        % C3=2;C4=.5;  %cec and engineering problems
        C3=1;C4=2;  %standard Optimization functions

        %土壤蒸发过程
        [Target_score_1,Target_pos_1,AOA_cg_curve]=oil_evaporation(SearchAgents_no,Max_iteration,lb,ub,dim,C3,C4,...
            trainData,testData,trainlabel,testlabel);
        %植物蒸腾作用
        [Target_score_2,Target_pos_2,AOA_cg_curve_2]=plant_evaporation(SearchAgents_no,Max_iteration,lb,ub,dim,C3,C4,...
            trainData,testData,trainlabel,testlabel);
        %海洋蒸发过程
        [Target_score_3,Target_pos_3,AOA_cg_curve_3]=ocean_evaporation(SearchAgents_no,Max_iteration,lb,ub,dim,C3,C4,...
            trainData,testData,trainlabel,testlabel);
        %大气降水过程
        [Target_score_4,Target_pos_4,AOA_cg_curve_4]=atmo_rain(SearchAgents_no,Max_iteration,lb,ub,dim,C3,C4,...
            trainData,testData,trainlabel,testlabel);
        %地表/地下径流
        [Target_score_5,Target_pos_5,AOA_cg_curve_5]=ground_runoff(SearchAgents_no,Max_iteration,lb,ub,dim,C3,C4,...
            trainData,testData,trainlabel,testlabel);
        

        % final evaluation for GOA tuned selected features
        [error_AOA,accuracy_AOA,predictedLables_AOA]=finalEval(Target_pos_2,trainData,testData,trainlabel,testlabel);    %%%  这块的Target_pos_1也要改一下
        %finalEval里有knn训练器对AOA算法的选出的特征子集进行准确性的评估
        ddd(m)=accuracy_GOA;
        sum=sum+ddd(m); %BGOA准确率
        ddd1(m)=accuracy_AOA;
        sum1=sum1+ddd1(m); %SA准确率
        ddd2(m)=accuracy;
        sum2=sum2+ddd2(m); %knn准确率
        %
        ddd3(m)=Target_score;
        sum3=sum3+ddd3(m);%BGOA历史适应度
        ddd4(m)=Target_score_2;    %%% Target_pos_1参数需要改一下
        sum4=sum4+ddd4(m);%AOA适应度值

        ddd5(m)=numel(find(Target_pos));sum5=sum5+ddd5(m);  %BGOA特征数
        ddd6(m)=numel(find(Target_pos_2));sum6=sum6+ddd6(m); %A0A特征数         %%% Target_pos_1参数需要改一下
    end

    if (m>=1)
        % sum=(sum)/20
        % sum1=(sum1)/20
        % sum2=(sum2)/20
        % sum3=(sum3)/20
        % sum4=(sum4)/20
        % sum5=round((sum5)/20)
        % sum6=round((sum6)/20)


        figure
        subplot(1,2,1)
        labels={num2str(sum9),num2str(sum6),num2str(sum5)};
        %eg:设A=magic（3），num2str(size(A,2))=‘3’
        pie([numel(sum9),numel(sum6),numel(sum5)],labels)%绘制出圆饼图
        %labels={num2str(size(testData,2)),num2str(sum6),num2str(sum5)};
        %eg:设A=magic（3），num2str(size(A,2))=‘3’
        %pie([(size(testData,2)),numel(sum6),numel(sum5)],labels)%绘制出圆饼图
        title('Number of features selected')
        legendlabels={'Features after BPSO Features','Features after WCOA Selection','Features after BGOA Selection'};
        legend(legendlabels,'Location','southoutside','Orientation','vertical')
        subplot(1,2,2)
        labels={num2str(sum7*100),num2str(sum1*100),num2str(sum*100)};
        pie([sum7,sum1,sum].*100,labels)
        %labels={num2str(sum2*100),num2str(sum1*100),num2str(sum*100)};
        %pie([sum2,sum1,sum].*100,labels)
        title('Accuracy for features selected')
        legendlabels={'Features after BPSO Selection','Features after WCOA Selection','Features after BGOA Selection'};
        legend(legendlabels,'Location','southoutside','Orientation','vertical')
        %Location 在轴下方，方向为“垂直”-垂直堆叠图例项目。
        break;
    end
end