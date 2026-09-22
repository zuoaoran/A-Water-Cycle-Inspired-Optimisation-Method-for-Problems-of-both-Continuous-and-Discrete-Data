
function[Best_score,Best_pos,GOA_curve]=GOA(SearchAgents,Max_iterations,lowerbound,upperbound,dimension,fitness)
lowerbound=ones(1,dimension).*(lowerbound);                              % Lower limit for variables
upperbound=ones(1,dimension).*(upperbound);                              % Upper limit for variables
%%
for i=1:dimension
    X(:,i) = lowerbound(i)+rand(SearchAgents,1).*(upperbound(i) - lowerbound(i));                          % Initial population
end
for i =1:SearchAgents
    L=X(i,:);
    fit(i)=fitness(L);
end
%%
for t=1:Max_iterations
    %% update the best member and worst member
    [best , blocation]=min(fit);
    if t==1
        Xbest=X(blocation,:);                                           % Optimal location
        fbest=best;                                           % The optimization objective function
    elseif best<fbest
        fbest=best;
        Xbest=X(blocation,:);
    end
    
    
    %% update GOA population
    
    for i=1:SearchAgents
        
        %% Phase 1: Exploration
        if rand <0.5
            I=round(1+rand(1,1));
            RAND=rand(1,1);
        else
            I=round(1+rand(1,dimension));
            RAND=rand(1,dimension);
        end
        
        X_P1(i,:)=X(i,:)+RAND .* (Xbest-I.*X(i,:)); % Eq. (4)
        X_P1(i,:) = max(X_P1(i,:),lowerbound);X_P1(i,:) = min(X_P1(i,:),upperbound);
        
        % update position based on Eq (5)
        L=X_P1(i,:);
        F_P1(i)=fitness(L);
        if F_P1(i)<fit(i)
            X(i,:) = X_P1(i,:);
            fit(i) = F_P1(i);
        end
        %
        %% END Phase 1: Exploration (global search)
        
    end% END for i=1:SearchAgents
    
    %%
    %% Phase 2: exploitation (local search)
    for i=1:SearchAgents
            X_P2(i,:)= X(i,:)+ (1-2*rand(1,1)) .* ( lowerbound./t+rand(1,1).*(upperbound./t-lowerbound./t));%Eq(6)
            X_P2(i,:) = max(X_P2(i,:),lowerbound./t);X_P2(i,:) = min(X_P2(i,:),upperbound./t);
            X_P2(i,:) = max(X_P2(i,:),lowerbound);X_P2(i,:) = min(X_P2(i,:),upperbound);  
        
        % update position based on Eq (7)
        L=X_P2(i,:);
        F_P2(i)=fitness(L);
        if F_P2(i)<fit(i)
            X(i,:) = X_P2(i,:);
            fit(i) = F_P2(i);
        end
        %
        
    end % END for i=1:SearchAgents
    
    %% END Phase 2: exploitation (local search)
    
end% END for t=1:Max_iterations
Best_score=fbest;
Best_pos=Xbest;
GOA_curve(t)=fbest;
end
