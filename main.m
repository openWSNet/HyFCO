
clear;
clf;
clc;
close all;

global generation_size pop_size sense_node sense_range sensor_selected  node_x node_y   target_coveraged remaining_node_array target_covered_for_each_node active_node_array



packet_bit=2000;
generation_size=20;
pop_size=50;

sink_x=250;
sink_y=250; %sink_y=200

%grid_range
       

sense_node_case=[60 80 100 120 140 160];
grid_num_cand=[10 20 30 40 50];
sense_range_cand=[100 140 180 220 260 300];

for glo_node_case=1:1 % 可以改length(grid_num_grid) length(sense_node_case) length(sense_range_cand)
   for glo_grid_case=1:length(grid_num_cand)  
       for glo_sense_case=1:length(sense_range_cand)
                              for test_time=1:3            % numer of trial
                                 node_x=[];
                                 node_y=[];
                                 remaining_node_array=[];
                                  load ([num2str(glo_node_case) '_' num2str(glo_grid_case) '_' num2str(glo_sense_case) '_'  num2str(test_time) '.mat']); 
                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% read different cases
                                 sense_node=sense_node_case(glo_node_case); 
                                 grid_num=grid_num_cand(glo_grid_case);
                                 sense_range=sense_range_cand(glo_sense_case);
                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                                 target_covered_for_each_node=covermap;
                                 init_coveraged_target_count(test_time,glo_node_case,glo_grid_case,glo_sense_case)=cal_init_discrete_cov(target_covered_for_each_node);
                                 fprintf('\ninitial coverage=%d\n',init_coveraged_target_count(test_time,glo_node_case,glo_grid_case,glo_sense_case));
                                 glo_time=0;
                                 glo_result={};
                                 glo_coverage=[]; 
                                 tic;
                            %      while(sense_node~=0)
                            %     while(1) 
                                   while(1) %    while(sense_node~=0) run out all nodes
                                            glo_time=glo_time+1;
                                             fprintf('%d-%d-%d-%d-%d\n',test_time, glo_node_case,glo_grid_case,glo_sense_case,glo_time);
                                            sensor_selected=zeros(pop_size,sense_node,generation_size+1);
                                            target_coveraged=zeros(pop_size,size(target_covered_for_each_node,2),generation_size+1); % (node #, covered target array, generation no)
                                            [avg_fit,bst_fit,act_node,final_coverage,final_generation,best_fit,best_idx]=algorithm();
                                            if bst_fit==0
                                                break;
                                            end
                                            glo_coverage(glo_time)=final_coverage/size(target_covered_for_each_node,2);
                                            glo_remaining_node{glo_time}=remaining_node_array;
                                            glo_result{glo_time}=active_node_array;
                                            [covered_number_all,covered_map_all]=fit_foreach(ones(1,sense_node));
                                            covered_number_all
                                            if covered_number_all~=grid_num
                                                break;
                                            end        
                                    end
                                     time_period=toc;
                                     time_consuming(test_time,glo_node_case,glo_grid_case,glo_sense_case)=time_period;
                                     num_coverage_100per(test_time,glo_node_case,glo_grid_case,glo_sense_case)=length(find(glo_coverage==1));
                                     coverage_all{test_time,glo_node_case,glo_grid_case,glo_sense_case}=glo_coverage;
                                     node_active_result{test_time,glo_node_case,glo_grid_case,glo_sense_case}=glo_result;
%                                      filename=[num2str(glo_node_case) '_' num2str(glo_grid_case) '_' num2str(glo_sense_case) 'dscp1.mat'];
                             
                              % second phase
                              % LEACH-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                node_active_result_chose=glo_result;

                                current_node_x=[];
                                current_node_y=[];
                                current_node_e=[];
                                current_round=[];
                                node_e=[];
                                total_remaining_node_set=[];
                                total_remaining_node_E_set=[];
                                E0=0.25;
                                % find out the remaining nodes out of DSCs------------------------------------------------------------
                                temp=[];
                                remaining_node_from_allDSC=[];
                                remaining_node_x_from_allDSC=[];
                                remaining_node_y_from_allDSC=[];
                                remaining_node_e_from_allDSC=[];
                                total_remaining_node_set=[];
                                node_e(1:sense_node_case(glo_node_case))=E0;  % power of node
                                for k=1:length(node_active_result_chose)
                                    temp=union(temp,node_active_result_chose{k});
                                end
                                remaining_node_from_allDSC=setxor([1:sense_node_case(glo_node_case)],temp);
                                % disp('remaining_node_from_allDSC');%test***
                                % fprintf(' %d ', remaining_node_from_allDSC); %test***
                                % disp('');%test***
                                for t=1:length(remaining_node_from_allDSC)
                                    remaining_node_x_from_allDSC=[remaining_node_x_from_allDSC node_x(remaining_node_from_allDSC(t))];
                                    remaining_node_y_from_allDSC=[remaining_node_y_from_allDSC node_y(remaining_node_from_allDSC(t))];
                                    remaining_node_e_from_allDSC=[remaining_node_e_from_allDSC node_e(remaining_node_from_allDSC(t))];
                                end

                                round_rec_count=0;
                                for i=1:size(node_active_result_chose,2) % running main loop of DSCs
                                    current_node_set=node_active_result_chose{i}; %
                                %     fprintf('\n');%test***
                                %     disp('current_node_set');%test***
                                %     fprintf(' %d ',current_node_set); %test***
                                %     disp('');%test***
                                    round_rec_count=round_rec_count+1;
                                    current_node_x=[];
                                    current_node_y=[];
                                    current_node_e=[];
                                    for j=1:size(current_node_set,2)   %nodes in DSC to be activated 
                                        current_node_x=[current_node_x node_x(current_node_set(j))];
                                        current_node_y=[current_node_y node_y(current_node_set(j))];
                                        current_node_e=[current_node_e node_e(current_node_set(j))];
                                    end

                                    [current_round(round_rec_count),coverage_rec{round_rec_count},remaining_node_from_oneDSC{i},remaining_node_E_from_oneDSC{i},last_round]=LEACH(9000,0.2,... % 此版本的 leach 跑到coverage rate <100 %  stop
                                    current_node_set, size(current_node_set,2),current_node_x,current_node_y, current_node_e, sink_x,sink_y, packet_bit, grid_num, target_covered_for_each_node,1);
                                    fprintf('\n%d DSC: rounds=%d\n', i, current_round(round_rec_count));  
                                % ------更新node能量
                                    get_remaining_node_from_oneDSC=remaining_node_from_oneDSC{i};
                                    get_remaining_node_E_from_oneDSC=remaining_node_E_from_oneDSC{i};

                                    dead_node_from_oneDSC=setxor(current_node_set,get_remaining_node_from_oneDSC); % update the power
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
                                    if i==1 
                                        total_remaining_node_set=remaining_node_from_allDSC;
                                    end
                                % wake up--------------------------------------------------------------
                                    [lost_coverage_vector]=lost_coverage(target_covered_for_each_node,remaining_node_from_oneDSC{i});
                                    recover_num=-1;
                                    while 1
                                        best_cand={}; % best_cand is used to record the bets conbination
                                        recover_coverage_vector_best_solution={};
                                        new_current_node_set=[];
                                        new_current_node_x=[];
                                        new_current_node_y=[];
                                        new_current_node_e=[];     
                                        cand_node=1;
                                        [best_cand{cand_node},recover_target_num,recover_coverage_vector_best_solution{cand_node}]=search_best_cand_by_dp(target_covered_for_each_node, lost_coverage_vector, total_remaining_node_set,[],[],node_e); % one node
                                        if recover_target_num==sum(lost_coverage_vector) && cand_node==1 % got the solution and finish
                                            new_current_node_set=[best_cand{cand_node}];
                                            for get_position=1:length(new_current_node_set)
                                                new_current_node_x=[new_current_node_x node_x(new_current_node_set(get_position))];
                                                new_current_node_y=[new_current_node_y node_y(new_current_node_set(get_position))];
                                                new_current_node_e=[new_current_node_e node_e(new_current_node_set(get_position))];
                                                fprintf('find one-level best solution:');fprintf('%d ',best_cand{cand_node});fprintf('\n');
                                            end            
                                        elseif isempty(best_cand{1})==0 && recover_target_num<sum(lost_coverage_vector) &&  length(total_remaining_node_set)>=2 % not recover completely
                                            for cand_node=2:length(total_remaining_node_set) % 找two nodes, three nodes, .....keep looking 
                                                [best_cand{cand_node},recover_target_num,recover_coverage_vector_best_solution{cand_node}]=search_best_cand_by_dp(target_covered_for_each_node,lost_coverage_vector,total_remaining_node_set...
                                                    ,best_cand{cand_node-1},recover_coverage_vector_best_solution{cand_node-1},node_e); % dynamic programming
                                                if recover_target_num==sum(lost_coverage_vector)
                                                    new_current_node_set=[best_cand{cand_node}]; % got the solution and finish
                                                    for get_position=1:length(new_current_node_set)
                                                        new_current_node_x=[new_current_node_x node_x(new_current_node_set(get_position))];
                                                        new_current_node_y=[new_current_node_y node_y(new_current_node_set(get_position))];
                                                        new_current_node_e=[new_current_node_e node_e(new_current_node_set(get_position))];
                                                    end
                                                    fprintf('find %d-level best solution:',cand_node);fprintf('%d ',new_current_node_set);fprintf('\n');
                                                    break; %jump out the for loop
                                                end
                                            end
                                        end   
                                        if (recover_target_num~=sum(lost_coverage_vector) && cand_node==length(total_remaining_node_set)) || isempty(best_cand{1})==1 % if coverage cannot be recovered, jump out the while
                                            other_node_set=[];
                                            if i>1
                                                for set_num=1:i-1
                                                    temp_set=node_active_result_chose{set_num};
                                                    for node_num=1:length(temp_set)
                                                        if node_e(temp_set(node_num))>0 other_node_set=[other_node_set temp_set(node_num)];end
                                                    end
                                                end
                                            end    
                                            if size(remaining_node_from_allDSC,2)==1
                                                remaining_node_from_allDSC=remaining_node_from_allDSC';
                                            end
                                            total_remaining_node_set=[remaining_node_from_allDSC other_node_set get_remaining_node_from_oneDSC]; % 若 i==1 other_node_set=[]
                                            disp('none any recover solution, leave extend mode');
                                            break;  % change to next DSC
                                        end 
                                        round_rec_count=round_rec_count+1;
                                        new_current_node_set=[new_current_node_set get_remaining_node_from_oneDSC];  
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
                                        % ------update power
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
                                        %--------update the lost coverage
                                        [lost_coverage_vector]=lost_coverage(target_covered_for_each_node,get_remaining_node_from_oneDSC);
                                        % -------update set
                                        remaining_node_from_allDSC2=[]; 
                                        for node_num=1:length(remaining_node_from_allDSC)
                                            if node_e(remaining_node_from_allDSC(node_num))>0 remaining_node_from_allDSC2=[remaining_node_from_allDSC2 remaining_node_from_allDSC(node_num)];end
                                        end
                                        remaining_node_from_allDSC=remaining_node_from_allDSC2;
                                        other_node_set=[];
                                        if i>1
                                            for set_num=1:i-1
                                                temp_set=node_active_result_chose{set_num};
                                                for node_num=1:length(temp_set)
                                                    if node_e(temp_set(node_num))>0 other_node_set=[other_node_set temp_set(node_num)];end
                                                end
                                            end
                                        end   
                                        total_remaining_node_set=[remaining_node_from_allDSC other_node_set]; 
                                %         fprintf('\n');%test***
                                %         disp(' total_remaining_node_set');%test***
                                %         fprintf(' %d ', total_remaining_node_set); %test***
                                %         fprintf('\n');%test*** 
                                    end
                                    % wake up end..........................................................

                                end
                                % --------evaluate the final coverage
                                target_covered=zeros(1,grid_num);
                                for p=1:length(node_e)
                                    if node_e(p)>0
                                        target_covered=or(target_covered, target_covered_for_each_node(p,:));
                                    end
                                end
                                fprintf('*final coverage:%d\n',sum(target_covered));

                                % Stage 2--------run LEACH with the remaining nodes
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
                                % -------run
                                % round_rec_count=round_rec_count+1;

                                while 1
                                    pre_best_cand_node=[];
                                    pre_recover_coverage_vector=[];
                                    for cand_node=1:length(new_node_set)
                                        %--------update lost coverage , in stage 2 try look for as larger coverage as possible (full coverage is not forced)
                                      
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
                                    if current_recover_target_num>0 && isempty([best_cand{cand_node}])==0 
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
                                        % -------update
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
                                    else  % if the best solution is not found
                                        break;
                                    end

                                end                   
                                round{test_time,glo_node_case,glo_grid_case,glo_sense_case}=current_round; 
                                coverage_round{test_time,glo_node_case,glo_grid_case,glo_sense_case}=coverage_rec;
                                save('result.mat', 'time_consuming','num_coverage_100per','coverage_all','node_active_result','init_coveraged_target_count', 'round', 'coverage_round');
                              end
       end
   end
end
% save sim_data.mat init_coveraged_target_count time_consuming num_coverage_100per coverage_all node_active_result field_num 
% save sim_data.mat target_covered_for_each_node init_coveraged_target_count time_consuming num_coverage_100per coverage_all node_active_result node_x node_y grid_range_x grid_range_y span sink_x sink_y packet_bit sense_range grid_num


% [coverage_rec,avg_packets_to_bs,avg_packets_to_ch,dead,S,last_round,CLUSTERHS,avg_ch]=LEACH(sense_node,9000,0.2,...
% sensor_selected(best_idx,:,generation_size+1),node_x,node_y,sink_x,sink_y,packet_bit,1);
% avg_ch
% avg_packets_to_bs
% avg_packets_to_ch

% pause;
% end

