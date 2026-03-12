:- module(distance, [
    obter_distancia/4,
    eh_viagem_inviavel/2,
    todas_cidades/2
]).

% ...
todas_cidades(CidadesAdicionais, Todas) :-
    findall(cidade(E, Lat, Lon), coordenadas(E, Lat, Lon), Estaticas),
    append(Estaticas, CidadesAdicionais, Todas).

% --- COORDENADAS (Fatos) ---

% formato: coordenadas(Estado, Latitude, Longitude).
coordenadas('AC', -9.97, -67.81).
coordenadas('AL', -9.66, -35.73).
coordenadas('AP', 0.03, -51.06).
coordenadas('AM', -3.11, -60.02).
coordenadas('BA', -12.97, -38.50).
coordenadas('CE', -3.71, -38.54).
coordenadas('DF', -15.79, -47.88).
coordenadas('ES', -20.31, -40.31).
coordenadas('GO', -16.68, -49.25).
coordenadas('MA', -2.53, -44.30).
coordenadas('MT', -15.60, -56.09).
coordenadas('MS', -20.44, -54.61).
coordenadas('MG', -19.91, -43.93).
coordenadas('PA', -1.45, -48.50).
coordenadas('PB', -7.11, -34.86).
coordenadas('PR', -25.42, -49.27).
coordenadas('PE', -8.05, -34.88).
coordenadas('PI', -5.09, -42.80).
coordenadas('RJ', -22.90, -43.17).
coordenadas('RN', -5.79, -35.20).
coordenadas('RS', -30.03, -51.21).
coordenadas('RO', -8.76, -63.90).
coordenadas('RR', 2.82, -60.67).
coordenadas('SC', -27.59, -48.54).
coordenadas('SP', -23.55, -46.63).
coordenadas('SE', -10.91, -37.07).
coordenadas('TO', -10.16, -48.33).

% --- BUSCAR COORDENADA ---
% buscar_coord(+Nome, +CidadesAdicionais, -Lat, -Lon)
buscar_coord(Nome, _, Lat, Lon) :-
    coordenadas(Nome, Lat, Lon), !.
buscar_coord(Nome, Cidades, Lat, Lon) :-
    member(cidade(Nome, Lat, Lon), Cidades), !.

% --- HAVERSINE ---
% haversine(+Lat1, +Lon1, +Lat2, +Lon2, -Distancia)
haversine(Lat1, Lon1, Lat2, Lon2, Distancia) :-
    R = 6371, % Raio médio da Terra em KM
    
    % Conversão para Radianos
    DLat is (Lat2 - Lat1) * pi / 180,
    DLon is (Lon2 - Lon1) * pi / 180,
    Lat1Rad is Lat1 * pi / 180,
    Lat2Rad is Lat2 * pi / 180,
    

    % O operador ** é a exponenciação.
    A is sin(DLat/2)**2 + cos(Lat1Rad) * cos(Lat2Rad) * sin(DLon/2)**2,
    C is 2 * atan2(sqrt(A), sqrt(1 - A)),
    
    Distancia is R * C.

% --- OBTER DISTÂNCIA ---
% obter_distancia(+Origem, +Destino, +CidadesAdicionais, -DistanciaArredondada)

% Caso 1: Origem e Destino são iguais. 
obter_distancia(Origem, Destino, _, 0) :- 
    Origem == Destino,
    !. % O Cut (!) diz ao Prolog: "Se chegou aqui, pare! Não teste as regras abaixo."

% Caso 2: Coordenadas válidas são encontradas.
obter_distancia(Origem, Destino, Cidades, DistanciaArredondada) :-
    buscar_coord(Origem, Cidades, Lat1, Lon1),
    buscar_coord(Destino, Cidades, Lat2, Lon2),
    !, % Encontrou os dois estados? Ótimo, faça a conta e não use o fallback.
    haversine(Lat1, Lon1, Lat2, Lon2, DistReal),
    DistanciaArredondada is round(DistReal).

% Caso 3: Fallback (Equivalente ao `if c1 == (0,0) || c2 == (0,0)` do Haskell).
% Se as regras acima falharem (ex: sigla desconhecida), ele cai aqui.
obter_distancia(_, _, _, 800).

% --- VALIDAÇÃO DE INVIABILIDADE ---
% eh_viagem_inviavel(+Limite, +Distancia)
% Em Prolog, não retornamos um booleano "True" ou "False". 
% O predicado simplesmente "passa" (é verdade) ou "falha" (é mentira).
eh_viagem_inviavel(Limite, Distancia) :-
    Distancia > Limite.