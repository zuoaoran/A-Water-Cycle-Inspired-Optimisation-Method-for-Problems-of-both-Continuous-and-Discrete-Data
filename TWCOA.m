function [Xbest_4, Scorebest_4,cg_curve_4] = TWCOA(Materials_no,Max_iter,lb, ub, dim, fobj)
C3=1;C4=2;  %standard Optimization functions
tic
%[Best_score,Best_pos,cg_curve]=WOA(nPop,Max_iter,lb,ub,dim,fobj);
[~, ~,~]=oil_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
[~, ~,~]=plant_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
[~, ~,~]=ocean_evaporation(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
[~, ~,~]=atmo_rain(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
[Scorebest_4,Xbest_4,cg_curve_4]=ground_runoff(Materials_no,Max_iter,fobj, dim,lb,ub,C3,C4);
toc
end

