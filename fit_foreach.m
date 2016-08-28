function [covered_number,covered_map]=fit_foreach(gene) %只評估每個基因的覆蓋率
  global sense_node target_covered_for_each_node remaining_node_array

  target_covered=zeros(1,size(target_covered_for_each_node,2));

  for k=1:sense_node
     if(gene(k)==1)
         target_covered(1,:)=or(target_covered(1,:),target_covered_for_each_node(remaining_node_array(k),:));
     end
  end

  covered_target_count=sum(target_covered);
    
  covered_number=covered_target_count;
  covered_map=target_covered;