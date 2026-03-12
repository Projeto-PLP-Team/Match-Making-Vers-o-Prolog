:- use_module('Types/estado').
:- use_module('Geography/distance').
:- use_module('Core/mock_data').
:- use_module('UI/ui_utils').
:- use_module('UI/ui_cidades').
:- use_module('UI/ui_times').
:- use_module('UI/ui_campeonato').
:- use_module('UI/ui_configuracoes').

% --- PONTO DE ENTRADA ---
main :-
    estado_inicial(Estado),
    menu_principal(Estado).

% --- LOOP PRINCIPAL ---
menu_principal(Estado) :-
    limpar_tela,
    Estado = estado_sistema(_, _, _, _, Mensagem),
    writeln('========================================'),
    writeln('       MATCH-MAKING PROLOG v1.0'),
    writeln('========================================'),
    format('Mensagem: ~w~n', [Mensagem]),
    writeln('----------------------------------------'),
    writeln('[1] Gerenciar Cidades'),
    writeln('[2] Gerenciar Times'),
    writeln('[3] Gerenciar Campeonato'),
    writeln('[4] Visualizar Dados'),
    writeln('[5] Configuracoes'),
    writeln('[6] Carregar Serie A (Mock)'),
    writeln('[0] Sair'),
    writeln('----------------------------------------'),
    write('Escolha uma opcao: '),
    read_line_to_string(user_input, OpcaoStr),
    processar_opcao(OpcaoStr, Estado).

% --- PROCESSAMENTO DE OPÇÕES ---
processar_opcao("1", Estado) :-
    tela_gerenciamento_cidades(Estado, NovoEstado),
    menu_principal(NovoEstado).

processar_opcao("2", Estado) :-
    tela_gerenciamento_times(Estado, NovoEstado),
    menu_principal(NovoEstado).

processar_opcao("3", Estado) :-
    tela_gerenciamento_campeonato(Estado, NovoEstado),
    menu_principal(NovoEstado).

processar_opcao("4", Estado) :-
    tela_visualizar_dados(Estado),
    menu_principal(Estado).

processar_opcao("5", Estado) :-
    tela_configuracoes(Estado, NovoEstado),
    menu_principal(NovoEstado).

processar_opcao("6", Estado) :-
    carregar_serie_a(Estado, NovoEstado),
    menu_principal(NovoEstado).

processar_opcao("0", _) :-
    writeln('Saindo... Ate logo!').

processar_opcao(_, Estado) :-
    Estado = estado_sistema(E, C, Camp, Config, _),
    NovoEstado = estado_sistema(E, C, Camp, Config, "Opcao invalida!"),
    menu_principal(NovoEstado).

% Visualização de Dados Geral
tela_visualizar_dados(Estado) :-
    limpar_tela,
    Estado = estado_sistema(Equipes, Cidades, _, _, _),
    writeln('\n--- Dados do Sistema ---'),
    writeln('Times:'),
    (Equipes = [] -> writeln('  Nenhum time cadastrado.') ; listar_times(Equipes)),
    writeln('\nCidades (Mock + Adicionais):'),
    todas_cidades(Cidades, Todas),
    (Todas = [] -> writeln('  Nenhuma cidade encontrada.') ; listar_cidades_detalhado(Todas)),
    writeln('\nPressione Enter para voltar...'),
    read_line_to_string(user_input, _).
