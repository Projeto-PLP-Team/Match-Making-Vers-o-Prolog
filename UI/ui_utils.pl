:- module(ui_utils, [
    limpar_tela/0,
    listar_numeros/2,
    listar_times/1,
    listar_cidades_nomes/1,
    listar_cidades_detalhado/1,
    exibir_campeonato/1,
    exibir_rodadas/2,
    exibir_partidas/1,
    exibir_partidas_com_indice/2,
    exibir_classificacao/1,
    exibir_distancias/1
]).

limpar_tela :- write('\e[H\e[2J').

listar_numeros(N, Max) :-
    N > Max, !.
listar_numeros(N, Max) :-
    format(' [~w]', [N]),
    N1 is N + 1,
    listar_numeros(N1, Max),
    (N mod 5 =:= 0 -> nl ; true).

listar_times([]).
listar_times([time(N, C) | T]) :-
    format('  - ~w (~w)~n', [N, C]),
    listar_times(T).

listar_cidades_nomes([]).
listar_cidades_nomes([cidade(N, _, _) | T]) :-
    format('  - ~w~n', [N]),
    listar_cidades_nomes(T).

listar_cidades_detalhado([]).
listar_cidades_detalhado([cidade(N, Lat, Lon) | T]) :-
    format('  - ~w (Lat: ~w, Lon: ~w)~n', [N, Lat, Lon]),
    listar_cidades_detalhado(T).

exibir_campeonato(Turno) :-
    exibir_rodadas(Turno, 1).

exibir_rodadas([], _).
exibir_rodadas([Rodada | Resto], N) :-
    format('  RODADA ~w:~n', [N]),
    exibir_partidas(Rodada),
    N1 is N + 1,
    exibir_rodadas(Resto, N1).

exibir_partidas([]).
exibir_partidas([partida(time(M, _), time(V, _), _, Local, Res) | T]) :-
    format('    ~w vs ~w (Local: ~w) - Status: ~w~n', [M, V, Local, Res]),
    exibir_partidas(T).

exibir_partidas_com_indice([], _).
exibir_partidas_com_indice([partida(time(M, _), time(V, _), _, _, Res) | T], I) :-
    format('  [~w] ~w vs ~w (Status: ~w)~n', [I, M, V, Res]),
    I1 is I + 1,
    exibir_partidas_com_indice(T, I1).

exibir_classificacao(Class) :-
    writeln('Pos | Time            | Pts | V | E | D | GP | GC | SG'),
    writeln('-------------------------------------------------------'),
    exibir_linhas_class(Class, 1).

exibir_linhas_class([], _).
exibir_linhas_class([stats(time(Nome, _), Pts, V, E, D, GP, GC, SG) | T], Pos) :-
    format('~w°  | ~-15w | ~w  | ~w | ~w | ~w | ~w  | ~w  | ~w~n', [Pos, Nome, Pts, V, E, D, GP, GC, SG]),
    Pos1 is Pos + 1,
    exibir_linhas_class(T, Pos1).

exibir_distancias([]).
exibir_distancias([dist_time(time(Nome, _), KM) | T]) :-
    format('  - ~-15w : ~w KM~n', [Nome, KM]),
    exibir_distancias(T).
