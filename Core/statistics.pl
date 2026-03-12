:- module(statistics, [
    calcular_classificacao/2,
    calcular_distancias/3,
    vencedor/2
]).

:- use_module('../Geography/distance').

% --- CLASSIFICAÇÃO ---
% calcular_classificacao(+Campeonato, -Classificacao)
% Classificacao é uma lista de stats(Time, Pts, V, E, D, GP, GC, SG)
calcular_classificacao(nenhum, []) :- !.
calcular_classificacao(Turno, Classificacao) :-
    flatten(Turno, TodasPartidas),
    extrair_times(TodasPartidas, Times),
    maplist(processar_time(TodasPartidas), Times, Stats),
    sort(2, @>=, Stats, StatsOrdenados), % Ordena por pontos
    Classificacao = StatsOrdenados.

extrair_times(Partidas, Times) :-
    findall(T, (member(partida(T, _, _, _, _), Partidas), T \= time('BYE', _)), T1),
    findall(T, (member(partida(_, T, _, _, _), Partidas), T \= time('BYE', _)), T2),
    append(T1, T2, T3),
    sort(T3, Times).

processar_time(Partidas, Time, stats(Time, Pts, V, E, D, GP, GC, SG)) :-
    findall(res(G1, G2), (member(partida(Time, Opp, _, _, gols(G1, G2)), Partidas), Opp \= time('BYE', _)), ResCasa),
    findall(res(G2, G1), (member(partida(Opp, Time, _, _, gols(G1, G2)), Partidas), Opp \= time('BYE', _)), ResFora),
    append(ResCasa, ResFora, TodosRes),
    contar_stats(TodosRes, Pts, V, E, D, GP, GC),
    SG is GP - GC.

contar_stats([], 0, 0, 0, 0, 0, 0).
contar_stats([res(GP1, GC1) | T], Pts, V, E, D, GP, GC) :-
    contar_stats(T, P1, V1, E1, D1, GP_Resto, GC_Resto),
    GP is GP1 + GP_Resto,
    GC is GC1 + GC_Resto,
    (GP1 > GC1 -> Pts is P1 + 3, V is V1 + 1, E = E1, D = D1 ;
     GP1 < GC1 -> Pts is P1, V = V1, E = E1, D is D1 + 1 ;
     Pts is P1 + 1, V = V1, E is E1 + 1, D = D1).

% --- DISTÂNCIAS ---
% calcular_distancias(+Campeonato, +Cidades, -Distancias)
% Distancias é uma lista de dist_time(Time, TotalKM)
calcular_distancias(nenhum, _, []) :- !.
calcular_distancias(Turno, Cidades, Distancias) :-
    extrair_times_sem_bye(Turno, Times),
    maplist(distancia_por_time(Turno, Cidades), Times, Distancias).

extrair_times_sem_bye(Turno, Times) :-
    flatten(Turno, Todas),
    findall(T, (member(partida(T, _, _, _, _), Todas), T \= time('BYE', _)), T1),
    findall(T, (member(partida(_, T, _, _, _), Todas), T \= time('BYE', _)), T2),
    append(T1, T2, T3),
    sort(T3, Times).

distancia_por_time(Turno, Cidades, dist_time(Time, TotalKM)) :-
    Time = time(_, CidadeBase),
    calcular_viagens(Turno, Time, CidadeBase, Cidades, TotalKM).

calcular_viagens([], _, _, _, 0).
% Na rodada, o time pode jogar em casa ou fora
calcular_viagens([Rodada | Resto], Time, CidadeAtual, Cidades, Total) :-
    (member(partida(Time, _Visitante, _, _, _), Rodada) ->
        % Joga em casa: distância é 0 até o estádio (simplificado)
        ProximaCidade = CidadeAtual, Dist = 0
    ; member(partida(Mandante, Time, _, _, _), Rodada) ->
        % Joga fora: viaja da CidadeAtual para a cidade do Mandante
        Mandante = time(_, CidadeMandante),
        obter_distancia(CidadeAtual, CidadeMandante, Cidades, Dist),
        ProximaCidade = CidadeMandante
    ;
        % Não jogou (BYE): fica onde estava
        ProximaCidade = CidadeAtual, Dist = 0
    ),
    calcular_viagens(Resto, Time, ProximaCidade, Cidades, SubTotal),
    Total is Dist + SubTotal.

% --- VENCEDOR ---
vencedor([], time('Nenhum', 'Nenhum')) :- !.
vencedor(Classificacao, Vencedor) :-
    Classificacao = [stats(Vencedor, _, _, _, _, _, _, _) | _].
