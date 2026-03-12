:- module(ui_campeonato, [
    tela_gerenciamento_campeonato/2
]).

:- use_module('../Types/estado').
:- use_module('../Core/round_generator').
:- use_module('../Core/statistics').
:- use_module('ui_utils').

tela_gerenciamento_campeonato(Estado, NovoEstado) :-
    limpar_tela,
    writeln('--- Gerenciamento de Campeonato ---'),
    writeln('[1] Gerar Novo Campeonato'),
    writeln('[2] Visualizar Calendario'),
    writeln('[3] Lancar Resultados'),
    writeln('[4] Classificacao Atual'),
    writeln('[5] Finalizar Campeonato'),
    writeln('[6] Excluir Campeonato Atual'),
    writeln('[0] Voltar'),
    write('Escolha: '),
    read_line_to_string(user_input, Op),
    processar_gerenciamento(Op, Estado, NovoEstado).

processar_gerenciamento("1", Estado, NovoEstado) :-
    tela_gerar_campeonato(Estado, NovoEstado).
processar_gerenciamento("2", Estado, Estado) :-
    Estado = estado_sistema(_, _, Camp, _, _),
    (Camp = nenhum -> writeln('\nNenhum campeonato gerado.') ; exibir_campeonato(Camp)),
    writeln('\nPressione Enter para continuar...'),
    read_line_to_string(user_input, _).
processar_gerenciamento("3", Estado, NovoEstado) :-
    tela_lancar_resultados(Estado, NovoEstado).
processar_gerenciamento("4", Estado, Estado) :-
    Estado = estado_sistema(_, _, Camp, _, _),
    (Camp = nenhum -> writeln('\nNenhum campeonato em curso.') ; 
        calcular_classificacao(Camp, Class),
        exibir_classificacao(Class)),
    writeln('\nPressione Enter para continuar...'),
    read_line_to_string(user_input, _).
processar_gerenciamento("5", Estado, NovoEstado) :-
    tela_finalizar_campeonato(Estado, NovoEstado).
processar_gerenciamento("6", Estado, NovoEstado) :-
    Estado = estado_sistema(E, C, _, Config, _),
    NovoEstado = estado_sistema(E, C, nenhum, Config, "Campeonato excluido com sucesso!").
processar_gerenciamento("0", Estado, Estado).
processar_gerenciamento(_, Estado, NovoEstado) :-
    Estado = estado_sistema(E, C, Camp, Config, _),
    NovoEstado = estado_sistema(E, C, Camp, Config, "Opcao invalida no gerenciamento.").

tela_gerar_campeonato(Estado, NovoEstado) :-
    Estado = estado_sistema(Equipes, Cidades, _, Config, _),
    length(Equipes, Qtd),
    (Qtd < 2 -> 
        NovoEstado = estado_sistema(Equipes, Cidades, nenhum, Config, "Cadastre pelo menos 2 times!")
    ; 
        write('Quantidade de times no campeonato: '),
        read_line_to_string(user_input, QtdStr),
        (number_string(QtdSel, QtdStr), QtdSel >= 2, QtdSel =< Qtd ->
            writeln('\n--- Selecione os Times ---'),
            listar_times_com_indice(Equipes, 1),
            selecionar_times(QtdSel, Equipes, [], Selecionados),
            reverse(Selecionados, TimesSelecionados),
            writeln('\n--- Selecione o Tipo de Campeonato ---'),
            writeln('[1] Pontos Corridos (Turno e Returno)'),
            writeln('[2] Mata-Mata'),
            writeln('[3] Grupos + Mata-Mata'),
            write('Escolha: '),
            read_line_to_string(user_input, TipoStr),
            mapear_tipo(TipoStr, Tipo),
            writeln('Gerando campeonato...'),
            (gerar_campeonato(Tipo, Config, TimesSelecionados, Cidades, Turno) ->
                format(string(Msg), "Campeonato (~w) gerado com sucesso!", [Tipo]),
                NovoEstado = estado_sistema(Equipes, Cidades, Turno, Config, Msg)
            ;
                NovoEstado = estado_sistema(Equipes, Cidades, nenhum, Config, "Falha ao gerar campeonato.")
            )
        ;
            NovoEstado = estado_sistema(Equipes, Cidades, nenhum, Config, "Quantidade invalida de times.")
        )
    ).

mapear_tipo("1", pontos_corridos).
mapear_tipo("2", mata_mata).
mapear_tipo("3", grupos_mata_mata).
mapear_tipo(_, pontos_corridos).

listar_times_com_indice([], _).
listar_times_com_indice([time(N, C) | T], I) :-
    format('  [~w] ~w (~w)~n', [I, N, C]),
    I1 is I + 1,
    listar_times_com_indice(T, I1).

selecionar_times(0, _, Selecionados, Selecionados).
selecionar_times(N, Disponiveis, Acc, Selecionados) :-
    N > 0,
    write('Escolha o numero do time: '),
    read_line_to_string(user_input, IndStr),
    (number_string(Ind, IndStr), nth1(Ind, Disponiveis, Time) ->
        select(Time, Disponiveis, Restantes),
        N1 is N - 1,
        selecionar_times(N1, Restantes, [Time | Acc], Selecionados)
    ;
        writeln('Opcao invalida. Tente novamente.'),
        selecionar_times(N, Disponiveis, Acc, Selecionados)
    ).

tela_lancar_resultados(Estado, NovoEstado) :-
    Estado = estado_sistema(Equipes, Cidades, Camp, Config, _),
    (Camp = nenhum -> NovoEstado = Estado, writeln('Nenhum campeonato gerado.') ;
        writeln('\n--- Lancar Resultados ---'),
        writeln('Selecione a Rodada:'),
        length(Camp, NumRod),
        listar_numeros(1, NumRod),
        write('Rodada: '), read_line_to_string(user_input, RStr),
        number_string(RNum, RStr),
        nth1(RNum, Camp, Rodada),
        exibir_partidas_com_indice(Rodada, 1),
        write('Selecione a Partida: '), read_line_to_string(user_input, PStr),
        number_string(PNum, PStr),
        write('Gols Mandante: '), read_line_to_string(user_input, GMStr),
        number_string(GM, GMStr),
        write('Gols Visitante: '), read_line_to_string(user_input, GVStr),
        number_string(GV, GVStr),
        atualizar_resultado_camp(Camp, RNum, PNum, gols(GM, GV), NovoCamp),
        NovoEstado = estado_sistema(Equipes, Cidades, NovoCamp, Config, "Resultado lancado!")
    ).

atualizar_resultado_camp(Camp, RNum, PNum, Res, NovoCamp) :-
    nth1(RNum, Camp, Rodada, RestoRod),
    atualizar_partida_na_rodada(Rodada, PNum, Res, NovaRodada),
    nth1(RNum, NovoCamp, NovaRodada, RestoRod).

atualizar_partida_na_rodada(Rodada, PNum, Res, NovaRodada) :-
    nth1(PNum, Rodada, Partida, RestoPart),
    Partida = partida(M, V, D, L, _),
    NovaPartida = partida(M, V, D, L, Res),
    nth1(PNum, NovaRodada, NovaPartida, RestoPart).

tela_finalizar_campeonato(Estado, NovoEstado) :-
    Estado = estado_sistema(Equipes, Cidades, Camp, Config, _),
    (Camp = nenhum -> NovoEstado = Estado, writeln('Nenhum campeonato para finalizar.') ;
        limpar_tela,
        writeln('========================================'),
        writeln('       FINALIZACAO DO CAMPEONATO'),
        writeln('========================================'),
        calcular_classificacao(Camp, Class),
        vencedor(Class, Vencedor),
        Vencedor = time(NomeV, _),
        format('*** O GRANDE CAMPEAO EH: ~w ***~n~n', [NomeV]),
        exibir_classificacao(Class),
        writeln('\n--- Estatisticas de Viagem (KM) ---'),
        calcular_distancias(Camp, Cidades, Dists),
        exibir_distancias(Dists),
        writeln('\nPressione Enter para encerrar o campeonato e voltar...'),
        read_line_to_string(user_input, _),
        NovoEstado = estado_sistema(Equipes, Cidades, nenhum, Config, "Campeonato finalizado!")
    ).
