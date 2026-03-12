
% Gera o turno completo com as funcoes auxiliares e recursivas
% Caso haja dificuldades em gerar os turnos, relaxa as restricoes

gerar_turno_completo(Config, QtdTimes, Estoque, Turno) :-
    MetaRodada is QtdTimes // 2,
    realizar_tentativa(Config, MetaRodada, Estoque, [], Turno), !.

gerar_turno_completo(Config, QtdTimes, Estoque, Turno) :-
    relaxar_restricao(Config, NovaConfig), 
    % Limite para nao entrar em loop infinito
    NovaConfig = restricoes(_,_,_, Limite),
    Limite < 10000
    gerar_turno_completo(NovaConfig, QtdTimes, Estoque, Turno).

% Passo recursivo para gerar o turno completo. Restricoes (config) é o conjunto de todas as restricoes (round_validator), Meta é a quantidade de times que irão
% jogar o campeonato dividido por 2, Estoque é a lista com todas as possibilidades de partidas e Turno é um turno do campeonato.

realizar_tentativa(_, _, [], _, []) :- !.

realizar_tentativa(Config, Meta, Estoque, Historico, [Rodada | ProximasRodadas]) :-
    % Tenta montar uma rodada
    gerar_rodada(Config, Meta, [], Estoque, Historico, Rodada, Sobra),

    % Se conseguiu, chama a si mesmo recursivamente adicionando a partida ao historico

    realizar_tentativa(Config, Meta, Estoque, [Rodada | Historico], ProximasRodadas).

% Gera a rodada passando as restricoes, a meta (n° times div 2), o estoque, escolhidos (acumula as partidas que passam nas restricoes), [P | Ps] é o 
% estoque, Historico é o historico (obviamente), Rodada é a saída e sobra é o restante das partidas que voltam pro estoque

gerar_rodada(_, 0, Escolhidos, Estoque, _, Escolhidos, Estoque) :- !.

gerar_rodada(Config, Meta, Escolhidos, [P | Ps], Historico, Rodada, Sobra) :-
    validar_rodada(Config, Historico, [P | Escolhidos]),
    NovaMeta is Meta - 1,
    gerar_rodada(Config, NovaMeta, [P | Escolhidos], Ps, Historico, Rodada, Sobra).


% Caso uma partida não passe, volta pro estoque (sobraresto)
gerar_rodada(Config, Meta, Escolhidos, [P | Ps], Hist, Rodada, [P | SobraResto]) :-
    gerar_rodada(Config, Meta, Escolhidos, Ps, Hist, Rodada, SobraResto).
