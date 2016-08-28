%先讀sim_data.mat
%Dynamic Programming 使用遞迴的概念
clear
clc
load sim_data
node_active_result_chose=node_active_result{1,1};

current_node_x=[];
current_node_y=[];
current_node_e=[];
current_round=[];
node_e=[];
total_remaining_node_set=[];
total_remaining_node_E_set=[];
E0=0.25;
% 找出DSC剩下的節點------------------------------------------------------------
temp=[];
remaining_node_from_allDSC=[];
remaining_node_x_from_allDSC=[];
remaining_node_y_from_allDSC=[];
remaining_node_e_from_allDSC=[];
total_remaining_node_set=[];
node_e(1:400)=E0;  % node=400 能量初始化
for k=1:length(node_active_result_chose)
    temp=union(temp,node_active_result_chose{k});
end
remaining_node_from_allDSC=setxor([1:400],temp);   %從disjoint set covers剩下的節點 [1:400] 編號1~400的節點
% disp('remaining_node_from_allDSC');%test***
% fprintf(' %d ', remaining_node_from_allDSC); %test***
% disp('');%test***
for t=1:length(remaining_node_from_allDSC)
    remaining_node_x_from_allDSC=[remaining_node_x_from_allDSC node_x(remaining_node_from_allDSC(t))];
    remaining_node_y_from_allDSC=[remaining_node_y_from_allDSC node_y(remaining_node_from_allDSC(t))];
    remaining_node_e_from_allDSC=[remaining_node_e_from_allDSC node_e(remaining_node_from_allDSC(t))];
end
%------------------------------------------------------------
% for i=1:size(node_active_result_chose,2)
%     node_active_result_chose_tmp{i}=node_active_result_chose{size(node_active_result_chose,2)-i+1};
% end
% node_active_result_chose=node_active_result_chose_tmp;


round_rec_count=0;
for i=1:size(node_active_result_chose,2) % dsc主要運作迴圈
    current_node_set=node_active_result_chose{i}; %
%     fprintf('\n');%test***
%     disp('current_node_set');%test***
%     fprintf(' %d ',current_node_set); %test***
%     disp('');%test***
    round_rec_count=round_rec_count+1;
    current_node_x=[];
    current_node_y=[];
    current_node_e=[];
    for j=1:size(current_node_set,2)   %要啟動的dsc的node
        current_node_x=[current_node_x node_x(current_node_set(j))];
        current_node_y=[current_node_y node_y(current_node_set(j))];
        current_node_e=[current_node_e node_e(current_node_set(j))];
    end

    [current_round(round_rec_count),coverage_rec{round_rec_count},remaining_node_from_oneDSC{i},remaining_node_E_from_oneDSC{i},last_round]=LEACH(9000,0.2,... % 此版本的 leach 跑到coverage rate <100 %  stop
    current_node_set, size(current_node_set,2),current_node_x,current_node_y, current_node_e, sink_x,sink_y, packet_bit, grid_num, target_covered_for_each_node,1);
    fprintf('%d DSC: rounds=%d\n', i, current_round(round_rec_count));  
% ------更新node能量
    get_remaining_node_from_oneDSC=remaining_node_from_oneDSC{i};
    get_remaining_node_E_from_oneDSC=remaining_node_E_from_oneDSC{i};
   
    dead_node_from_oneDSC=setxor(current_node_set,get_remaining_node_from_oneDSC); %找到死去的node 也要更新能量
%     disp('dead_node_from_oneDSC');%test***
%     fprintf(' %d ',dead_node_from_oneDSC); %test***
%     fprintf('\n');%test***
    for remaing_node=1:length(get_remaining_node_from_oneDSC)
        node_e(get_remaining_node_from_oneDSC(remaing_node))=get_remaining_node_E_from_oneDSC(remaing_node);
    end
    for dead_node=1:length(dead_node_from_oneDSC)
        node_e(dead_node_from_oneDSC(dead_node))=0;
    end
% -------
    if i==1  %第一組dsc 只有"原本扣除所有dsc的node後"所剩下的node 當候選節點
        total_remaining_node_set=remaining_node_from_allDSC;
    end
% wake up--------------------------------------------------------------
    [lost_coverage_vector]=lost_coverage(target_covered_for_each_node,remaining_node_from_oneDSC{i});
    recover_num=-1;
    while 1
        best_cand={}; %best_cand 記錄每種啟動的最佳組合
        recover_coverage_vector_best_solution={};
        new_current_node_set=[];
        new_current_node_x=[];
        new_current_node_y=[];
        new_current_node_e=[];     
        cand_node=1;
        [best_cand{cand_node},recover_target_num,recover_coverage_vector_best_solution{cand_node}]=search_best_cand_by_dp(target_covered_for_each_node, lost_coverage_vector, total_remaining_node_set,[],[],node_e); % one node
        if recover_target_num==sum(lost_coverage_vector) && cand_node==1 %找到最佳解 結束1
            new_current_node_set=[best_cand{cand_node}];
            for get_position=1:length(new_current_node_set)
                new_current_node_x=[new_current_node_x node_x(new_current_node_set(get_position))];
                new_current_node_y=[new_current_node_y node_y(new_current_node_set(get_position))];
                new_current_node_e=[new_current_node_e node_e(new_current_node_set(get_position))];
                fprintf('find one-level best solution:');fprintf('%d ',best_cand{cand_node});fprintf('\n');
            end            
        elseif isempty(best_cand{1})==0 && recover_target_num<sum(lost_coverage_vector) %假使一顆的有找到 但未完全recover
            for cand_node=2:length(total_remaining_node_set) % 找two nodes, three nodes, .....持續找下去 (DP流程控制)
                [best_cand{cand_node},recover_target_num,recover_coverage_vector_best_solution{cand_node}]=search_best_cand_by_dp(target_covered_for_each_node,lost_coverage_vector,total_remaining_node_set...
                    ,best_cand{cand_node-1},recover_coverage_vector_best_solution{cand_node-1},node_e); % dynamic programming
                if recover_target_num==sum(lost_coverage_vector)
                    new_current_node_set=[best_cand{cand_node}]; %找到最佳解 結束2
                    for get_position=1:length(new_current_node_set)
                        new_current_node_x=[new_current_node_x node_x(new_current_node_set(get_position))];
                        new_current_node_y=[new_current_node_y node_y(new_current_node_set(get_position))];
                        new_current_node_e=[new_current_node_e node_e(new_current_node_set(get_position))];
                    end
                    fprintf('find %d-level best solution:',cand_node);fprintf('%d ',new_current_node_set);fprintf('\n');
                    break; %跳出for搜尋
                end
            end
        end   
        if (recover_target_num~=sum(lost_coverage_vector) && cand_node==length(total_remaining_node_set)) || isempty(best_cand{1})==1 % 假使無法有效恢復coverage 就跳出while -> 用來處理當 還是持續有NODE死掉 造成COVERAGE降低的情況
            other_node_set=[];
            if i>1
                for set_num=1:i-1
                    temp_set=node_active_result_chose{set_num};
                    for node_num=1:length(temp_set)
                        if node_e(temp_set(node_num))>0 other_node_set=[other_node_set temp_set(node_num)];end
                    end
                end
            end    
            total_remaining_node_set=[remaining_node_from_allDSC other_node_set get_remaining_node_from_oneDSC]; % 若 i==1 other_node_set=[]
            disp('none any recover solution, leave extend mode');
            break;  %跳出while 換下一個disjoint set
        end 
        round_rec_count=round_rec_count+1;
        new_current_node_set=[new_current_node_set get_remaining_node_from_oneDSC];  % 最佳解的node + 原本的dsc中的remaining node
        for remaing_node=1:length(get_remaining_node_from_oneDSC)
            new_current_node_x=[new_current_node_x node_x(get_remaining_node_from_oneDSC(remaing_node))];
            new_current_node_y=[new_current_node_y node_y(get_remaining_node_from_oneDSC(remaing_node))];
            new_current_node_e=[new_current_node_e node_e(get_remaining_node_from_oneDSC(remaing_node))];
        end
        disp('new_current_node_set');%test***
        fprintf(' %d ',new_current_node_set); %test***
        disp('');%test***
%         target_covered=zeros(1,64); %檢查coverage
%         for p=1:length(new_current_node_set)
%         target_covered=or(target_covered, target_covered_for_each_node(new_current_node_set(p),:));
%         end
%         sum(target_covered)

        [current_round(round_rec_count), coverage_rec{round_rec_count}, remaining_node_from_oneDSC{i}, remaining_node_E_from_oneDSC{i}, last_round]=LEACH(9000,0.2,... %再次啟動leach
        new_current_node_set, size(new_current_node_set,2), new_current_node_x, new_current_node_y, new_current_node_e, sink_x, sink_y, packet_bit, grid_num, target_covered_for_each_node,1);   
        fprintf('%d DSC: extended rounds=%d\n', i, current_round(round_rec_count));
        % ------更新node能量
        get_remaining_node_from_oneDSC=remaining_node_from_oneDSC{i};
        get_remaining_node_E_from_oneDSC=remaining_node_E_from_oneDSC{i};
        for node_num=1:length(get_remaining_node_from_oneDSC)
            node_e(get_remaining_node_from_oneDSC(node_num))=get_remaining_node_E_from_oneDSC(node_num);
        end
        dead_node_from_oneDSC=setxor(new_current_node_set,get_remaining_node_from_oneDSC);
%         fprintf('\n');%test***
%         disp('dead_node_from_oneDSC_part2');%test***
%         fprintf(' %d ',dead_node_from_oneDSC); %test***
%         fprintf('\n');%test*** 
        for node_num=1:length(dead_node_from_oneDSC)
            node_e(dead_node_from_oneDSC(node_num))=0;
        end
        %--------更新lost coverage
        [lost_coverage_vector]=lost_coverage(target_covered_for_each_node,get_remaining_node_from_oneDSC);
        % -------更新set
        remaining_node_from_allDSC2=[]; %　扣除所有ｄｓｃ節點之後剩餘的ｎｏｄｅｓ(在一個dsc執行之後有節點死掉，接著喚醒其他節點)
        for node_num=1:length(remaining_node_from_allDSC)
            if node_e(remaining_node_from_allDSC(node_num))>0 remaining_node_from_allDSC2=[remaining_node_from_allDSC2 remaining_node_from_allDSC(node_num)];end
        end
        remaining_node_from_allDSC=remaining_node_from_allDSC2; %更新remaining_node_from_allDSC = remaining_node_from_allDSC2
        other_node_set=[];
        if i>1
            for set_num=1:i-1
                temp_set=node_active_result_chose{set_num};
                for node_num=1:length(temp_set)
                    if node_e(temp_set(node_num))>0 other_node_set=[other_node_set temp_set(node_num)];end % other_node_set先前已經啟動過的dsc中的節點
                end
            end
        end   
        total_remaining_node_set=[remaining_node_from_allDSC other_node_set]; % 更新之後，while又可以依照此matrix繼續跑 
%         fprintf('\n');%test***
%         disp(' total_remaining_node_set');%test***
%         fprintf(' %d ', total_remaining_node_set); %test***
%         fprintf('\n');%test*** 
    end
    % wake up end..........................................................
   
end
% --------計算最後的 coverage
target_covered=zeros(1,grid_num);
for p=1:length(node_e)
    if node_e(p)>0
        target_covered=or(target_covered, target_covered_for_each_node(p,:));
    end
end
fprintf('*final coverage:%d\n',sum(target_covered));

% Stage 2--------把剩下的node繼續執行leach
fprintf('----------------------------------\n');
fprintf('* Stage2: LEACH keeps going on....\n');
new_node_set=[];
new_node_e_set=[];
new_node_x_set=[];
new_node_y_set=[];
for node_count=1:length(node_e)
    if node_e(node_count)>0
        new_node_set=[new_node_set node_count];
        new_node_e_set=[new_node_e_set node_e(node_count)];
        new_node_x_set=[new_node_x_set node_x(node_count)];
        new_node_y_set=[new_node_y_set node_y(node_count)];
    end
end
% --------啟動leach
% round_rec_count=round_rec_count+1;

while 1
    pre_best_cand_node=[];
    pre_recover_coverage_vector=[];
    for cand_node=1:length(new_node_set)
        %--------更新lost coverage , stage 2只在乎找出覆蓋率最高的組合，不要求100% 覆蓋率，lost
        %coverage 設定為全部的target，要找出和所有target交集最多node組合
        lost_coverage_vector=ones(1,grid_num);   
        [best_cand{cand_node},current_recover_target_num,recover_coverage_vector_best_solution{cand_node}]=search_best_cand_by_dp(target_covered_for_each_node, lost_coverage_vector,...
            new_node_set,pre_best_cand_node, pre_recover_coverage_vector,node_e);
        temp=best_cand{cand_node};
        if length(temp)>=2
            if temp(length(temp)-1)==temp(length(temp)) 
                best_cand{cand_node}=pre_best_cand_node;
                recover_coverage_vector_best_solution{cand_node}=pre_recover_coverage_vector;
                break;
            end
        end        
        pre_best_cand_node=best_cand{cand_node};
        pre_recover_coverage_vector=recover_coverage_vector_best_solution{cand_node};   
    end
    if current_recover_target_num>0 && isempty([best_cand{cand_node}])==0 %假使有找到解
        fprintf('coverage:%d , activating %d nodes:',current_recover_target_num, length(best_cand{cand_node}));fprintf('%d ',best_cand{cand_node});
        new_node_set=[best_cand{cand_node}];
        new_node_e_set=[];
        new_node_x_set=[];
        new_node_y_set=[];
        for node_count=1:length(new_node_set)
            new_node_e_set=[new_node_e_set node_e(new_node_set(node_count))];
            new_node_x_set=[new_node_x_set node_x(new_node_set(node_count))];
            new_node_y_set=[new_node_y_set node_y(new_node_set(node_count))];            
        end
        round_rec_count=round_rec_count+1;
        [current_round(round_rec_count), coverage_rec{round_rec_count}, remaining_node_from_oneDSC{i+1}, remaining_node_E_from_oneDSC{i+1}, last_round]=LEACH(9000,0.2,... %再次啟動leach
         new_node_set, size(new_node_set,2), new_node_x_set, new_node_y_set, new_node_e_set, sink_x, sink_y, packet_bit, grid_num, target_covered_for_each_node,1); 
        fprintf('- %d rounds', current_round(round_rec_count));fprintf('\n');
        % ------更新node能量
        get_remaining_node_from_oneDSC=remaining_node_from_oneDSC{i+1};
        get_remaining_node_E_from_oneDSC=remaining_node_E_from_oneDSC{i+1};
        for node_num=1:length(get_remaining_node_from_oneDSC)
            node_e(get_remaining_node_from_oneDSC(node_num))=get_remaining_node_E_from_oneDSC(node_num);
        end
        dead_node_from_oneDSC=setxor(new_node_set,get_remaining_node_from_oneDSC);
        for node_num=1:length(dead_node_from_oneDSC)
            node_e(dead_node_from_oneDSC(node_num))=0;
        end    
        % -------更新
        new_node_set=[];
        new_node_e_set=[];
        new_node_x_set=[];
        new_node_y_set=[];
        for node_count=1:length(node_e)
            if node_e(node_count)>0
                new_node_set=[new_node_set node_count];
                new_node_e_set=[new_node_e_set node_e(node_count)];
                new_node_x_set=[new_node_x_set node_x(node_count)];
                new_node_y_set=[new_node_y_set node_y(node_count)];
            end
        end     
    else  %假使找不到最佳解
        break;
    end

end


%  current_round(i)  :   每個set cover 可run的round數(sensing coverage<100% )
%  sum(current_round)