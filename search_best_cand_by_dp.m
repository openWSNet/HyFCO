function [best_solution,value,recover_coverage_vector_best_solution]=search_best_cand_by_dp(target_covered_for_each_node,lost_coverage_vector,...
    total_remaining_node_set, pre_best_cand_node, pre_recover_coverage_vector, node_e)

    the_same_node=[];
    if isempty(pre_best_cand_node) % 若前一個cand_node找出來的best是空的(也就是cand_node一顆的時候，其他數量是不可能發生的，因為既然一顆都找不到了，遑論cand_node>=2 之後要找到) 從頭找
        if isempty(total_remaining_node_set)==0 % 且候選節點不是空的 (代表cand_node=1 level : 1的挑選狀況)
            covered_num=[];
            for i=1:length(total_remaining_node_set)
                covered_num(i)=sum(and(target_covered_for_each_node(total_remaining_node_set(i),:),lost_coverage_vector));    
            end
            [value,bst_e]=max(covered_num);  
            the_same_node=find(covered_num==value);
            if isempty(the_same_node)==0 %有找到一樣覆蓋的節點的話 要選出最多能量的節點 bst_e: index of the node with largest energy
                for node_num=1:length(the_same_node)
                    if node_e(total_remaining_node_set(the_same_node(node_num)))>node_e(total_remaining_node_set(bst_e))
                        bst_e=the_same_node(node_num);
                    end
                end
            end
            if value==0 
                best_solution=[];
                recover_coverage_vector_best_solution=[];
            else
                best_solution=total_remaining_node_set(bst_e);
                recover_coverage_vector_best_solution=and(target_covered_for_each_node(total_remaining_node_set(bst_e),:),lost_coverage_vector);
            end            
        else %候選節點是空的
            best_solution=[pre_best_cand_node];
            value=sum(pre_recover_coverage_vector);  % check here!!!!!!!!!!!!!!!!
            recover_coverage_vector_best_solution=pre_recover_coverage_vector;           
        end
    else %若前一個不是空的 以前面一個為base 再下去找 (一次加一顆)
        if isempty(total_remaining_node_set)==0 
            coverage_vecor_temp={};
            for i=1:length(total_remaining_node_set) 
                coverage_vector_temp{i}=or(and(target_covered_for_each_node(total_remaining_node_set(i),:),lost_coverage_vector),pre_recover_coverage_vector);
                covered_num(i)=sum(coverage_vector_temp{i});    
            end
             [value,bst_e]=max(covered_num);
             the_same_node=find(covered_num==value);
             if isempty(the_same_node)==0 % 有找到一樣覆蓋的節點的話
                for node_num=1:length(the_same_node)
                    if node_e(total_remaining_node_set(the_same_node(node_num)))>node_e(total_remaining_node_set(bst_e))
                        bst_e=the_same_node(node_num);
                    end
                end
             end      
             if value==sum(pre_recover_coverage_vector) %假使跟前一次找出來的最佳解一樣 則.現在這次的最佳解=上一次
                best_solution=[pre_best_cand_node];
                recover_coverage_vector_best_solution=pre_recover_coverage_vector;
             else         
                best_solution=[pre_best_cand_node total_remaining_node_set(bst_e)]; %最佳解=[前面的最佳解 當前的最佳一顆解] 
                recover_coverage_vector_best_solution=and(coverage_vector_temp{bst_e},lost_coverage_vector);
             end            
        else
             best_solution=[pre_best_cand_node];
             value=sum(pre_recover_coverage_vector);
             recover_coverage_vector_best_solution=pre_recover_coverage_vector;          
        end
    end
end