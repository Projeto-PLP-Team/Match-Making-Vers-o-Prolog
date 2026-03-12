:- module(ui_cidades, [
    tela_gerenciamento_cidades/2,
    listar_cidades_disponiveis/1
]).

:- use_module('../Types/estado').
:- use_module('../Geography/distance').
:- use_module('ui_utils').

tela_gerenciamento_cidades(Estado, NovoEstado) :-
    limpar_tela,
    writeln('--- Gerenciamento de Cidades ---'),
    writeln('[1] Cadastrar Nova Cidade'),
    writeln('[2] Listar Cidades Adicionais'),
    writeln('[3] Excluir Cidade'),
    writeln('[0] Voltar'),
    write('Escolha: '),
    read_line_to_string(user_input, Op),
    processar_gerenciamento_cidades(Op, Estado, NovoEstado).

processar_gerenciamento_cidades("1", Estado, NovoEstado) :-
    tela_cadastro_cidade(Estado, NovoEstado).
processar_gerenciamento_cidades("2", Estado, Estado) :-
    Estado = estado_sistema(_, Cidades, _, _, _),
    writeln('\nCidades Adicionais:'),
    (Cidades = [] -> writeln('  Nenhuma cidade cadastrada.') ; listar_cidades_detalhado(Cidades)),
    writeln('\nPressione Enter para continuar...'),
    read_line_to_string(user_input, _).
processar_gerenciamento_cidades("3", Estado, NovoEstado) :-
    writeln('\n--- Excluir Cidade ---'),
    write('Nome da cidade a excluir: '), read_line_to_string(user_input, NomeStr),
    atom_string(Nome, NomeStr),
    excluir_cidade(Nome, Estado, NovoEstado).
processar_gerenciamento_cidades("0", Estado, Estado).
processar_gerenciamento_cidades(_, Estado, NovoEstado) :-
    Estado = estado_sistema(E, C, Camp, Config, _),
    NovoEstado = estado_sistema(E, C, Camp, Config, "Opcao invalida no gerenciamento de cidades.").

tela_cadastro_cidade(Estado, NovoEstado) :-
    writeln('\n--- Cadastro de Cidade ---'),
    write('Nome (ou Sigla): '), read_line_to_string(user_input, NomeStr),
    atom_string(Nome, NomeStr),
    write('Latitude: '), read_line_to_string(user_input, LatStr),
    number_string(Lat, LatStr),
    write('Longitude: '), read_line_to_string(user_input, LonStr),
    number_string(Lon, LonStr),
    adicionar_cidade(cidade(Nome, Lat, Lon), Estado, NovoEstado).
tela_cadastro_cidade(Estado, NovoEstado) :- 
    Estado = estado_sistema(E, C, Camp, Config, _),
    NovoEstado = estado_sistema(E, C, Camp, Config, "Erro ao cadastrar cidade! Verifique os valores.").

listar_cidades_disponiveis(Cidades) :-
    writeln('  - Estados padrao (AC, SP, RJ, etc.)'),
    listar_cidades_nomes(Cidades).
