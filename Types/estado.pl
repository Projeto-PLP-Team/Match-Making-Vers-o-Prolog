% correspondente a DataTypes, Restrictions e SystemState


% --- DATATYPES (Regras de exibição) ---
% A estrutura dos dados é implícita:
% time(Nome, Cidade)
% data(Dia, Mes, Ano)
% partida(Mandante, Visitante, Data, Resultado, Local)

% imprime_data(+Data)
imprime_data(data(0, 0, 0)) :- 
    write('Data a definir').

imprime_data(data(Dia, Mes, Ano)) :- 
    Dia \= 0, Mes \= 0, Ano \= 0,
    format('~w/~w/~w', [Dia, Mes, Ano]).


% --- RESTRICTIONS ---
% Estrutura: restricoes(Geo, Conflito, MaxSequencia, LimiteFadiga)

% restricoes_padrao(-Restricoes)
restricoes_padrao(restricoes(true, true, 2, 2500)).

% relaxar_restricao(+RestricoesAtuais, -RestricoesRelaxadas)
relaxar_restricao(
    restricoes(Geo, Conflito, MaxSeq, LimiteAtual), 
    restricoes(Geo, Conflito, MaxSeq, NovoLimite)
) :-
    NovoLimite is LimiteAtual + 500.


% --- SYSTEM STATE ---
% Estrutura: estado_sistema(Equipes, Campeonato, Config, MsgFeedback)

% estado_inicial(-Estado)
estado_inicial(
    estado_sistema([], nenhum, restricoes(true, true, 2, 2500), "Bem-vindo! Cadastre os times para comecar.")
).

% adicionar_time(+NovoTime, +EstadoAtual, -NovoEstado)
adicionar_time(NovoTime, EstadoAtual, NovoEstado) :-
    % Desestrutura o estado atual
    EstadoAtual = estado_sistema(Equipes, Camp, Config, _),
    
    % Adiciona o novo time na cabeça da lista
    NovaListaEquipes = [NovoTime | Equipes],
    
    % Extrai o nome do time para a mensagem
    NovoTime = time(Nome, _),
    format(string(NovaMensagem), "Time ~w cadastrado!", [Nome]),
    
    % Monta o novo estado
    NovoEstado = estado_sistema(NovaListaEquipes, Camp, Config, NovaMensagem).