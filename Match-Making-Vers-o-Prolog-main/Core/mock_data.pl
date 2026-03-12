:- module(mock_data, [
    carregar_serie_a/2
]).

:- use_module('../Types/estado').

% carregar_serie_a(+EstadoAtual, -NovoEstado)
carregar_serie_a(EstadoAtual, NovoEstado) :-
    % Série A 2024 (exemplo)
    EquipesSerieA = [
        time('Palmeiras', 'SP'),
        time('Gremio', 'RS'),
        time('Atletico-MG', 'MG'),
        time('Flamengo', 'RJ'),
        time('Botafogo', 'RJ'),
        time('Bragantino', 'SP'),
        time('Fluminense', 'RJ'),
        time('Athletico-PR', 'PR'),
        time('Internacional', 'RS'),
        time('Fortaleza', 'CE'),
        time('Sao Paulo', 'SP'),
        time('Cuiaba', 'MT'),
        time('Corinthians', 'SP'),
        time('Cruzeiro', 'MG'),
        time('Vasco', 'RJ'),
        time('Bahia', 'BA'),
        time('Vitoria', 'BA'),
        time('Juventude', 'RS'),
        time('Criciuma', 'SC'),
        time('Atletico-GO', 'GO')
    ],
    EstadoAtual = estado_sistema(_, Cidades, Camp, Config, _),
    format(string(Msg), "Serie A carregada com ~w times!", [20]),
    NovoEstado = estado_sistema(EquipesSerieA, Cidades, Camp, Config, Msg).
