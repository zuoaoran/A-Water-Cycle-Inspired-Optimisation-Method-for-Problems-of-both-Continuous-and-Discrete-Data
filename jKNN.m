function Acc=jKNN(sFeat,label,HO)
k=5;
xtrain = sFeat(HO.training == 1,:);
ytrain = label(HO.training == 1); 
xvalid = sFeat(HO.test == 1,:); 
yvalid = label(HO.test == 1); 

Model = fitcknn(xtrain,ytrain,'NumNeighbors',k); 
pred = predict(Model,xvalid);

cp=classperf(yvalid,pred);

Acc=cp.CorrectRate;

% num_valid = length(yvalid); 
% correct   = 0;
% for i = 1:num_valid
%   if isequal(yvalid(i),pred(i))
%     correct = correct + 1;
%   end
% end
% Acc   = correct / num_valid; 
% % error = 1 - Acc;


end