% Validation/round_validator.pl

:- module(round_validator, [
    validar_rodada/4
]).

% Precisaremos importar a distância (fará sentido quando rodarmos tudo no main)
:- use_module('../Geography/distance').

% --- VALIDADOR PRINCIPAL ---
% validar_rodada(+Config, +Historico, +Partidas, +Cidades)
validar_rodada(Config, Historico, Partidas, Cidades) :-
    \+ times_repetidos(Partidas), % \+ é a negação em Prolog (equivalente ao 'not')
    checar_conflito(Config, Partidas),
    checar_sequencia(Config, Historico, Partidas),
    checar_geografia(Config, Historico, Partidas, Cidades).

% --- 1. TIMES REPETIDOS ---
% times_repetidos(+Partidas)
times_repetidos([Partida | Resto]) :-
    Partida = partida(Mandante, Visitante, _, _, _),
    (   time_no_jogo(Mandante, Resto)
    ;   time_no_jogo(Visitante, Resto)
    ;   times_repetidos(Resto)
    ), !.

time_no_jogo(Time, [partida(M, V, _, _, _) | _]) :-
    (Time = M ; Time = V), !.
time_no_jogo(Time, [_ | Resto]) :-
    time_no_jogo(Time, Resto).

% --- 2. CONFLITO DE MANDO DE CAMPO ---
% Impede que dois times da mesma cidade joguem em casa.
checar_conflito(restricoes(_, false, _, _), _) :- !. % Se restrição = false, passa direto.
checar_conflito(restricoes(_, true, _, _), Partidas) :-
    cidades_mandantes(Partidas, Cidades),
    sem_duplicatas(Cidades).

cidades_mandantes([], []).
cidades_mandantes([partida(_, _, _, Cidade, _) | Resto], [Cidade | CidadesResto]) :-
    cidades_mandantes(Resto, CidadesResto).

sem_duplicatas([]).
sem_duplicatas([H | T]) :-
    \+ member(H, T),
    sem_duplicatas(T).

% --- 3. SEQUÊNCIA DE JOGOS (CASA/FORA) ---
checar_sequencia(_, [], _) :- !. % Histórico vazio, sempre passa
checar_sequencia(restricoes(_, _, MaxSeq, _), _, _) :- MaxSeq =< 0, !.
checar_sequencia(Config, Historico, Partidas) :-
    verificar_limite_lista(Config, Historico, Partidas).

verificar_limite_lista(_, _, []).
verificar_limite_lista(Config, Historico, [P | Ps]) :-
    verificar_limite(Config, Historico, P),
    verificar_limite_lista(Config, Historico, Ps).

verificar_limite(restricoes(_, _, MaxSeq, _), Historico, partida(Mandante, Visitante, _, _, _)) :-
    contar_sequencia(Mandante, casa, Historico, SeqM),
    contar_sequencia(Visitante, fora, Historico, SeqV),
    (SeqM + 1) =< MaxSeq,
    (SeqV + 1) =< MaxSeq.

contar_sequencia(_, _, [], 0) :- !.
contar_sequencia(Time, Local, [Rodada | Resto], Total) :-
    jogou_nesse_local(Time, Local, Rodada), !,
    contar_sequencia(Time, Local, Resto, SubTotal),
    Total is SubTotal + 1.
contar_sequencia(_, _, _, 0). % Se quebrou a sequência, zera.

jogou_nesse_local(Time, casa, Rodada) :-
    member(partida(Time, _, _, _, _), Rodada).
jogou_nesse_local(Time, fora, Rodada) :-
    member(partida(_, Time, _, _, _), Rodada).

% --- 4. GEOGRAFIA E CANSAÇO ACUMULADO ---
checar_geografia(restricoes(false, _, _, _), _, _, _) :- !.
checar_geografia(_, [], _, _) :- !.
checar_geografia(Config, Historico, Partidas, Cidades) :-
    % Puxamos o LimiteFadiga da Configuração
    Config = restricoes(_, _, _, LimiteFadiga),
    validar_fadiga_lista(LimiteFadiga, Historico, Partidas, Cidades).

validar_fadiga_lista(_, _, [], _).
validar_fadiga_lista(LimiteFadiga, Historico, [P | Ps], Cidades) :-
    validar_fadiga_time(LimiteFadiga, Historico, P, Cidades),
    validar_fadiga_lista(LimiteFadiga, Historico, Ps, Cidades).

validar_fadiga_time(LimiteFadiga, [RodadaAnterior | _], partida(time(_, CidOrigem), Visitante, _, _, _), Cidades) :-
    Visitante = time(_, CidDestino),
    obter_distancia(CidOrigem, CidDestino, Cidades, DistAtual),
    buscar_distancia_anterior(Visitante, RodadaAnterior, DistAnterior, Cidades),
    (DistAtual + DistAnterior) =< LimiteFadiga.

buscar_distancia_anterior(Time, Rodada, Distancia, Cidades) :-
    % Se encontrar o time como visitante na rodada anterior:
    member(partida(time(_, CidOrigemAnt), Time, _, _, _), Rodada), !,
    Time = time(_, CidDestinoAnt),
    obter_distancia(CidOrigemAnt, CidDestinoAnt, Cidades, Distancia).
% Se jogou em casa ou não achou, a distância de viagem foi zero:
buscar_distancia_anterior(_, _, 0, _).