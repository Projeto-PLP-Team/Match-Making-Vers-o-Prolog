

:- module(match_generator, [
    gerar_estoque/2
]).

% Gerar estoque de partidas
% Times é uma lista de time(Nome, Cidade)

gerar_estoque(Times, Estoque) :-
    findall(
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

criar_partida(time(Nome1, Cidade1), time(Nome2, Cidade2), partida(time(Nome1, Cidade1), time(Nome2, Cidade2), data(0,0,0), Cidade1)).

