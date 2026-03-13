:- module(round_generator, [
    gerar_campeonato/5
]).

:- use_module('../Validation/round_validator').
:- use_module('../Types/estado').

% PONTO DE ENTRADA

gerar_campeonato(pontos_corridos, Config, Times, Cidades, Campeonato) :-
    gerar_pontos_corridos(Config, Times, Cidades, Campeonato).

gerar_campeonato(mata_mata, _Config, Times, _Cidades, [Rodada]) :-
    random_permutation(Times, Shuffled),
    montar_confrontos(Shuffled, Rodada).

gerar_campeonato(grupos_mata_mata, Config, Times, Cidades, Campeonato) :-
    gerar_grupos_mata_mata(Config, Times, Cidades, Campeonato).


% PONTOS CORRIDOS
%
% Passo a passo:
%   1. Gerar estoque completo: todas as combinacoes de todos os times (A vs B e B vs A)
%      O backtracking decide qual usar, garantindo que cada par jogue exatamente uma vez no turno via par_ja_jogou.
%   2. Backtracking -> monta N-1 rodadas respeitando as restrições (geração do turno).
%   3. Returno -> inverte o turno gerado.

gerar_pontos_corridos(Config, Times, Cidades, TurnoReturno) :-
    length(Times, N),
    ( N mod 2 =\= 0
    -> TimesComBye = [time('BYE', 'NENHUMA') | Times]
    ;  TimesComBye = Times
    ),
    gerar_estoque_completo(TimesComBye, EstoqueCompleto),
    random_permutation(EstoqueCompleto, Estoque),
    length(TimesComBye, QtdTimes),
    NumRodadas is QtdTimes - 1,
    MetaRodada is QtdTimes // 2,
    gerar_turno_completo(Config, NumRodadas, MetaRodada, Estoque, [], Cidades, Turno),
    gerar_returno(Turno, Returno),
    append(Turno, Returno, TurnoReturno).

% Gera todas as partidas em ambas orientações, sem BYE.
gerar_estoque_completo(Times, Estoque) :-
    findall(
        partida(M, V, data(0,0,0), Loc, pendente),
        (
            member(M, Times), member(V, Times),
            M \= V,
            \+ M = time('BYE', _),
            \+ V = time('BYE', _),
            M = time(_, Loc)
        ),
        Estoque
    ).

% BACKTRACKING COM RESTRIÇÕES
%
% NumRodadas controla quantas rodadas ainda precisam ser geradas.
% Quando chega a 0, o turno está completo.

gerar_turno_completo(Config, NumRodadas, MetaRodada, Estoque, Historico, Cidades, Turno) :-
    realizar_tentativa(Config, NumRodadas, MetaRodada, Estoque, Historico, Cidades, Turno), !.
gerar_turno_completo(Config, NumRodadas, MetaRodada, Estoque, Historico, Cidades, Turno) :-
    relaxar_restricao(Config, NovaConfig),
    NovaConfig = restricoes(_, _, _, Limite),
    Limite < 10000,
    gerar_turno_completo(NovaConfig, NumRodadas, MetaRodada, Estoque, Historico, Cidades, Turno).

% Caso base: todas as rodadas geradas.
realizar_tentativa(_, 0, _, _, _, _, []) :- !.
% Gera uma rodada e recursa para as próximas.
realizar_tentativa(Config, NumRodadas, Meta, Estoque, Historico, Cidades, [Rodada | ProximasRodadas]) :-
    NumRodadas > 0,
    gerar_rodada(Config, Meta, [], Estoque, Historico, Cidades, Rodada, Sobra),
    NumRodadas1 is NumRodadas - 1,
    realizar_tentativa(Config, NumRodadas1, Meta, Sobra, [Rodada | Historico], Cidades, ProximasRodadas).

% Caso base: meta de partidas na rodada atingida.
gerar_rodada(_, 0, Escolhidos, Estoque, _, _, Escolhidos, Estoque) :- !.
% Tenta incluir P: par não jogou ainda + passa na validação.
gerar_rodada(Config, Meta, Escolhidos, [P | Ps], Historico, Cidades, Rodada, Sobra) :-
    P = partida(M, V, _, _, _),
    \+ par_ja_jogou(M, V, Historico),
    \+ par_ja_na_rodada(M, V, Escolhidos),
    validar_rodada(Config, Historico, [P | Escolhidos], Cidades),
    NovaMeta is Meta - 1,
    gerar_rodada(Config, NovaMeta, [P | Escolhidos], Ps, Historico, Cidades, Rodada, Sobra).
% P não passou: descarta para essa rodada, volta ao estoque como Sobra.
gerar_rodada(Config, Meta, Escolhidos, [P | Ps], Historico, Cidades, Rodada, [P | SobraResto]) :-
    gerar_rodada(Config, Meta, Escolhidos, Ps, Historico, Cidades, Rodada, SobraResto).

% par_ja_jogou(+M, +V, +Historico)
% Verdadeiro se M vs V ou V vs M já aparecem no histórico de rodadas.
par_ja_jogou(M, V, Historico) :-
    flatten(Historico, Todas),
    ( member(partida(M, V, _, _, _), Todas)
    ; member(partida(V, M, _, _, _), Todas)
    ).

% par_ja_na_rodada(+M, +V, +Escolhidos)
% Evita repetir o par dentro da mesma rodada.
par_ja_na_rodada(M, V, Escolhidos) :-
    ( member(partida(M, V, _, _, _), Escolhidos)
    ; member(partida(V, M, _, _, _), Escolhidos)
    ).


% RETURNO

gerar_returno([], []).
gerar_returno([Rodada | Resto], [RodadaInvertida | RestoInvertido]) :-
    inverter_rodada(Rodada, RodadaInvertida),
    gerar_returno(Resto, RestoInvertido).

inverter_rodada([], []).
inverter_rodada(
    [partida(Mandante, Visitante, Data, _, _) | T],
    [partida(Visitante, Mandante, Data, NovoLoc, pendente) | Resto]
) :-
    Visitante = time(_, NovoLoc),
    inverter_rodada(T, Resto).


% MATA-MATA

montar_confrontos([], []).
montar_confrontos([_], []).
montar_confrontos([T1, T2 | Resto], [partida(T1, T2, data(0,0,0), L, pendente) | Proximas]) :-
    T1 = time(_, L),
    montar_confrontos(Resto, Proximas).

% GRUPOS + MATA-MATA

gerar_grupos_mata_mata(Config, Times, Cidades, Campeonato) :-
    length(Times, Total),
    ( Total < 4 -> NumGrupos = 1 ; NumGrupos = 4 ),
    random_permutation(Times, Shuffled),
    dividir_em_grupos(Shuffled, NumGrupos, Grupos),
    maplist(gerar_grupo(Config, Cidades), Grupos, TurnosGrupos),
    flatten(TurnosGrupos, Campeonato).

gerar_grupo(Config, Cidades, Grupo, Turno) :-
    gerar_pontos_corridos(Config, Grupo, Cidades, Turno).

dividir_em_grupos([], _, []).
dividir_em_grupos(L, 1, [L]) :- !.
dividir_em_grupos(L, N, [Grupo | Resto]) :-
    length(L, Total),
    Size is Total // N,
    ( Size < 1 -> ActualSize = 1 ; ActualSize = Size ),
    split_at(ActualSize, L, Grupo, Sobra),
    N1 is N - 1,
    dividir_em_grupos(Sobra, N1, Resto).


% UTILITÁRIOS

rotacionar([H | T], Rotacionado) :-
    append(T, [H], Rotacionado).

split_at(0, L, [], L) :- !.
split_at(N, [H|T], [H|L1], L2) :-
    N > 0,
    N1 is N - 1,
    split_at(N1, T, L1, L2).