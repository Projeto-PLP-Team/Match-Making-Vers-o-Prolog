:- module(round_generator, [
    gerar_campeonato/5
]).

:- use_module('../Validation/round_validator').
:- use_module('../Types/estado').

% --- PONTO DE ENTRADA PRINCIPAL ---
% gerar_campeonato(+Tipo, +Config, +Times, +Cidades, -Campeonato)
gerar_campeonato(pontos_corridos, Config, Times, Cidades, Campeonato) :-
    gerar_pontos_corridos(Config, Times, Cidades, Campeonato).

gerar_campeonato(mata_mata, Config, Times, Cidades, Campeonato) :-
    gerar_mata_mata(Config, Times, Cidades, Campeonato).

gerar_campeonato(grupos_mata_mata, Config, Times, Cidades, Campeonato) :-
    gerar_grupos_mata_mata(Config, Times, Cidades, Campeonato).

% --- 1. PONTOS CORRIDOS (Circle Method) ---
gerar_pontos_corridos(_Config, Times, _Cidades, TurnoReturno) :-
    length(Times, N),
    (N mod 2 =\= 0 -> TimesComBye = [time('BYE', 'NENHUMA') | Times] ; TimesComBye = Times),
    length(TimesComBye, TotalN),
    NumRodadas is TotalN - 1,
    TimesComBye = [Fixo | Rotativos],
    gerar_rodadas_circle(NumRodadas, Fixo, Rotativos, [], Turno),
    gerar_returno(Turno, Returno),
    append(Turno, Returno, TurnoReturno).

% Overload maplist to handle BYE filtering
criar_partidas_filtradas([], [], []).
criar_partidas_filtradas([T1|R1], [T2|R2], Partidas) :-
    (T1 = time('BYE', _) ; T2 = time('BYE', _)), !,
    criar_partidas_filtradas(R1, R2, Partidas).
criar_partidas_filtradas([T1|R1], [T2|R2], [partida(T1, T2, data(0,0,0), Loc, pendente) | Resto]) :-
    T1 = time(_, Loc),
    criar_partidas_filtradas(R1, R2, Resto).

% Refined version of montar_rodada_circle_simples
montar_rodada_circle_simples_v2(Fixo, Rotativos, Rodada) :-
    length(Rotativos, L),
    Half is L // 2,
    split_at(Half, Rotativos, Top, [B1 | BRest]),
    reverse(BRest, RevBRest),
    ( (Fixo = time('BYE', _) ; B1 = time('BYE', _)) -> 
        PartidasIniciais = [] 
    ; 
        Fixo = time(_, Loc), PartidasIniciais = [partida(Fixo, B1, data(0,0,0), Loc, pendente)]
    ),
    criar_partidas_filtradas(Top, RevBRest, PartidasT),
    append(PartidasIniciais, PartidasT, Rodada).

gerar_rodadas_circle(0, _, _, Rodadas, Rodadas) :- !.
gerar_rodadas_circle(N, Fixo, Rotativos, Acc, Rodadas) :-
    montar_rodada_circle_simples_v2(Fixo, Rotativos, Rodada),
    rotacionar(Rotativos, NovosRotativos),
    N1 is N - 1,
    append(Acc, [Rodada], NovoAcc),
    gerar_rodadas_circle(N1, Fixo, NovosRotativos, NovoAcc, Rodadas).

rotacionar([H | T], Rotacionado) :-
    append(T, [H], Rotacionado).

split_at(0, L, [], L) :- !.
split_at(N, [H|T], [H|L1], L2) :- N > 0, N1 is N - 1, split_at(N1, T, L1, L2).

gerar_returno([], []).
gerar_returno([Rodada | Resto], [RodadaInvertida | RestoInvertido]) :-
    inverter_rodada(Rodada, RodadaInvertida),
    gerar_returno(Resto, RestoInvertido).

inverter_rodada([], []).
inverter_rodada([partida(M, V, D, _, _) | T], [partida(V, M, D, Loc, pendente) | Resto]) :-
    V = time(_, Loc),
    inverter_rodada(T, Resto).

% --- 2. MATA-MATA ---
gerar_mata_mata(_, Times, _, [Rodada]) :-
    random_permutation(Times, Shuffled),
    montar_confrontos(Shuffled, Rodada).

montar_confrontos([], []).
montar_confrontos([T1, T2 | Resto], [partida(T1, T2, data(0,0,0), L, pendente) | Proximas]) :-
    T1 = time(_, L),
    montar_confrontos(Resto, Proximas).
montar_confrontos([_], []).

% --- 3. GRUPOS + MATA-MATA ---
gerar_grupos_mata_mata(Config, Times, Cidades, Campeonato) :-
    length(Times, Total),
    (Total < 4 -> NumGrupos = 1 ; NumGrupos = 4),
    random_permutation(Times, Shuffled),
    dividir_em_grupos(Shuffled, NumGrupos, Grupos),
    maplist(gerar_pontos_corridos_simples(Config, Cidades), Grupos, TurnosGrupos),
    flatten(TurnosGrupos, Campeonato).

gerar_pontos_corridos_simples(Config, Cidades, Grupo, Turno) :-
    gerar_pontos_corridos(Config, Grupo, Cidades, Turno).

dividir_em_grupos([], _, []).
dividir_em_grupos(L, 1, [L]) :- !.
dividir_em_grupos(L, N, [Grupo | Resto]) :-
    length(L, Total),
    Size is Total // N,
    (Size < 1 -> ActualSize = 1 ; ActualSize = Size),
    split_at(ActualSize, L, Grupo, Sobra),
    N1 is N - 1,
    dividir_em_grupos(Sobra, N1, Resto).
