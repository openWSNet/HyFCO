function gene_output=local_search_for_alive_neighbor(dead_node,gene_input,node,dist_node)
% dead_node ���h�`�I���s��
% gene_input ��]����J �t�w���h���`�I (=0)
% neighbor �����F�~�`�I���s��
% neighobr_gene �����n����ǾF�~ (���שMneighboe�@��) 1���󴫿�
% error_range ����F�~���Ѧҭ� �w�]1 (���Ϥ�����ӾF�~�ҳy�����л\�l���j��error_range�A�h����ӾF�~)(�����������л\���p�����)
global  sense_node sense_range target_covered_for_each_node 
trans_range=17.675; %�q�T�Z�� 27.95
neighbor=[];
for i=1:sense_node
    if i~=dead_node      
        if dist_node(i,dead_node)<trans_range && gene_input(i)==0 && node(i).E>0 && node(i).type~='D'
            neighbor(length(neighbor)+1)=i;
        end
    end
end

[temp1,no_dead_node_covered_map]=fit_foreach(gene_input);
gene_tmp=gene_input;
gene_tmp(dead_node)=1;
[temp2,include_dead_node_covered_map]=fit_foreach(gene_tmp);
remaining_no_covered_target=xor(no_dead_node_covered_map,include_dead_node_covered_map); %��Xdead_node�����ҳy���S�Q�л\��target

% optimal_gene=zeros(1,2);
lost_target_num=length(find(remaining_no_covered_target==1));
optimal_covered_num=0;
optimal_rec=[];
fprintf('\nlossing no.%d',dead_node);
fprintf('\n�F�~��=%d,�l����target��=%d',length(neighbor),lost_target_num);

if isempty(neighbor)~=1 
    candidate_node=[];
    for k=1:length(neighbor)
       tmp=and(target_covered_for_each_node(:,:,neighbor(k)),remaining_no_covered_target);
       sum_tmp=sum(sum(tmp,1));
       if  sum_tmp>=1
           candidate_node=[candidate_node neighbor(k)];
       end
    end
%     fprintf('\n���л\���I���F�~\n');
%     disp(candidate_node);
    
    if length(candidate_node)>4  %% ����!!! ��F�~�L�h���ɭ� �קK�B��ӹL�����H�Τ��ŦX����(�s�Ӧh�`�I�d��)�A�]��������
        cbn_num=4;
    else
        cbn_num=length(candidate_node);
    end
    
    for i=1:cbn_num
        disp(i);
        choice=[];     
        choice=combntns(candidate_node,i);  %% choice�x�s�Ҧ��i��Q������F�~���ƦC�զX�s��       
        for j=1:length(choice(:,1))
            count_num=evaluate_with_remaining_area(choice(j,:),remaining_no_covered_target);
%             disp('�զX');     
%             disp(choice(j,:));
%             disp('count_num=');     
%             disp(count_num);
            if count_num>optimal_covered_num
                optimal_covered_num=count_num;
                optimal_rec=choice(j,:);
            end
        end
    end
end

gene_output=gene_input;
fprintf('\n���=');
if optimal_covered_num~=0 
    for m=1:length(optimal_rec)
        gene_output(optimal_rec(m))=1; 
        fprintf('%d ',optimal_rec(m));
    end
end
end


