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

valor(azul, 1).
valor(roja, -1).

% Definición de las puertas entre habitaciones
puerta_abierta(h1, h2).
puerta_abierta(h2, h1).

% REGLAS

% Regla para mover al robot de una habitación a otra
mover(Robot, Desde, Hacia) :-
    ubicacion_inicial(Desde),  % El robot debe estar en la habitación desde la que se va a mover
    puerta_abierta(Desde, Hacia),  % La puerta entre las habitaciones debe estar abierta
    retract(ubicacion_inicial(Desde)),  % Retirar el hecho de que el robot está en la habitación actual
    asserta(ubicacion_inicial(Hacia)),  % Afirmar que el robot está en la habitación a la que se ha movido
    write('El robot se ha movido de '), write(Desde), write(' a '), write(Hacia), nl.  % Imprimir un mensaje de movimiento

% Regla para que el robot agarre una caja
agarrar(Robot, Caja) :-
    ubicacion_inicial(Habitacion),  % Obtener la ubicación actual del robot
    en_habitacion(Caja, Habitacion),  % Verificar si la caja está en la misma habitación que el robot
    valor(Caja, 1),  % Verificar si la caja tiene valor igual a 1
    retract(en_habitacion(Caja, Habitacion)),  % Retirar el hecho de que la caja está en la habitación actual
    write('El robot ha agarrado la caja '), write(Caja), nl.  % Imprimir un mensaje de agarrar

% Regla para que el robot suelte una caja
soltar(Robot, Caja) :-
    ubicacion_inicial(Habitacion),  % Obtener la ubicación actual del robot
    asserta(en_habitacion(Caja, Habitacion)),  % Afirmar que la caja está en la habitación actual
    write('El robot ha soltado la caja '), write(Caja), nl.  % Imprimir un mensaje de soltar
