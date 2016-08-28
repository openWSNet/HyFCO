  function gene_output=local_search_for_alive_neighbor(dead_node,gene_input,node,dist_node)
% dead_node_id ���h�`�I���s��
% gene_input ��]����J �t�w���h���`�I (=0)
% neighbor �����F�~�`�I���s��
% neighobr_gene �����n����ǾF�~ (���שMneighboe�@��) 1���󴫿�
% error_range ����F�~���Ѧҭ� �w�]1 (���Ϥ�����ӾF�~�ҳy�����л\�l���j��error_range�A�h����ӾF�~)(�����������л\���p�����)
global  sense_node sense_range 

neighbor=[];
for i=1:sense_node
    if i~=dead_node      
        if dist_node(i,dead_node)<sense_range*2 && gene_input(i)==0 && node(i).E>0
            neighbor(length(neighbor)+1)=i;
        end
    end
end

[temp1,no_dead_node_covered_map]=fit_foreach(gene_input);
gene_tmp=gene_input;
gene_tmp(dead_node)=1;
[temp2,include_dead_node_covered_map]=fit_foreach(gene_tmp);
remaining_no_covered_nodes=xor(no_dead_node_covered_map,include_dead_node_covered_map);

% optimal_gene=zeros(1,2);
optimal_covered_num=0;
optimal_rec=[];
for i=1:length(neighbor) 
    choice=[];     
    choice=combntns(neighbor,i);
    for j=1:length(choice(:,1))
        count_num=evaluate_with_remaining_area(choice(j,:),remaining_no_covered_nodes);
        if count_num>optimal_covered_num
            optimal_covered_num=count_num;
            optimal_rec=choice(j,:);
        end
    end
end

neighbor_gene=zeros(1,length(neighbor));

% count_of_covered_map_all_neighbor=length(find(covered_map_all_neighbor==1));

%�}�l�����C�ӾF�~
% neighbor_gene=ones(1,length(neighbor));
% for j=1:length(neighbor)
%     neighbor_gene(j)=0;
%     covered_map_del_one_neighbor=zeros(length(target_x(:,1)),length(target_x(1,:)));
%     %����������j�ӾF�~���ĪG -START
%     for k=1:length(neighbor) 
%         if neighbor_gene(k)==1
%             covered_map_del_one_neighbor=or(covered_map_del_one_neighbor,target_covered_for_each_node(:,:,neighbor(k)));
%         end
%     end
%     covered_map_del_one_neighbor=and(covered_map_del_one_neighbor,target_covered_for_each_node(:,:,dead_node)); % �A�M�w���h��node�л\�ϰ�and
%     count_of_covered_map_del_one_neighbor=length(find(covered_map_del_one_neighbor==1));
%      %����������j�ӾF�~���ĪG -END
%      if (count_of_covered_map_all_neighbor-count_of_covered_map_del_one_neighbor)>error_range
%          neighbor_gene(j)=1;
%      end   
% 
% end

%fprintf('node %d is dead. wake up :\n',dead_node);
gene_output=gene_input;
% disp(neighbor_gene);
% disp(neighbor);
for m=1:length(neighbor)
    gene_output(neighbor(m))=1; 
%       fprintf('%d,',neighbor(m));
end


end