function y=local_search(sensor_select) %�N�����
   pop=sensor_select;
        for i=1:length(pop(:,1)) %1�N�̦��X�ӭ���
            active_node=find(pop(i,:)==1);
            for j=1:length(active_node)  %��Xactive_node�̭����ǥi�H�R�� �C�ӧR���� ���ݭ��s����fit
                [f_pre,temp1]=fit_foreach(pop(i,:)); %�������
                pop(i,active_node(j))=0;
                [f_fit,temp2]=fit_foreach(pop(i,:));
                if f_pre>f_fit
                    pop(i,active_node(j))=1;
                end         
            end
        end          
y=pop;        
