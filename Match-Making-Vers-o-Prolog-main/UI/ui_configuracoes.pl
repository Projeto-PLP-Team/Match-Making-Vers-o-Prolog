:- module(ui_configuracoes, [
    tela_configuracoes/2
]).

:- use_module('../Types/estado').
:- use_module('ui_utils').

tela_configuracoes(Estado, NovoEstado) :-
    Estado = estado_sistema(_, _, _, restricoes(Geo, Conf, Seq, Fadiga), _),
    writeln('\n--- Configuracoes de Restricoes ---'),
    format('[1] Restricao Geografica: ~w~n', [Geo]),
    format('[2] Conflito de Mando: ~w~n', [Conf]),
    format('[3] Maxima Sequencia (Casa/Fora): ~w~n', [Seq]),
    format('[4] Limite de Fadiga (KM): ~w~n', [Fadiga]),
    writeln('[0] Voltar'),
    write('Escolha para alterar: '),
    read_line_to_string(user_input, Op),
    alterar_config(Op, Estado, NovoEstado).

alterar_config("1", estado_sistema(E, C, Camp, restricoes(Geo, Conf, Seq, Fad), _), Novo) :-
    (Geo = true -> NGeo = false ; NGeo = true),
    Novo = estado_sistema(E, C, Camp, restricoes(NGeo, Conf, Seq, Fad), "Restricao geografica alterada.").
alterar_config("2", estado_sistema(E, C, Camp, restricoes(Geo, Conf, Seq, Fad), _), Novo) :-
    (Conf = true -> NConf = false ; NConf = true),
    Novo = estado_sistema(E, C, Camp, restricoes(Geo, NConf, Seq, Fad), "Conflito de mando alterado.").
alterar_config("3", estado_sistema(E, C, Camp, restricoes(Geo, Conf, _, Fad), _), Novo) :-
    write('Novo valor para sequencia maxima: '), read_line_to_string(user_input, S),
    number_string(NS, S),
    Novo = estado_sistema(E, C, Camp, restricoes(Geo, Conf, NS, Fad), "Sequencia alterada.").
alterar_config("4", estado_sistema(E, C, Camp, restricoes(Geo, Conf, Seq, _), _), Novo) :-
    write('Novo valor para limite de fadiga (KM): '), read_line_to_string(user_input, F),
    number_string(NF, F),
    Novo = estado_sistema(E, C, Camp, restricoes(Geo, Conf, Seq, NF), "Limite de fadiga alterado.").
alterar_config("0", Estado, Estado).
alterar_config(_, Estado, Novo) :-
    Estado = estado_sistema(E, C, Camp, Config, _),
    Novo = estado_sistema(E, C, Camp, Config, "Opcao de configuracao invalida.").
