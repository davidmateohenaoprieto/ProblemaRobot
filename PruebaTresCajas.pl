% HECHOS

habitacion(h1).
habitacion(h2).

caja(azul).
caja(roja).

:- dynamic(ubicacion_inicial/1).
ubicacion_inicial(h1).

:- dynamic(en_habitacion/2).
en_habitacion(azul, h1).
en_habitacion(roja, h1).

:- dynamic(valor/2).
valor(roja, -1).
valor(azul, 1).

% Definición de las puertas entre habitaciones
puerta_abierta(h1, h2).
puerta_abierta(h2, h1).



% Regla para mover al robot de una habitación a otra
mover(Robot, Desde, Hacia) :-
    ubicacion_inicial(Desde),  % El robot debe estar en la habitación desde la que se va a mover
    puerta_abierta(Desde, Hacia),  % La puerta entre las habitaciones debe estar abierta
    retract(ubicacion_inicial(Desde)),  % Retirar el hecho de que el robot está en la habitación actual
    asserta(ubicacion_inicial(Hacia)),  % Afirmar que el robot está en la habitación a la que se ha movido
    write('El robot se ha movido de '), write(Desde), write(' a '), write(Hacia), nl.  % Imprimir un mensaje de movimiento

% Regla para que el robot suelte una caja
soltar(Robot, Caja) :-
    ubicacion_inicial(Habitacion),  % Obtener la ubicación actual del robot
    asserta(en_habitacion(Caja, Habitacion)),  % Afirmar que la caja está en la habitación actual
    retract(valor(Caja, Valor)),
    asserta(valor(Caja,0)),  % Afirmar que el robot está en la habitación a la que se ha movido
    write('El robot ha soltado la caja '), write(Caja), nl.  % Imprimir un mensaje de soltar

listar_ordenado_para_resolver(CajasOrdenadas) :-
    ubicacion_inicial(Habitacion),  % Obtener la ubicación actual del robot
    findall(Caja-Valor, (en_habitacion(Caja, Habitacion), valor(Caja, Valor), Valor > 0), CajasPositivas), % Recolectar cajas positivas
    sort(2, @>=, CajasPositivas, CajasOrdenadas), % Ordenar las cajas positivas de mayor a menor según su valor
    imprimir_cajas_ordenadas(CajasOrdenadas). % Imprimir las cajas ordenadas

% Regla para imprimir las cajas ordenadas
imprimir_cajas_ordenadas([]). % Caso base: lista vacía, no hay cajas que imprimir
imprimir_cajas_ordenadas([Caja-Valor|Resto]) :- % Imprimir la primera caja y luego las restantes
    write('Caja con valor positivo: '), write(Caja), write(', Valor: '), write(Valor), nl,
    imprimir_cajas_ordenadas(Resto).

mover_caja_a_habitacion2(Caja) :-
    ubicacion_inicial(HabitacionRobot),  % Obtener la ubicación actual del robot
    en_habitacion(Caja, HabitacionCaja),  % Obtener la ubicación de la caja
    HabitacionRobot = HabitacionCaja,  % Verificar si el robot y la caja están en la misma habitación
    retract(en_habitacion(Caja, HabitacionCaja)),  % Retirar la caja de la habitación actual
    asserta(en_habitacion(Caja, h2)),  % Colocar la caja en la habitación 2
    write('El robot ha agarrrado la caja '), write(Caja), nl,
    mover(Robot, HabitacionRobot, h2),  % Mover al robot a la habitación 2
    soltar(Robot, Caja), % Soltar la caja en la habitación 2
    !. % Cortar para evitar backtracking


mover_caja_a_habitacion2(_). % Regla para evitar backtracking si no hay caja que mover


mover_cajas_ordenadas([]) :- % Caso base: no quedan cajas por mover
    ubicacion_inicial(HabitacionRobot),
    mover(Robot, HabitacionRobot, h2).
mover_cajas_ordenadas([Caja-_|Resto]) :- % Mover la primera caja y luego las restantes
    mover_caja_a_habitacion2(Caja), % Mover la caja a la Habitación 2
    eliminar_caja(Caja, Resto, RestoSinCaja), % Eliminar la caja movida de la lista de cajas restantes
    ubicacion_inicial(HabitacionRobot), % Obtener la ubicación actual del robot
    mover(Robot, HabitacionRobot, h1), % Devolver al robot a la habitación donde están las siguientes cajas
    mover_cajas_ordenadas(RestoSinCaja). % Mover las cajas restantes


eliminar_caja(_, [], []). % Caso base: lista vacía, no hay cajas para eliminar
eliminar_caja(Caja, [Caja-_|Resto], RestoSinCaja) :- % Eliminar la caja de la lista
    !, % Cortar para evitar backtracking
    eliminar_caja(Caja, Resto, RestoSinCaja).
eliminar_caja(Caja, [OtraCaja-_|Resto], [OtraCaja-_|RestoSinCaja]) :- % Mantener otra caja en la lista
    Caja \= OtraCaja,
    eliminar_caja(Caja, Resto, RestoSinCaja).

resolver :-
    % ENTREGA 1 PROYECTO IA (BRAYAN FAJARDO-GABRIEL CORONADO-MATEO HENAO)
    write('ENTREGA 1 PROYECTO IA (BRAYAN FAJARDO-GABRIEL CORONADO-MATEO HENAO)'), nl, nl,
    write('LISTADO DE CAJAS A RECOGER---------------------------------------------'), nl,
    listar_ordenado_para_resolver(CajasOrdenadas),  % Generar lista de cajas ordenadas por valor
    write('-----------------------------------------------------------------------'), nl,nl,
    write('LISTADO DE MOVIMIENTOS DEL ROBOT---------------------------------------'), nl,
    mover_cajas_ordenadas(CajasOrdenadas), % Mover las cajas ordenadas a la habitación 2
    write('-----------------------------------------------------------------------'), nl, nl,  
    !. % Cortar para evitar backtracking y finalizar el proceso
