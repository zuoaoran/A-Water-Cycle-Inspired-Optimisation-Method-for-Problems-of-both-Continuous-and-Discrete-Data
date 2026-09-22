% Water Flow Optimizer: A Nature-Inspired
% Evolutionary Algorithm for Global Optimization
function [fb,xb,con] = WFO(NP,max_nfe, lb,ub,dim,fobj)
% Water Flowing Optimizer
% Reference: 
% Kaiping Luo. Water Flow Optimizer: a nature-inspired evolutionary algorithm for global optimization.
% IEEE Transactions on Cybernetics, 2021.

prob.lb = lb; 
prob.ub = ub;
prob.fobj = fobj;
alg.pl = 0.3;
alg.pe = 0.7;
%% Initialization

if size(prob.lb,1)>size(prob.lb,2)
    lb = prob.lb'.*ones(1,dim);
else
    lb = prob.lb.*ones(1,dim);
end
if size(prob.ub,1)>size(prob.ub,2)
    ub = prob.ub'.*ones(1,dim);
else
    ub = prob.ub.*ones(1,dim);
end
fb = inf;
con = zeros(max_nfe,1);
X = zeros(NP,dim);
F = zeros(NP,1);
for i = 1:NP
    X(i,:) = lb+rand(1,dim).*(ub-lb);
    F(i) = prob.fobj(X(i,:)');
    if F(i)<fb
        fb = F(i);        
        xb = X(i,:);
    end
    con(i) = fb;
end
nfe = NP;
Y = zeros(NP,dim);
%% Evolution
while nfe < max_nfe    
    if rand < alg.pl %  laminar flow
        d = xb - X(ceil(rand*NP),:);
        for i = 1:NP
            Y(i,:) = X(i,:) + rand*d;
            ind = Y(i,:)>ub | Y(i,:)<lb;
            Y(i,ind) = X(i,ind);
        end
    else % turbulent flow
        for i = 1:NP
            Y(i,:) = X(i,:);
            k = ceil(rand*NP);
            while k==i
                k = ceil(rand*NP);
            end
            j1 = ceil(rand*dim);
            if rand < alg.pe % spiral flow
                theta = (2*rand-1)*pi;
                Y(i,j1) = X(i,j1)+abs(X(k,j1)-X(i,j1))*theta*cos(theta);
                if Y(i,j1)>ub(j1) || Y(i,j1)<lb(j1)
                    Y(i,j1) = X(i,j1);
                end
            else
                j2 = ceil(rand*dim);
                while j2==j1
                    j2 = ceil(rand*dim);
                end
                Y(i,j1) = lb(j1)+(ub(j1)-lb(j1))*(X(k,j2)-lb(j2))/(ub(j2)-lb(j2));
            end
        end
    end
    for i = 1:NP
        f = prob.fobj(Y(i,:)');
        if f<F(i)
            F(i) = f;
            X(i,:) = Y(i,:);
            if f<fb
                fb = F(i);
                xb = X(i,:);
            end
        end
        nfe = nfe+1;
        con(nfe) = fb;
    end
end