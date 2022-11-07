clearvars;
%M/M/1

rng(1233) %semente
util(1:10) = 0;     % taxa de utilização do servidor
avg_num_in_queue(1:10) = 0;     % tempo de fila/tempo de simulação
avg_delay(1:10) = 0;    %atraso médio
P(1:10) = 1;    %intensidade de tráfego


for indice = 1:100
	tempo_sim =0.00; %tempo de simulação
	estado_servidor = 1; %Disponível (1) ou ocupado (0)
	pacotes_total = 50; %total de iterações a serem feitas
	pacotes_simulados = 0; %total de iterações realizadas
	media_chegada = 0.01+ 0.001*(indice-1);   %tempo médio de chegada normal
	media_service = 0.01;     %tempo médio de serviço
	time_server_free = 0; %tempo do serviço ocupado
	atraso_total = 0;   %tempo total de atraso
	tempo_fila = 0;     %tempo total em fila
	ite=1;      %iterado para o memorial descritivo
	descrito = zeros(50,2); %memorial descritivo
	tabela = zeros(5,8);    %Tabela de dados
	quadro = [(1:4)' zeros(4,1)];   %lista de eventos com prioridade
	quadro(4,2) = Inf;                                           % Próximo evento de saída
	quadro(3,2) = abs(normrnd(media_chegada,0.01));    % Próximo evento de entrada com prioridade alta
	quadro(2,2) = abs(normrnd(media_chegada,0.01));    % Próximo evento de entrada com prioridade média
	quadro(1,2) = abs(normrnd(media_chegada,0.01));    % Próximo evento de entrada com prioridade baixa
	queue_size = zeros(101,3);  %Tamanho das filas
	
	%Inicialização das filas de prioridade e dimensão das filas
	fila_low = zeros(50,1);     q_low = 0;
	fila_med = zeros(50,1);   q_med = 0;
	fila_high = zeros(50,1);    q_high = 0;
	
	
	%Geração dos pacotes
	while(pacotes_simulados < pacotes_total)
		
		%Verificação do evento mais próximo
		[temp,pri] = min(quadro(:,2));
		%atualização do tempo dos próximos eventos
		quadro(:,2) = quadro(:,2) - temp;
		
		%Cálculo da taxa de utilização
		if (estado_servidor)
			time_server_free = time_server_free + temp;
		end
		
		%Cálculo do tempo de fila
		tempo_fila = tempo_fila + q_low*temp + q_med*temp + q_high*temp;
		%Atualização do tempo de simulação
		tempo_sim = tempo_sim + temp;
		%Atualização do memorial descritivo
		descrito(ite,:) = [tempo_sim,pri];
		tabela(pacotes_simulados +1,:) = [tempo_sim, temp,pri,0, 0, 0, 0, 0];
		
		ite=ite+1;
		
		if(pri==4) %evento de saída
			%Pacote já saiu, busca de novo pacote por prioridade
			if q_high > 0
				%Incremento do atraso = tempo de início de serviço - tempo de chegada
				atraso_total = atraso_total + tempo_sim - fila_high(1);
				%Sorteio do tempo do novo evento de saída
				quadro(4,2) = exprnd(media_service);
				%Gravação do tempo de início e fim do serviço
				tabela(tabela(:,1)==fila_high(1),4) = quadro(4,2);
				tabela(tabela(:,1)==fila_high(1),5) = tempo_sim;
				%Atualização da fila de espera alta
				for i = 1:q_high
					fila_high(i)=fila_high(i+1);
				end
				q_high = q_high - 1;
				
				
			elseif q_med > 0
				%Incremento do atraso = tempo de início de serviço - tempo de chegada
				atraso_total = atraso_total + tempo_sim - fila_med(1);
				%Sorteio do tempo do novo evento de saída
				quadro(4,2) = exprnd(media_service);
				%Gravação do tempo de início e fim do serviço
				tabela(tabela(:,1)==fila_med(1),4) = quadro(4,2);
				tabela(tabela(:,1)==fila_med(1),5) = tempo_sim;
				%Atualização da fila de espera média
				for i = 1:q_med
					fila_med(i)=fila_med(i+1);
				end
				q_med = q_med - 1;
				
				
			elseif q_low > 0
				%Incremento do atraso = tempo de início de serviço - tempo de chegada
				atraso_total = atraso_total + tempo_sim - fila_low(1);
				%Sorteio do tempo do novo evento de saída
				quadro(4,2) = exprnd(media_service);
				%Gravação do tempo de início e fim do serviço
				tabela(tabela(:,1)==fila_low(1),4) = quadro(4,2);
				tabela(tabela(:,1)==fila_low(1),5) = tempo_sim;
				%Atualização da fila de espera média
				for i = 1:q_low
					fila_low(i)=fila_low(i+1);
				end
				q_low = q_low - 1;
				
				
			else
				estado_servidor = 1;
				quadro(4,2) = Inf;
			end
			
		elseif (pri == 3) %Prioridade alta
			%Se o servidor estiver disponível não entra na fila
			if(estado_servidor)
				%Sorteio do próximo evento de saída
				quadro(4,2) = exprnd(media_service);
				%Gravação do tempo de início e fim do serviço
				tabela(tabela(:,1)==tempo_sim,4) = quadro(4,2);
				tabela(tabela(:,1)==tempo_sim,5) = tempo_sim;
				estado_servidor = 0;
			else
				%Aumenta o tamanho da fila
				q_high = q_high + 1;
				fila_high(q_high) = tempo_sim;
			end
			%Sorteio do próximo evento de chegada
			quadro(3,2) = abs(normrnd(media_chegada,0.01));
			pacotes_simulados = pacotes_simulados +1;
			
		elseif (pri == 2) %Prioridade média
			%Se o servidor estiver disponível não entra na fila
			if(estado_servidor)
				%Sorteio do próximo evento de saída
				quadro(4,2) = exprnd(media_service);
				%Gravação do tempo de início e fim do serviço
				tabela(tabela(:,1)==tempo_sim,4) = quadro(4,2);
				tabela(tabela(:,1)==tempo_sim,5) = tempo_sim;
				estado_servidor = 0;
			else
				%Aumenta o tamanho da fila
				q_med = q_med + 1;
				fila_med(q_med) = tempo_sim;
			end
			quadro(2,2) = abs(normrnd(media_chegada,0.01));
			pacotes_simulados = pacotes_simulados +1;
			
		else %Prioridade baixa
			%Se o servidor estiver disponível não entra na fila
			if(estado_servidor)
				%Sorteio do próximo evento de saída
				quadro(4,2) = exprnd(media_service);
				%Gravação do tempo de início e fim do serviço
				tabela(tabela(:,1)==tempo_sim,4) = quadro(4,2);
				tabela(tabela(:,1)==tempo_sim,5) = tempo_sim;
				estado_servidor = 0;
			else
				%Aumenta o tamanho da fila
				q_low = q_low + 1;
				fila_low(q_low) = tempo_sim;
			end
			quadro(1,2) = abs(normrnd(media_chegada,0.01));
			pacotes_simulados = pacotes_simulados +1;
			
		end
		queue_size(ite,:) = [q_high q_med q_low];
	end
	
	fila_ttl = 1;   %Tamanho total da fila
	
	quadro(3,2) = Inf;
	quadro(2,2) = Inf;
	quadro(1,2) = Inf;
	
	%Processamento dos pacotes ainda em fila
	while(fila_ttl)
		fila_ttl = q_high + q_med + q_low;
		%Verificação do evento mais próximo
		[temp,pri] = min(quadro(:,2));
		%atualização do tempo dos próximos eventos
		quadro(:,2) = quadro(:,2) - temp;
		
		%Cálculo da utilização
		if (estado_servidor)
			time_server_free = time_server_free + temp;
		end
		
		%Cálculo do tempo de fila
		tempo_fila = tempo_fila + q_low*temp + q_med*temp + q_high*temp;
		%Atualização do tempo de simulação
		tempo_sim = tempo_sim + temp;
		%Atualização do memorial descritivo
		descrito(ite,:) = [tempo_sim,pri];
		ite=ite+1;
		
		if(pri==4) %evento de saída
			
			%Pacote já saiu, busca de novo pacote por prioridade
			if q_high > 0
				
				atraso_total = atraso_total + tempo_sim - fila_high(1);
				quadro(4,2) = exprnd(media_service);
				tabela(tabela(:,1)==fila_high(1),4) = quadro(4,2);
				tabela(tabela(:,1)==fila_high(1),5) = tempo_sim;
				
				for i = 1:q_high
					fila_high(i)=fila_high(i+1);
				end
				q_high = q_high - 1;
				
				
			elseif q_med > 0
				
				atraso_total = atraso_total + tempo_sim - fila_med(1);
				quadro(4,2) = exprnd(media_service);
				tabela(tabela(:,1)==fila_med(1),4) = quadro(4,2);
				tabela(tabela(:,1)==fila_med(1),5) = tempo_sim;
				
				for i = 1:q_med
					fila_med(i)=fila_med(i+1);
				end
				q_med = q_med - 1;
				
				
			elseif q_low > 0
				
				atraso_total = atraso_total + tempo_sim - fila_low(1);
				quadro(4,2) = exprnd(media_service);
				tabela(tabela(:,1)==fila_low(1),4) = quadro(4,2);
				tabela(tabela(:,1)==fila_low(1),5) = tempo_sim;
				
				for i = 1:q_low
					fila_low(i)=fila_low(i+1);
				end
				q_low = q_low - 1;
				
				
			else
				estado_servidor = 1;
				quadro(4,2) = Inf;
			end
			
		end
		queue_size(ite,:) = [q_high q_med q_low];
		
	end
	
	for i = 1:pacotes_simulados
		tabela(i,7) = tabela(i,5) + tabela(i,4);	%Tempo de saída do servidor
		tabela(i,6) = tabela(i,5) - tabela(i,1);	%Tempo em fila
		tabela(i,8) = tabela(i,7) - tabela(i,1);	%Tempo no sistema
	end
	
	util(indice) = (tempo_sim - time_server_free)/tempo_sim;
	avg_num_in_queue(indice) = tempo_fila/tempo_sim;
	avg_delay(indice) = sum(tabela(:,6))/pacotes_simulados;
	P(indice) = media_service/media_chegada;
end

figure('name','Taxa de utilização');
plot(P,util,'r');
xlabel('Intensidade de tráfego');
ylabel('Taxa de utilização');
% saveas(gcf,"Norm" + "_Util.jpg")

figure('name','Tempo médio na fila');
plot(P,avg_num_in_queue,'m');
xlabel('Intensidade de tráfego');
ylabel('Tempo médio na fila');
% saveas(gcf,"Norm" + "_Queue.jpg")

figure('name','Atraso médio por pacote');
plot(P,avg_delay,'b');
xlabel('Intensidade de tráfego');
ylabel('Atraso médio por pacote');
% saveas(gcf,"Norm" + "_Delay.jpg")