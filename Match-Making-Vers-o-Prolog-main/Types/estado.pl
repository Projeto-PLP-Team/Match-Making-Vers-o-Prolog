:- module(estado, [
    imprime_data/1,
    restricoes_padrao/1,
    relaxar_restricao/2,
    estado_inicial/1,
    adicionar_time/3,
    adicionar_cidade/3,
    excluir_time/3,
    excluir_cidade/3
]).

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
% Estrutura: estado_sistema(Equipes, Cidades, Campeonato, Config, MsgFeedback)

% estado_inicial(-Estado)
estado_inicial(
    estado_sistema([], [], nenhum, restricoes(true, true, 2, 2500), "Bem-vindo! Cadastre os times para comecar.")
).

% adicionar_time(+NovoTime, +EstadoAtual, -NovoEstado)
adicionar_time(NovoTime, EstadoAtual, NovoEstado) :-
    % Desestrutura o estado atual
    EstadoAtual = estado_sistema(Equipes, Cidades, Camp, Config, _),
    
    % Adiciona o novo time na cabeça da lista
    NovaListaEquipes = [NovoTime | Equipes],
    
    % Extrai o nome do time para a mensagem
    NovoTime = time(Nome, _),
    format(string(NovaMensagem), "Time ~w cadastrado!", [Nome]),
    
    % Monta o novo estado
    NovoEstado = estado_sistema(NovaListaEquipes, Cidades, Camp, Config, NovaMensagem).

% adicionar_cidade(+NovaCidade, +EstadoAtual, -NovoEstado)
adicionar_cidade(NovaCidade, EstadoAtual, NovoEstado) :-
    % Desestrutura o estado atual
    EstadoAtual = estado_sistema(Equipes, Cidades, Camp, Config, _),
    
    % Adiciona a nova cidade na cabeça da lista
    NovaListaCidades = [NovaCidade | Cidades],
    
    % Extrai o nome da cidade para a mensagem
    NovaCidade = cidade(Nome, _, _),
    format(string(NovaMensagem), "Cidade ~w cadastrada!", [Nome]),
    
    % Monta o novo estado
    NovoEstado = estado_sistema(Equipes, NovaListaCidades, Camp, Config, NovaMensagem).

% excluir_time(+NomeTime, +EstadoAtual, -NovoEstado)
excluir_time(Nome, EstadoAtual, NovoEstado) :-
    EstadoAtual = estado_sistema(Equipes, Cidades, Camp, Config, _),
    (select(time(Nome, _), Equipes, NovasEquipes) ->
        format(string(Msg), "Time ~w excluido com sucesso!", [Nome]),
        NovoEstado = estado_sistema(NovasEquipes, Cidades, Camp, Config, Msg)
    ;
        format(string(Msg), "Erro: Time ~w nao encontrado!", [Nome]),
        NovoEstado = estado_sistema(Equipes, Cidades, Camp, Config, Msg)
    ).

% excluir_cidade(+NomeCidade, +EstadoAtual, -NovoEstado)
excluir_cidade(Nome, EstadoAtual, NovoEstado) :-
    EstadoAtual = estado_sistema(Equipes, Cidades, Camp, Config, _),
    (select(cidade(Nome, _, _), Cidades, NovasCidades) ->
        format(string(Msg), "Cidade ~w excluida com sucesso!", [Nome]),
        NovoEstado = estado_sistema(Equipes, NovasCidades, Camp, Config, Msg)
    ;
        format(string(Msg), "Erro: Cidade ~w nao encontrada!", [Nome]),
        NovoEstado = estado_sistema(Equipes, Cidades, Camp, Config, Msg)
    ).