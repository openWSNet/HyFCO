node_num=[60 80 100 120 140 160];
target_num=[10 20 30 40 50];
sensing_range=[100 140 180 220 260 300];
field_x=500;
field_y=500;


for node_case=1:length(node_num)
    for target_case=1:length(target_num)
        for sensing_case=1:length(sensing_range)
            for test_time=1:30
                while (1)
                        node_x=[];
                        node_y=[];
                        target_x=[];
                        target_y=[];
                        covermap=[];
                        remaining_node_array=[];
                         for i=1:node_num(node_case)    %隨機產生node %//
                               node_x(i)=fix(rand*field_x);
                               node_y(i)=fix(rand*field_y);
                               remaining_node_array(i)=i;  %node id
                         end
                          for j=1:target_num(target_case)    %隨機產生node %//
                               target_x(j)=fix(rand*field_x);
                               target_y(j)=fix(rand*field_y);
                          end         
                         for k=1:node_num(node_case)  %產生coverage map
                             for m=1:target_num(target_case) 
                                 if dist(node_x(k),node_y(k),target_x(m),target_y(m))<sensing_range(sensing_case)
                                        covermap(k,m)=1;
                                 else
                                        covermap(k,m)=0;
                                 end
                             end
                         end
                         if cal_init_discrete_cov(covermap)==1
                                 filename=[num2str(node_case) '_' num2str(target_case) '_' num2str(sensing_case) '_'  num2str(test_time) '.mat'];
                                 fprintf('save ok: %d-%d-%d-%d\n',node_case,target_case,sensing_case,test_time);
                                 save( filename, 'node_x', 'node_y', 'target_x', 'target_y',  'remaining_node_array', 'covermap');                         
                                 break;
                         end                     
                end
            end
      end
   end
end
