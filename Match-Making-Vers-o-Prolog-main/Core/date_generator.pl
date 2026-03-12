% ==========================================
% ARQUIVO: Core/date_generator.pl
% ==========================================

:- module(date_generator, [
    gerar_datas/4,
    avancar_dias/3
]).

% Importamos nosso validador para saber os dias exatos de cada mês
:- use_module('../Validation/date_validator').

% --- AVANÇAR DIAS (Calendário Real) ---

% avancar_um_dia(+DataAtual, -NovaData)
% Caso 1: O dia atual é menor que o máximo de dias daquele mês.
avancar_um_dia(data(Dia, Mes, Ano), data(NovoDia, Mes, Ano)) :-
    dias_no_mes(Mes, Ano, MaxDias),
    Dia < MaxDias,
    NovoDia is Dia + 1, !.

% Caso 2: Último dia do mês (virada de mês).
avancar_um_dia(data(Dia, Mes, Ano), data(1, NovoMes, Ano)) :-
    dias_no_mes(Mes, Ano, MaxDias),
    Dia =:= MaxDias,
    Mes < 12,
    NovoMes is Mes + 1, !.

% Caso 3: Último dia do ano (31 de Dezembro).
avancar_um_dia(data(31, 12, Ano), data(1, 1, NovoAno)) :-
    NovoAno is Ano + 1, !.

% avancar_dias(+QuantidadeDias, +DataAtual, -NovaData)
avancar_dias(0, Data, Data) :- !.
avancar_dias(N, DataAtual, NovaData) :-
    N > 0,
    avancar_um_dia(DataAtual, DataSeguinte),
    N1 is N - 1,
    avancar_dias(N1, DataSeguinte, NovaData).


% --- GERADOR DE DATAS DO CAMPEONATO ---
% gerar_datas(+Rodadas, +DataInicial, +IntervaloDias, -RodadasAgendadas)

% Condição de parada: acabaram as rodadas.
gerar_datas([], _, _, []).

% Passo recursivo: agenda a rodada atual e avança a data para a próxima.
gerar_datas([Rodada | RestoRodadas], DataAtual, Intervalo, [RodadaAgendada | RestoAgendado]) :-
    agendar_rodada(Rodada, DataAtual, RodadaAgendada),
    avancar_dias(Intervalo, DataAtual, ProximaData),
    gerar_datas(RestoRodadas, ProximaData, Intervalo, RestoAgendado).


% --- FUNÇÃO AUXILIAR: AGENDAR RODADA ---
% agendar_rodada(+RodadaSemData, +Data, -RodadaComData)
% Desestrutura a partida de 5 argumentos, descarta a data(0,0,0) e insere a nova.

agendar_rodada([], _, []).
agendar_rodada([Partida | Resto], NovaData, [PartidaAgendada | RestoAgendado]) :-
    % Extrai os dados da partida antiga (o '_' ignora a data velha)
    Partida = partida(Mandante, Visitante, _, Local, Resultado),
    
    % Monta a nova partida com a NovaData
    PartidaAgendada = partida(Mandante, Visitante, NovaData, Local, Resultado),
    
    % Continua para o resto da rodada
    agendar_rodada(Resto, NovaData, RestoAgendado).