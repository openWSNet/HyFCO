function [node_cover_grid]=generate_discrete_field(node_x,node_y,grid_range_x,grid_range_y,sense_range,sense_node,grid_num,span)
    node_cover_grid=zeros(sense_node,grid_num);
    
%     for grid_count=1:grid_num
%         grid_x(grid_count)=fix(rand*grid_range_x);
%         grid_y(grid_count)=fix(rand*grid_range_y);
%     end
    
    for i=1:grid_range_y*span   % 決定target座標 0.04 x 200 = 8
        for j=1:grid_range_x*span
            target_x(i,j)=6.25+(j-1)*12.5;
            target_y(i,j)=6.25+(i-1)*12.5;
        end
    end 
% .......    
% 25 26 27 28 29 30 31 32
% 17 18 19 20 21 22 23 24    target(3,1) target(3,2) ....
%  9 10 11 12 13 14 15 16    target(2,1)=(18.75,6.25) target(2,2)=(18.75,18.75) ....
%  1  2  3  4  5  6  7  8    target(1,1)=(6.25,6.25) target(1,2)=(6.25,18.75) .... 
    row_count=0;
    col_count=0;
    for grid_count=1:grid_num
        if mod(grid_count,8) == 1 %1 9 17...
            row_count=row_count+1;
            col_count=1;
        else
            col_count=col_count+1;
        end      
        grid_x(grid_count)=target_x(row_count,col_count);
        grid_y(grid_count)=target_y(row_count,col_count);
    end
    for i=1:sense_node
        for grid_count=1:grid_num
            if dist(node_x(i),node_y(i),grid_x(grid_count),grid_y(grid_count))<sense_range
                node_cover_grid(i,grid_count)=1;
            end
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



