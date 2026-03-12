

% Gerar estoque de partidas

gerar_estoque(Times, Estoque) :-
    findall (
        PartidaCompleta,
        (
            member(M, Times),
            member(V, Times),
            M \= V,
            criar_partida(M, V, PartidaCompleta)
        ),
        Estoque
    ).

    
% Cria as partidas com base no estoque
% partida (mandante, visitante, data(int,int,int), local)
% Como prolog trabalha com unificacao, fica faltando apenas a cidade, por isso, buscamos a cidade do time que é usado como entrada (mandante)

criar_partida(Time1, Time2, partida(Time1, Time2, data(0,0,0), Cidade)) :-
    time(Time1, Cidade).

