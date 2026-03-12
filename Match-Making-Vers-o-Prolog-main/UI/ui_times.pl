:- module(ui_times, [
    tela_gerenciamento_times/2
]).

:- use_module('../Types/estado').
:- use_module('ui_utils').
:- use_module('ui_cidades').

tela_gerenciamento_times(Estado, NovoEstado) :-
    limpar_tela,
    writeln('--- Gerenciamento de Times ---'),
    writeln('[1] Cadastrar Novo Time'),
    writeln('[2] Listar Times Cadastrados'),
    writeln('[3] Excluir Time'),
    writeln('[0] Voltar'),
    write('Escolha: '),
    read_line_to_string(user_input, Op),
    processar_gerenciamento_times(Op, Estado, NovoEstado).

processar_gerenciamento_times("1", Estado, NovoEstado) :-
    tela_cadastro_time(Estado, NovoEstado).
processar_gerenciamento_times("2", Estado, Estado) :-
    Estado = estado_sistema(Equipes, _, _, _, _),
    writeln('\nTimes Cadastrados:'),
    (Equipes = [] -> writeln('  Nenhum time cadastrado.') ; listar_times(Equipes)),
    writeln('\nPressione Enter para continuar...'),
    read_line_to_string(user_input, _).
processar_gerenciamento_times("3", Estado, NovoEstado) :-
    writeln('\n--- Excluir Time ---'),
    write('Nome do time a excluir: '), read_line_to_string(user_input, NomeStr),
    atom_string(Nome, NomeStr),
    excluir_time(Nome, Estado, NovoEstado).
processar_gerenciamento_times("0", Estado, Estado).
processar_gerenciamento_times(_, Estado, NovoEstado) :-
    Estado = estado_sistema(E, C, Camp, Config, _),
    NovoEstado = estado_sistema(E, C, Camp, Config, "Opcao invalida no gerenciamento de times.").

tela_cadastro_time(Estado, NovoEstado) :-
    writeln('\n--- Cadastro de Time ---'),
    write('Nome do Time: '), read_line_to_string(user_input, NomeStr),
    atom_string(Nome, NomeStr),
    writeln('Cidades Disponiveis:'),
    Estado = estado_sistema(_, CidadesAdicionais, _, _, _),
    listar_cidades_disponiveis(CidadesAdicionais),
    write('Cidade/Estado do Time: '), read_line_to_string(user_input, CidStr),
    atom_string(Cidade, CidStr),
    adicionar_time(time(Nome, Cidade), Estado, NovoEstado).
tela_cadastro_time(Estado, NovoEstado) :-
    Estado = estado_sistema(E, C, Camp, Config, _),
    NovoEstado = estado_sistema(E, C, Camp, Config, "Erro ao cadastrar time!").
