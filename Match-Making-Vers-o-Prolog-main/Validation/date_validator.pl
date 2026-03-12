
% Validation/date_validator.pl
% correspondente a DateValidator.hs


:- module(date_validator, [
    validar_data/1,
    dias_no_mes/3,
    ano_bissexto/1
]).

% --- VERIFICAÇÃO DE ANO BISSEXTO ---
% ano_bissexto(+Ano)
% A regra tem sucesso se o ano for divisível por 4 E (não for divisível por 100 OU for divisível por 400).
ano_bissexto(Ano) :-
    Ano mod 4 =:= 0,
    ( Ano mod 100 =\= 0 ; Ano mod 400 =:= 0 ).

% --- DIAS NO MÊS ---
% dias_no_mes(+Mes, +Ano, -TotalDias)

% Caso 1: Fevereiro em ano bissexto
dias_no_mes(2, Ano, 29) :- 
    ano_bissexto(Ano), 
    !. % O Cut garante que não vai testar a regra de baixo se for bissexto

% Caso 2: Fevereiro em ano comum
dias_no_mes(2, _, 28) :- 
    !.

% Caso 3: Meses com 31 dias
% O predicado member/2 verifica se o elemento Mês está dentro da lista.
dias_no_mes(Mes, _, 31) :- 
    member(Mes, [1, 3, 5, 7, 8, 10, 12]), 
    !.

% Caso 4: Meses com 30 dias
dias_no_mes(Mes, _, 30) :- 
    member(Mes, [4, 6, 9, 11]), 
    !.

% Caso 5: Mês inválido (Fallback)
dias_no_mes(_, _, 0).

% --- VALIDAÇÃO DA DATA ---
% validar_data(+Data)
% Desestrutura o termo data/3 e aplica as regras lógicas.
% Em Prolog, o operador de menor ou igual é '=<' (e não '<=').
validar_data(data(Dia, Mes, Ano)) :-
    Mes >= 1, 
    Mes =< 12,
    dias_no_mes(Mes, Ano, MaxDias),
    Dia >= 1, 
    Dia =< MaxDias.