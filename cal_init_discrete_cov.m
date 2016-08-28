function y=cal_init_discrete_cov(target_covered_for_each_node)
    un_target=zeros(1,size(target_covered_for_each_node,2));
    for i=1:size(target_covered_for_each_node,1)
        un_target=or(un_target,target_covered_for_each_node(i,:));
    end
    y=sum(un_target)/size(target_covered_for_each_node,2);
end