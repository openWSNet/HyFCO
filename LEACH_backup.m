%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% best_gene_rec 紀錄基因裡等於1的那些位置
% 有被選擇到的基因(=1) 被集合在此陣列裡做運算
% gene_of_each_round 紀錄每個ROUND後仍活著的節點
% best_gene ga跑完後的最佳基因
% coverage_rec 紀錄每個round的覆蓋率
%                                                                      %
% SEP: A Stable Election Protocol for clustered                        %
%      heterogeneous wireless sensor networks                          %
%                                                                      %
% (c) Georgios Smaragdakis                                             %
% WING group, Computer Science Department, Boston University           %
%                                                                      %
% You can find full documentation and related information at:          %
% http://csr.bu.edu/sep                                                %
%                                                                      %  
% To report your comment or any bug please send e-mail to:             %
% gsmaragd@cs.bu.edu                                                   %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
% This is the LEACH [1] code we have used.                             %
% The same code can be used for FAIR if m=1                            %
%                                                                      %
% [1] W.R.Heinzelman, A.P.Chandrakasan and H.Balakrishnan,             %
%     "An application-specific protocol architecture for wireless      % 
%      microsensor networks"                                           % 
%     IEEE Transactions on Wireless Communications, 1(4):660-670,2002  %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [DEAD,S]=LEACH_backup(best_gene,node_x,node_y,sink_x,sink_y,p,rmax,local_search_for_alive_neighbor_flag) 

global target_x target_y ;
coverage_rec=zeros(1,rmax);

if local_search_for_alive_neighbor_flag==1
    gene_of_each_round=best_gene;
else
    gene_of_each_round=ones(1,length(best_gene));
end


Eo=0.5;
%Eelec=Etx=Erx
ETX=50*0.000000001;
ERX=50*0.000000001;
%Transmit Amplifier types
Efs=10*0.000000000001;
Emp=0.0013*0.000000000001;
%Data Aggregation Energy
EDA=5*0.000000001;


%%%%%%%%%%%%%%%%%%%%%%%%% END OF PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%

%Computation of do
do=sqrt(Efs/Emp);

n=length(best_gene);

for i=1:1:n
        S(i).xd=node_x(i);
        XR(i)=S(i).xd;
        S(i).yd=node_y(i);
        YR(i)=S(i).yd;
        S(i).G=0;
        %initially there are no cluster heads only nodes
        S(i).type='N';

        temp_rnd0=i;
        %Random Election of Normal Nodes
        if (temp_rnd0>=0.1*n+1) 
            S(i).E=Eo;
            S(i).ENERGY=0;
        end
        %Random Election of Advanced Nodes
        if (temp_rnd0<0.1*n+1)  
            S(i).E=Eo*(1+0);
            S(i).ENERGY=1;
        end
        
end

S(n+1).xd=sink_x;
S(n+1).yd=sink_y;
node_x(n+1)=sink_x;
node_y(n+1)=sink_y;

dist_node=zeros(n+1,n+1);
for i=1:(n+1)
    for j=1:(n+1)
        dist_node(i,j)=dist(node_x(i),node_y(i),node_x(j),node_y(j));
    end
end




countCHs=0;
%counter for CHs per round
rcountCHs=0;
cluster=1;

countCHs;
rcountCHs=rcountCHs+countCHs;
flag_first_dead=0;

%%%%%%%%%%%%%% round start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for r=1:1:rmax
  %Operation for epoch
  r
  if(mod(r, round(1/p) )==0)
    for i=1:1:n
        S(i).G=0;
        S(i).cl=0;
    end
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

% figure(1);


for i=1:1:n
    
    %checking if there is a dead node
    if (S(i).E<=0)
%         plot(S(i).xd,S(i).yd,'red .');
        dead=dead+1;
        gene_of_each_round(i)=0;  %假使節點死掉就要更新基因
        if local_search_for_alive_neighbor_flag==1
            gene_of_each_round=local_search_for_alive_neighbor(i,gene_of_each_round,S,dist_node);
        end
        if(S(i).ENERGY==1)
            dead_a=dead_a+1;
        end
        if(S(i).ENERGY==0)
            dead_n=dead_n+1;
        end
%         hold on;    
    end

    if S(i).E>0
        S(i).type='N';
        if (S(i).ENERGY==0)  
%         plot(S(i).xd,S(i).yd,'o');
        end
        if (S(i).ENERGY==1)  
%         plot(S(i).xd,S(i).yd,'+');
        end
%         hold on;
    end
   
end
% plot(S(n+1).xd,S(n+1).yd,'x');
    %更新完死掉的節點後 執行覆蓋率評估
    [coverage_rec(1,r+1),temp]=fit_foreach(gene_of_each_round);
    

STATISTICS(r+1).DEAD=dead;
DEAD(r+1)=dead;
DEAD_N(r+1)=dead_n;
DEAD_A(r+1)=dead_a;

%When the first node dies
if (dead==1)
    if(flag_first_dead==0)
        first_dead=r
        flag_first_dead=1;
    end
end

countCHs=0;
cluster=1; %一個計數指標
for i=1:1:n
   if(S(i).E>0)
   temp_rand=rand;     
   if ( (S(i).G)<=0 && gene_of_each_round(i)==1)

 %Election of Cluster Heads
       if(temp_rand<= (p/(1-p*mod(r,round(1/p)))))
            countCHs=countCHs+1;
            packets_TO_BS=packets_TO_BS+1;
            PACKETS_TO_BS(r+1)=packets_TO_BS;
            
            S(i).type='C';
            S(i).G=round(1/p)-1;   % 有當過head的node 其G值就不會是0 因此可以用來判斷下個round是否要選取其來當head
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;
%             plot(S(i).xd,S(i).yd,'k*');
            
        %    distance=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 ); %和sink的距離
            distance=dist_node(i,n+1);%和sink的距離
            C(cluster).distance=distance;
            C(cluster).id=i;
            X(cluster)=S(i).xd;
            Y(cluster)=S(i).yd;
            cluster=cluster+1;
            
            %Calculation of Energy dissipated
            distance;
            if (distance>do)
                S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
            end
            if (distance<=do)
                S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance )); 
            end
        end     
    
    end
  end 
end

STATISTICS(r+1).CLUSTERHEADS=cluster-1;
CLUSTERHS(r+1)=cluster-1;

%Election of Associated Cluster Head for Normal Nodes
for i=1:1:n
   if ( S(i).type=='N' && S(i).E>0 && gene_of_each_round(i)==1)
     if(cluster-1>=1)
       %min_dis=sqrt( (S(i).xd-S(n+1).xd)^2 + (S(i).yd-S(n+1).yd)^2 );
       min_dis=dist_node(i,n+1);
       min_dis_cluster=1;
       for c=1:1:cluster-1
           temp=min(min_dis,sqrt( (S(i).xd-C(c).xd)^2 + (S(i).yd-C(c).yd)^2 ) );
           if ( temp<min_dis )
               min_dis=temp;
               min_dis_cluster=c;
           end
       end
       
       %Energy dissipated by associated Cluster Head
            min_dis;
            if (min_dis>do)
                S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
            end
            if (min_dis<=do)
                S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
            end
        %Energy dissipated
        if(min_dis>0)
          S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 ); 
         PACKETS_TO_CH(r+1)=n-dead-cluster+1; 
        end

       S(i).min_dis=min_dis;
       S(i).min_dis_cluster=min_dis_cluster;
           
   end
 end
end
% hold on;

countCHs;
rcountCHs=rcountCHs+countCHs;


end

figure(2);

plot(n-DEAD(2:(rmax+1)),'b');     %因為DEAD是從第二個ROUND以後才有值
figure(3);
target_num=length(target_x(1,:))*length(target_y(:,1));

plot(coverage_rec(2:(rmax+1))/target_num,'r'); % 因為coverage_rec也是從第二個round以後才有值

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




