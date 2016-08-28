%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [current_round,coverage_rec,remaining_node_set,remaining_node_E_set,last_round] = LEACH(rmax, p, current_node_set, sense_node, node_x, node_y, node_e, sink_x, sink_y,...
                                              packet_bit,grid_num, target_covered_for_each_node,coverage_constraint) 
                                          % coverage_constraint �ΨӶ}���л\�v����
                                          
%avg_ch �O ��S���`�Ialive���ɭԡA���e����Ҧ�rounds��head������
% current_node_set �����ثe��node set �s�������ǡA�i�Jleach ��|�q�s�s���q1�}�l
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

dist_node=zeros(sense_node+1,sense_node+1); % �p��node�������Z���Asense_node+1�Osink
for i=1:(sense_node+1)
    for j=1:(sense_node+1)
        dist_node(i,j)=dist(S(i).xd,S(i).yd,S(j).xd,S(j).yd);
    end
end
target_covered=zeros(1,grid_num); %�������@�}�l��coverage
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
       for i=1:sense_node  %��sG�ȡA�ΨӧP�_�O�_��epoch�w�g����
         S(i).G=0;
         S(i).cl=0;
       end
    end
    for y=1:sense_node
       S(y).sons=0; %�O���C��round���A�Y�Ohead����Ҫ��`�I���X��
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

%��s���������`�I�� �����л\�v����
target_covered=zeros(1,grid_num);
for k=1:sense_node
    if S(k).E>0
        target_covered=or(target_covered,target_covered_for_each_node(current_node_set(k),:));
    end
end
remaining_node_set=[];
remaining_node_E_set=[];
for node_count=1:sense_node %�p��ѤU�� node������
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
current_round=r;  %%���OR+1
flag=0;
if coverage_constraint==1   % ���}���л\�v����
%     if coverage_rec(1,r+1)<grid_num   % target��64��  ���Ϥp��64�� �N��coverage <100%  �h���X       
%         break;
%     end
    for k=1:sense_node %���Ϧ��`�I�����N���X
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
cluster=1; %�@�ӭp�ƫ���
alive_node=0;
for i=1:1:sense_node
   if(S(i).E>0)
   temp_rand=rand;    
   alive_node=alive_node+1;
   if ( (S(i).G)<=0) %G�p�󵥩�0�~�����|�Q�אּHEAD
       %Election of Cluster Heads    
       if(temp_rand<= (p/(1-p*mod(r,round(1/p)))))
            countCHs=countCHs+1;
            packets_TO_BS=packets_TO_BS+1;  
            S(i).type='C';
            S(i).G=round(1/p)-1;   % ����Lhead��node ��G�ȴN���|�O0 �]���i�H�ΨӧP�_�U��round�O�_�n�����ӷ�head
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;
            
            distance=dist_node(i,sense_node+1);%�Msink���Z��
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
if (alive_node==0 && flag==0 )||(r==rmax && flag==0 ) %�Y�F��̤�round �Υ����`�I���` �N�O��last_round
    last_round=r;
    flag=1;
end
packets_TO_CH=0;
%Election of Associated Cluster Head for Normal Nodes
for i=1:1:sense_node
   if ( S(i).type=='N' && S(i).E>0)
     if(cluster-1>=1) %�Y������ ���@�ӥH�W��head
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
         % �έphead�ǰe��BS���ʥ]�ƶq  
for h=1:sense_node %% �p��head�Ǩ�bs����q����
    if S(h).type=='C' && S(h).E>0
       dis=dist_node(h,sense_node+1);%�Msink���Z��
       S(h).E=S(h).E- ( EDA*(packet_bit) + ETX*(packet_bit) + Emp*packet_bit*( dis * dis)); 
    end
end
% hold on;

countCHs;
rcountCHs=rcountCHs+countCHs;

for i=1:sense_node %%�N��q�]���̫�@������ �ɭP�C��s���`�I �^�k��0
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

% plot(sense_node-DEAD(2:(rmax+1)),'b');     %�]��DEAD�O�q�ĤG��ROUND�H��~����
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




