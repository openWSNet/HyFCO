%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [current_round,coverage_rec,remaining_node_set,remaining_node_E_set,last_round] = LEACH(rmax, p, current_node_set, sense_node, node_x, node_y, node_e, sink_x, sink_y,...
                                              packet_bit,grid_num, target_covered_for_each_node,coverage_constraint) 
                                          % coverage_constraint 用來開啟覆蓋率限制
                                          
%avg_ch 是 到沒有節點alive的時候，往前推算所有rounds的head平均數
% current_node_set 紀錄目前的node set 編號有哪些，進入leach 後會從新編號從1開始
current_round=0;
%Eelec=Etx=Erx
ETX=50*0.000000001;
ERX=50*0.000000001;
%Transmit Amplifier types
Emp=0.1*0.000000001;
%Data Aggregation Energy
EDA=5*0.000000001;
flag=0;                                                         
%Data Aggregation Energy
remaining_node_set=[];
%Computation of do
S=[];
for i=1:1:sense_node
    S(i).xd=node_x(i);
    XR(i)=S(i).xd;
    S(i).yd=node_y(i);
    YR(i)=S(i).yd;
    S(i).G=0;
    S(i).sons=0;
    S(i).E=node_e(i);
    %initially there are no cluster heads only nodes
    S(i).type='N';
end

S(sense_node+1).xd=sink_x;
S(sense_node+1).yd=sink_y;

dist_node=zeros(sense_node+1,sense_node+1); % 計算node之間的距離，sense_node+1是sink
for i=1:(sense_node+1)
    for j=1:(sense_node+1)
        dist_node(i,j)=dist(S(i).xd,S(i).yd,S(j).xd,S(j).yd);
    end
end
target_covered=zeros(1,grid_num); %先評估一開始的coverage
for k=1:sense_node
    if S(k).E>0
        target_covered=or(target_covered,target_covered_for_each_node(current_node_set(k),:));
    end
end
coverage_rec=[sum(target_covered)];
countCHs=0;
%counter for CHs per round
rcountCHs=0;
cluster=1;
countCHs;
rcountCHs=rcountCHs+countCHs;
flag_first_dead=0;
last_round=0;

%%%%%%%%%%%%%%%%%%%%%%%%% END OF PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% START OF ROUNDS %%%%%%%%%%%%%%%%%%%%%%%%%%
for r=1:1:rmax
  %Operation for epoch
    if mod(r, round(1/p) )==0
       for i=1:sense_node  %更新G值，用來判斷是否該epoch已經結束
         S(i).G=0;
         S(i).cl=0;
       end
    end
    for y=1:sense_node
       S(y).sons=0; %記錄每個round中，若是head其所轄的節點有幾顆
    end
% hold off;

%Number of dead nodes
dead=0;
%Number of dead Advanced Nodes
dead_a=0;
%Number of dead Normal Nodes
dead_n=0;

%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS=0;
packets_TO_CH=0;
%counter for bit transmitted to Bases Station and to Cluster Heads 
%per round
PACKETS_TO_CH(r+1)=0;
PACKETS_TO_BS(r+1)=0;

for i=1:1:sense_node
    %checking if there is a dead node
    if (S(i).E<=0)
        dead=dead+1;
        S(i).type='D';          
    end
end

for j=1:sense_node
    if S(j).E>0
        S(j).type='N';
    end
end

%更新完死掉的節點後 執行覆蓋率評估
target_covered=zeros(1,grid_num);
for k=1:sense_node
    if S(k).E>0
        target_covered=or(target_covered,target_covered_for_each_node(current_node_set(k),:));
    end
end
remaining_node_set=[];
remaining_node_E_set=[];
for node_count=1:sense_node %計算剩下的 node有哪些
    if S(node_count).E>0 
%         fprintf('**%d**\n',node_count);
%         fprintf(' e1(leach)=%f\n',S(node_count).E); 
        remaining_node_set=[remaining_node_set current_node_set(node_count)]; 
        remaining_node_E_set=[remaining_node_E_set S(node_count).E];
    end
end
covered_target_count=sum(target_covered);
covered_number=covered_target_count;
covered_map=target_covered;
coverage_rec=[coverage_rec covered_number];
current_round=r;  %%不是R+1
flag=0;
if coverage_constraint==1   % 有開啟覆蓋率限制
%     if coverage_rec(1,r+1)<grid_num   % target有64個  假使小於64個 代表coverage <100%  則跳出       
%         break;
%     end
    for k=1:sense_node %假使有節點死掉就跳出
        if S(k).E<=0 
%             fprintf('**=%d=**\n',k);
%             fprintf(' e2(leach)=%f\n', S(k).E);                   
            flag=1;
        end
    end
    if flag==1
        break;
    end
end

STATISTICS(r+1).DEAD=dead;
DEAD(r+1)=dead;

%When the first node dies
if (dead==1)
    if(flag_first_dead==0)
        first_dead=r
        flag_first_dead=1;
    end
end

countCHs=0; 
cluster=1; %一個計數指標
alive_node=0;
for i=1:1:sense_node
   if(S(i).E>0)
   temp_rand=rand;    
   alive_node=alive_node+1;
   if ( (S(i).G)<=0) %G小於等於0才有機會被選為HEAD
       %Election of Cluster Heads    
       if(temp_rand<= (p/(1-p*mod(r,round(1/p)))))
            countCHs=countCHs+1;
            packets_TO_BS=packets_TO_BS+1;  
            S(i).type='C';
            S(i).G=round(1/p)-1;   % 有當過head的node 其G值就不會是0 因此可以用來判斷下個round是否要選取其來當head
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;
            
            distance=dist_node(i,sense_node+1);%和sink的距離
            C(cluster).distance=distance;
            C(cluster).id=i;
            X(cluster)=S(i).xd;
            Y(cluster)=S(i).yd;
            cluster=cluster+1;
        end     
    end
   end 

end

CLUSTERHS(r+1)=(cluster-1);
if (alive_node==0 && flag==0 )||(r==rmax && flag==0 ) %若達到最中round 或全部節點死亡 就記錄last_round
    last_round=r;
    flag=1;
end
packets_TO_CH=0;
%Election of Associated Cluster Head for Normal Nodes
for i=1:1:sense_node
   if ( S(i).type=='N' && S(i).E>0)
     if(cluster-1>=1) %若網路內 有一個以上的head
       min_dis=dist_node(i,sense_node+1);
       min_dis_cluster=1;
       for c=1:1:cluster-1
           temp=min(min_dis,sqrt( (S(i).xd-C(c).xd)^2 + (S(i).yd-C(c).yd)^2 ) );
           if ( temp<min_dis )
               min_dis=temp;
               min_dis_cluster=c;
           end
       end     
          S(i).E=S(i).E- ( ETX*(packet_bit) + Emp*packet_bit*( min_dis * min_dis)); 
        if(min_dis_cluster~=1)
          S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*packet_bit ); 
          S(C(min_dis_cluster).id).sons=S(C(min_dis_cluster).id).sons+1;
          packets_TO_CH=packets_TO_CH+1;
        end
        S(i).min_dis=min_dis;
        S(i).min_dis_cluster=min_dis_cluster;      
     else
        min_dis=dist_node(i,sense_node+1);
        min_dis_cluster=1;
        S(i).E=S(i).E - ( ETX*(packet_bit) + Emp*packet_bit*( min_dis * min_dis)); 
        packets_TO_BS=packets_TO_BS+1; 
     end    
 end
end
      PACKETS_TO_CH(r+1)=packets_TO_CH; 
      PACKETS_TO_BS(r+1)=packets_TO_BS;     
         % 統計head傳送到BS的封包數量  
for h=1:sense_node %% 計算head傳到bs的能量消耗
    if S(h).type=='C' && S(h).E>0
       dis=dist_node(h,sense_node+1);%和sink的距離
       S(h).E=S(h).E- ( EDA*(packet_bit) + ETX*(packet_bit) + Emp*packet_bit*( dis * dis)); 
    end
end
% hold on;

countCHs;
rcountCHs=rcountCHs+countCHs;

for i=1:sense_node %%將能量因為最後一次扣除 導致低於零的節點 回歸到0
    if S(i).E<0
        S(i).E=0;
    end
end

% if r==1 || r==500 || r==1500 || r==3000 || r==4500 || r==4900
% % if r==rmax
%     energy_analysis(100,100,S,sense_node);  
% %     print(figure(10),'-dmeta',[int2str(r)]);  
% 
%     pause;
% end

end

% energy_analysis(grid_range_x*span,grid_range_y*span,S,sense_node);
% plot_topology(1,sense_range,gene_of_each_round,node_x,node_y,target_x,target_y);

% 
% figure(2);
% if last_round~=0
%     avg_ch=sum(CLUSTERHS)/last_round;
%     avg_packets_to_bs=sum(PACKETS_TO_BS)/last_round;
%     avg_packets_to_ch=sum(PACKETS_TO_CH)/last_round;
% else
%     avg_ch=sum(CLUSTERHS)/rmax;
% end

% plot(sense_node-DEAD(2:(rmax+1)),'b');     %因為DEAD是從第二個ROUND以後才有值
% figure(3);
% target_num=length(target_x(1,:))*length(target_y(:,1));

% plot(coverage_rec(2:(rmax+1))/target_num,'r')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   STATISTICS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                     %
%  DEAD  : a rmax x 1 array of number of dead nodes/round 
%  DEAD_A : a rmax x 1 array of number of dead Advanced nodes/round
%  DEAD_N : a rmax x 1 array of number of dead Normal nodes/round
%  CLUSTERHS : a rmax x 1 array of number of Cluster Heads/round
%  PACKETS_TO_BS : a rmax x 1 array of number packets send to Base Station/round
%  PACKETS_TO_CH : a rmax x 1 array of number of packets send to ClusterHeads/round
%  first_dead: the round where the first node died                   
%                                                                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end




