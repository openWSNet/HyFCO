% generation_index ���X�n�p��fitness���@�N
% sense_node �|�ܤ�
function [f,coveraged_target_count,active_node_num]=fitness(generation_index)
   global pop_size sense_node sensor_selected target_coveraged target_covered_for_each_node remaining_node_array
    
for pop=1:pop_size
    for k=1:sense_node
        if(sensor_selected(pop,k,generation_index)==1)
              target_coveraged(pop,:,generation_index)=or(target_coveraged(pop,:,generation_index),target_covered_for_each_node(remaining_node_array(k),:));
        end
    end
end

for pop=1:pop_size
    coveraged_target_count(pop)=0;
    find_one=find(target_coveraged(pop,:,generation_index)==1);
    coveraged_target_count(pop)=length(find_one);
end


for pop=1:pop_size
    active_node_num(pop)=0;
    for i=1:sense_node
        if(sensor_selected(pop,i,generation_index)==1)
            active_node_num(pop)=active_node_num(pop)+1;
        end
    end
end

%disp(((coveraged_target_count./(length(target_x(1,:))*length(target_y(:,1)))).^2)*1);
%disp(((active_node_num./sense_node).^0.5)*1);
%f=((coveraged_target_count./(length(target_x(1,:))*length(target_y(:,1)))).^6)*100-((active_node_num./sense_node).^0.5)*1;
f=((coveraged_target_count./size(target_covered_for_each_node,2)).^2)*1000-((active_node_num./sense_node).^0.5)*1;


