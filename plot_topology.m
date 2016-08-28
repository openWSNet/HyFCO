function plot_topology(gene_of_each_round_old,gene_of_each_round,sense_range,node_x,node_y,target_x,target_y)
temp_x=[];
temp_y=[];
temp2_x=[];
temp2_y=[];
clf
for i=1:length(gene_of_each_round_old)
      if(gene_of_each_round_old(i)==1)
            temp_x(length(temp_x)+1)=node_x(i);
            temp_y(length(temp_y)+1)=node_y(i);
            axis image;
            hold on;  
            subplot(1,2,1),text(node_x(i),node_y(i),int2str(i));
      end
end

axis image;
hold on;    

if isempty(temp_x)~=1 && isempty(temp_y)~=1
    subplot(1,2,1),circle(sense_range,temp_x,temp_y,'b');
end

for i=1:length(target_x(:,1)) %%先畫一次所有的target
    axis image;
    hold on;      
    subplot(1,2,1),plot(target_x(i,:),target_y(i,:),'*'); %plot不接受以struct畫圖
end
% ------------------------------------------------------------------------------------以下右邊圖
for i=1:length(gene_of_each_round)
      if(gene_of_each_round(i)==1)
            temp2_x(length(temp2_x)+1)=node_x(i);
            temp2_y(length(temp2_y)+1)=node_y(i);
            axis image;
            hold on;  
            subplot(1,2,2),text(node_x(i),node_y(i),int2str(i));
      end
end
if isempty(temp2_x)~=1 && isempty(temp2_y)~=1
    subplot(1,2,2),circle(sense_range,temp2_x,temp2_y,'b');
end
for i=1:length(target_x(:,1)) %%先畫一次所有的target
    axis image;
    hold on;      
    subplot(1,2,2),plot(target_x(i,:),target_y(i,:),'*'); %plot不接受以struct畫圖
end

end