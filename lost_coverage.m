function [lost_coverage_vector]=lost_coverage(target_covered_for_each_node,remaining_node_set)
    target_covered=zeros(1,size(target_covered_for_each_node,2));
    target_all_covered=ones(1,size(target_covered_for_each_node,2)); 
    for i=1:length(remaining_node_set)
        target_covered=or(target_covered, target_covered_for_each_node(remaining_node_set(i),:));
    end
    lost_coverage_vector=xor(target_covered,target_all_covered); %和100% coverage比較看失去哪些target
end