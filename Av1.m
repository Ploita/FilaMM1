clear
%M/M/1

rng(1233) %semente
tempo_sim =0.00; %tempo de simulação
estado_servidor = 1; %Disponível (1) ou ocupado (0)
pacotes_total = 50; %total de iterações a serem feitas
pacotes_simulados = 0; %total de iterações realizadas
media_chegada = 0.1;   %tempo médio de chegada normal
media_service =0.001;     %tempo médio de serviço
ite=1;
descrito = zeros(50,2);

quadro = [(1:4)' zeros(4,1)];
quadro(4,2) = Inf;
quadro(3,2) = exprnd(media_chegada*10);
quadro(2,2) = exprnd(media_chegada);
quadro(1,2) = exprnd(media_chegada);

fila_low = zeros(15,1);     q_low = 1;
fila_med = zeros(15,1);   q_med = 1;
fila_high = zeros(15,1);    q_high = 1;

while(pacotes_simulados < pacotes_total)
    [temp,pri] = min(quadro(:,2));
    quadro(:,2) = quadro(:,2) - temp;
    tempo_sim = tempo_sim + temp;
    descrito(ite,:) = [tempo_sim,pri];
    
    if(pri==4) %evento de saída
        if(fila_high(1) ~= 0)
            for i = 1:size(nonzeros(fila_high),1)-1
                fila_high(i)=fila_high(i+1);
            end
            quadro(4,2) = exprnd(media_service);
            
        elseif (fila_med(1) ~= 0)
            for i = 1:size(nonzeros(fila_med),1)-1
                fila_med(i)=fila_med(i+1);
            end
            quadro(4,2) = exprnd(media_service);
            
        elseif (fila_low(1) ~= 0)
            for i = 1:size(nonzeros(fila_low),1)-1
                fila_low(i)=fila_low(i+1);
            end
            quadro(4,2) = exprnd(media_service);
            
        else
            estado_servidor = 1;
            quadro(4,2) = Inf;
        end
        
    elseif (pri == 3) %Prioridade alta
        if (estado_servidor)
            quadro(4,2) = exprnd(media_service);
        end
        if (fila_high(1) ==0)
            fila_high(1) = tempo_sim;
        else
            fila_high = [fila_high; tempo_sim];
        end
        quadro(3,2) = exprnd(media_chegada);
        
        pacotes_simulados = pacotes_simulados +1;
        
    elseif (pri == 2) %Prioridade média
        if (estado_servidor)
            quadro(4,2) = exprnd(media_service);
        end
        
        if (fila_med(1) ==0)
            fila_med(1) = tempo_sim;
        else
            fila_med = [fila_med; tempo_sim];
        end
        quadro(2,2) = exprnd(media_chegada);
        
        pacotes_simulados = pacotes_simulados +1;
        
    else %Prioridade baixa
        if (estado_servidor)
            quadro(4,2) = exprnd(media_service);
        end
        if (fila_low(1) ==0)
            fila_low(1) = tempo_sim;
        else
            fila_low = [fila_low; tempo_sim];
        end
        quadro(1,2) = exprnd(media_chegada);
        
        pacotes_simulados = pacotes_simulados +1;
    end
    ite=ite+1;
end