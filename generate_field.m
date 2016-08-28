function [grid_field,node_field,node_cover_field]=generate_field(node_x,node_y,grid_range_x,grid_range_y,sense_range,sense_node)
    grid_field=zeros(grid_range_y,grid_range_x);
    field_num=1;
    for i=1:sense_node
        fprintf('%d,',i);
        node_grid_intersection=zeros(grid_range_y,grid_range_x);
        for gi=1:grid_range_y
            for gj=1:grid_range_x
                if dist(gi,gj,node_x(i),node_y(i))<sense_range
                    node_grid_intersection(gi,gj)=1;
                end
            end
        end
        field_rec_temp=[];
        for gi=1:grid_range_y
            for gj=1:grid_range_x
               if node_grid_intersection(gi,gj)==1 
                   if isempty(find(field_rec_temp==grid_field(gi,gj)))
                        field_rec_temp=[field_rec_temp grid_field(gi,gj)];     
                   end
               end
            end
        end
     for rec_count=1:length(field_rec_temp)        
        for gi=1:grid_range_y
            for gj=1:grid_range_x   
                 if node_grid_intersection(gi,gj)==1 
                    if grid_field(gi,gj)==field_rec_temp(rec_count)
                       grid_field(gi,gj)=field_num;                       
                    end   
                 end
            end
        end
        field_num=field_num+1; 
     end
    end
 
    
    field_rec_chk=[];
    for gi=1:grid_range_y
        for gj=1:grid_range_x       
            if grid_field(gi,gj)~=0
                if isempty(find(field_rec_chk==grid_field(gi,gj)))
                    field_rec_chk=[field_rec_chk grid_field(gi,gj)];
                end
            end
        end
    end

    field_rec_chk=sort(field_rec_chk);
    for chk_count=1:length(field_rec_chk)
        for gi=1:grid_range_y
            for gj=1:grid_range_x   
                if grid_field(gi,gj)==field_rec_chk(chk_count)
                    grid_field(gi,gj)=chk_count;
                end
            end
        end
    end
    
   node_field={};
    for i=1:sense_node %找出每個node的field
        node_field_rec=[];
        for gi=1:grid_range_y
            for gj=1:grid_range_x   
                if dist(gi,gj,node_x(i),node_y(i))<sense_range
                    if isempty(find(node_field_rec==grid_field(gi,gj)))
                        node_field_rec=[node_field_rec grid_field(gi,gj)];
                    end
                end
            end
        end
        node_field{i}=node_field_rec;
    end
    
    node_cover_field=zeros(sense_node,length(field_rec_chk)); %將node所覆蓋的field轉換成10string
    for node_count=1:sense_node
        node_field_mat=node_field{node_count};
        for cell_count=1:length(node_field{node_count})     
           node_cover_field(node_count,node_field_mat(cell_count))=1;
        end
    end
   
    
    
    
    
%     [p_x,p_y] = meshgrid(1:grid_range_x,1:grid_range_y);%畫出文字旁的點   
%     plot(p_x,p_y,'*');
    
% for plot_count=1:length(field_rec_chk) %畫出不同顏色
%     pointcolor=[rand,rand,rand];
%         for gi=1:grid_range_y
%             for gj=1:grid_range_x   
%                 if grid_field(gi,gj)==plot_count
%                     plot(gi,gj,'color',pointcolor);
%                     hold on;
%                 end
%             end
%         end
% end

%         for gi=1:grid_range_y  %畫出文字
%             for gj=1:grid_range_x   
%                 hold on;
%                 text(gi,gj+0.2,int2str(grid_field(gi,gj)));
%             end
%         end
% 
%     axis image;
%     circle(sense_range,node_x,node_y,'b');
end



