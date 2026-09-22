function GrassHopperPositions = checkempty(GrassHopperPositions,dim,flag)
while numel(find(GrassHopperPositions==0))==numel(GrassHopperPositions)
     if(flag==1)
    GrassHopperPositions=round(rand(1,dim-1)); 
    else 
    GrassHopperPositions=round(rand(1,dim)); 
     end
end
%当数组中0的个数==数组中所有的个数（即数组中的每个数都等于0）
%数组G=随机生成的1*dim的数组，并对数组里的每个元素取整数
%这个函数的目的是让数组中至少有一个数不为0
%rand 返回间隔（0,1）中的单个均匀分布的随机数。
%round（X）将X的每个元素四舍五入到最接近的整数。 在平局的情况下，元素的小数部分正好为0.5，舍入函数从零舍入到较大数值的整数。