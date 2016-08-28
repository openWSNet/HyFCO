% �ܼƸ���
%  target_coveraged(i,j,pop,generation):�w��C�@�ӬV����(pop) �����@�i�V�q����x�s �ӬV������л\��target�I
%  sensor_selected(pop,sense_node,gen)%  :��l�ƫᲣ�ͤF�ƭӬV����A�C�@�ӬV���骺��]���O���P���Cpop�O�C�@�ӬV���骺�s��gen�A�O�N��
%  target_x�Btarget_y: �ΨӬ���target�C�@���I��x�My�y�СA�ӯx�}���h�j�A�N�|���h�֭��I (targrt_x�Mtarget_y size�@�ˤj)
%  coveraged_target_count(pop): �ΨӬ����ݭ��ӬV������л\��target�̦h
%  generation_size ���ͪ��@�N�� ��l�����N����J �ҥH�̫�@�Ӥl�N����ܬ�generation_size+1
% target_covered_for_each_node(i,j,sense_node) �O���C��node���л\��target���}�C
% distance �����C�Ӹ`�I�M�Ҧ�target���Z��
function [avg_fit,bst_fit,act_node,final_coverage,final_generation, best_fit,best_idx]=algorithm()

global sense_node pop_size sensor_selected remaining_node_array active_node_array generation_size target_covered_for_each_node


sensor_selected(:,:,1)=rand(pop_size,sense_node)>0.5;%�u�ݭn�H�����ͲĤ@�a����] ��L�N����

for i=1:generation_size % �g�Lgeneration_size �����^�N(�c�l) �|��generation_size+1�ӥ@�N����(�]�A��l���Ĥ@�N)
    %new_pop(1);
   [f,temp1,temp2]=fitness(i);
   [best_fit,best_idx]=max(f);
%    fprintf('\n generation=%d/%d  best_fit=%f  ave_fit=%f  coverage_ratio=%f  active_node_ratio=%f',i,...
%        generation_size+1,max(f),sum(f)/pop_size,temp1(best_idx)/(size(target_covered_for_each_node,2)),temp2(best_idx)/(sense_node));
   sensor_selected(:,:,i+1)= ga_nextpopu(f, sensor_selected(:,:,i), sense_node, 0.5, 0.07,1);
   sensor_selected(:,:,i+1)=local_search(sensor_selected(:,:,i+1));
end

  [f,temp1,temp2]=fitness(generation_size+1);
  fprintf('\n generation=%d/%d  best_fit=%f  ave_fit=%f',i+1,i+1,max(f),sum(f)/pop_size);
  [best_fit,best_idx]=max(fitness(generation_size+1)); %�̫�@�Ӥl�N����ܬ�generation_size+1
  fprintf('\n coveraged target ratio=%d/%d active_node_num=%d',temp1(best_idx),size(target_covered_for_each_node,2),temp2(best_idx));


avg_fit=sum(f)/pop_size;
bst_fit=best_fit;
act_node=temp2(best_idx);
final_coverage=temp1(best_idx);
final_generation=i+1;


remaining_node_array_temp=remaining_node_array;
remaining_node_array=[];
active_node_array=[];
for node_count=1:sense_node
    if sensor_selected(best_idx,node_count,i+1)==0
        remaining_node_array=[remaining_node_array remaining_node_array_temp(node_count)];
    else
        active_node_array=[active_node_array remaining_node_array_temp(node_count)];
    end
    
end
sense_node=sense_node-sum(sensor_selected(best_idx,:,i+1));
fprintf('\nsense_node=%d\n',sense_node);




