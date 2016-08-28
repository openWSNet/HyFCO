% 變數解釋
%  target_coveraged(i,j,pop,generation):針對每一個染色體(pop) 都有一張向量表來儲存 該染色體所覆蓋的target點
%  sensor_selected(pop,sense_node,gen)%  :初始化後產生了數個染色體，每一個染色體的基因都是不同的。pop是每一個染色體的編號gen，是代數
%  target_x、target_y: 用來紀錄target每一個點的x和y座標，該矩陣有多大，就會有多少個點 (targrt_x和target_y size一樣大)
%  coveraged_target_count(pop): 用來紀錄看哪個染色體所覆蓋的target最多
%  generation_size 產生的世代數 初始的母代不算入 所以最後一個子代的表示為generation_size+1
% target_covered_for_each_node(i,j,sense_node) 記錄每個node所覆蓋的target的陣列
% distance 紀錄每個節點和所有target的距離
function [avg_fit,bst_fit,act_node,final_coverage,final_generation, best_fit,best_idx]=algorithm()

global sense_node pop_size sensor_selected remaining_node_array active_node_array generation_size target_covered_for_each_node


sensor_selected(:,:,1)=rand(pop_size,sense_node)>0.5;%只需要隨機產生第一帶的基因 其他代不用

for i=1:generation_size % 經過generation_size 次的跌代(繁衍) 會有generation_size+1個世代產生(包括初始的第一代)
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
  [best_fit,best_idx]=max(fitness(generation_size+1)); %最後一個子代的表示為generation_size+1
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




