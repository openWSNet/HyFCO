function y=local_search(sensor_select) %代為單位
   pop=sensor_select;
        for i=1:length(pop(:,1)) %1代裡有幾個個體
            active_node=find(pop(i,:)==1);
            for j=1:length(active_node)  %找出active_node裡面哪些可以刪掉 每個刪完後 都需重新評估fit
                [f_pre,temp1]=fit_foreach(pop(i,:)); %個體評估
                pop(i,active_node(j))=0;
                [f_fit,temp2]=fit_foreach(pop(i,:));
                if f_pre>f_fit
                    pop(i,active_node(j))=1;
                end         
            end
        end          
y=pop;        
