function [best_solution,value,recover_coverage_vector_best_solution]=search_best_cand_by_dp(target_covered_for_each_node,lost_coverage_vector,...
    total_remaining_node_set, pre_best_cand_node, pre_recover_coverage_vector, node_e)

    the_same_node=[];
    if isempty(pre_best_cand_node) % �Y�e�@��cand_node��X�Ӫ�best�O�Ū�(�]�N�Ocand_node�@�����ɭԡA��L�ƶq�O���i��o�ͪ��A�]���J�M�@�����䤣��F�A�N��cand_node>=2 ����n���) �q�Y��
        if isempty(total_remaining_node_set)==0 % �B�Կ�`�I���O�Ū� (�N��cand_node=1 level : 1���D�窱�p)
            covered_num=[];
            for i=1:length(total_remaining_node_set)
                covered_num(i)=sum(and(target_covered_for_each_node(total_remaining_node_set(i),:),lost_coverage_vector));    
            end
            [value,bst_e]=max(covered_num);  
            the_same_node=find(covered_num==value);
            if isempty(the_same_node)==0 %�����@���л\���`�I���� �n��X�̦h��q���`�I bst_e: index of the node with largest energy
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
        else %�Կ�`�I�O�Ū�
            best_solution=[pre_best_cand_node];
            value=sum(pre_recover_coverage_vector);  % check here!!!!!!!!!!!!!!!!
            recover_coverage_vector_best_solution=pre_recover_coverage_vector;           
        end
    else %�Y�e�@�Ӥ��O�Ū� �H�e���@�Ӭ�base �A�U�h�� (�@���[�@��)
        if isempty(total_remaining_node_set)==0 
            coverage_vecor_temp={};
            for i=1:length(total_remaining_node_set) 
                coverage_vector_temp{i}=or(and(target_covered_for_each_node(total_remaining_node_set(i),:),lost_coverage_vector),pre_recover_coverage_vector);
                covered_num(i)=sum(coverage_vector_temp{i});    
            end
             [value,bst_e]=max(covered_num);
             the_same_node=find(covered_num==value);
             if isempty(the_same_node)==0 % �����@���л\���`�I����
                for node_num=1:length(the_same_node)
                    if node_e(total_remaining_node_set(the_same_node(node_num)))>node_e(total_remaining_node_set(bst_e))
                        bst_e=the_same_node(node_num);
                    end
                end
             end      
             if value==sum(pre_recover_coverage_vector) %���ϸ�e�@����X�Ӫ��̨θѤ@�� �h.�{�b�o�����̨θ�=�W�@��
                best_solution=[pre_best_cand_node];
                recover_coverage_vector_best_solution=pre_recover_coverage_vector;
             else         
                best_solution=[pre_best_cand_node total_remaining_node_set(bst_e)]; %�̨θ�=[�e�����̨θ� ��e���̨Τ@����] 
                recover_coverage_vector_best_solution=and(coverage_vector_temp{bst_e},lost_coverage_vector);
             end            
        else
             best_solution=[pre_best_cand_node];
             value=sum(pre_recover_coverage_vector);
             recover_coverage_vector_best_solution=pre_recover_coverage_vector;          
        end
    end
end