% HECHOS

habitacion(h1).
habitacion(h2).
habitacion(h3).

caja(azul).
caja(roja).
caja(verde).

valor(h1, 1).
valor(h2, 2).
valor(h3, 3).

:- dynamic(ubicacion_inicial/1).
ubicacion_inicial(h1).

:- dynamic(habitacion_siguiente/1).
habitacion_siguiente(h2).

:- dynamic(lista_faltantes/1).
lista_faltantes([azul, roja, verde])

:- dynamic(direccion/1).
direccion(d).

:- dynamic(en_habitacion/2).
en_habitacion(azul, h1).
en_habitacion(roja, h1).
en_habitacion(verde, h3).

:- dynamic(valor/2).
valor(roja, 2).
valor(azul, 3).
valor(verde, 1).

% Definición de las puertas entre habitaciones
puerta_abierta(h1, h2).
puerta_abierta(h2, h1).
puerta_abierta(h2, h3).
puerta_abierta(h3, h2).



% Regla para mover al robot de una habitación a otra
mover(Robot, Desde, Hacia) :-
    ubicacion_inicial(Desde),  % El robot debe estar en la habitación desde la que se va a mover
    puerta_abierta(Desde, Hacia),  % La puerta entre las habitaciones debe estar abierta
    retract(ubicacion_inicial(Desde)),  % Retirar el hecho de que el robot está en la habitación actual
    asserta(ubicacion_inicial(Hacia)),  % Afirmar que el robot está en la habitación a la que se ha movido
    write('El robot se ha movido de '), write(Desde), write(' a '), write(Hacia), nl, % Imprimir un mensaje de movimiento
    direccion(Direccion),
    ((Hacia =:= h3, cambiar_direccion(Direccion))
    ;(Hacia =:= h1, cambiar_direccion(Direccion))
    ),
    cambiar_habitacion(Direccion).

% Regla para que el robot suelte una caja
soltar(Robot, Caja) :-
    ubicacion_inicial(Habitacion),  % Obtener la ubicación actual del robot
    asserta(en_habitacion(Caja, Habitacion)),  % Afirmar que la caja está en la habitación actual
    retract(valor(Caja, Valor)),
    asserta(valor(Caja,0)),  % Afirmar que el robot está en la habitación a la que se ha movido
    write('El robot ha soltado la caja '), write(Caja), nl,  % Imprimir un mensaje de soltar
    lista_faltantes([Cabeza|Resto]),
    retract(lista_faltantes([Cabeza|Resto])),
    asserta(lista_faltantes(Resto)).
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

mover_caja_a_habitacion(Caja, HabitacionSiguiente) :-
    ubicacion_inicial(HabitacionRobot),  % Obtener la ubicación actual del robot
    en_habitacion(Caja, HabitacionCaja),  % Obtener la ubicación de la caja
    HabitacionRobot = HabitacionCaja,  % Verificar si el robot y la caja están en la misma habitación
    retract(en_habitacion(Caja, HabitacionCaja)),  % Retirar la caja de la habitación actual
    write('El robot ha agarrado la caja '), write(Caja), nl,
    mover(Robot, HabitacionRobot, HabitacionSiguiente),  % Mover al robot a la habitación 2
    valor(Caja, ValorCaja),
    valor(HabitacionSiguiente, ValorHabitacion),
    habitacion_siguiente(NuevaSiguiente),
    ((ValorCaja =:= ValorHabitacion, soltar(Robot, Caja))
    ;(ValorCaja \= ValorHabitacion), mover_caja_a_habitacion(Caja, NuevaSiguiente)    ),
    !. % Cortar para evitar backtracking


mover_caja_a_habitacion(_, _). % Regla para evitar backtracking si no hay caja que mover

cambiar_habitacion(d):-
    ubicacion_inicial(HabitacionRobot),
    valor(HabitacionRobot, Valor),
    NuevoValor is Valor+1,
    valor(HabitacionSiguiente, NuevoValor),
    retract(habitacion_siguiente(HabitacionRobot)),
    asserta(habitacion_siguiente(HabitacionSiguiente)).

cambiar_habitacion(i):-
    ubicacion_inicial(HabitacionRobot),
    valor(HabitacionRobot, Valor),
    NuevoValor is Valor-1,
    valor(HabitacionSiguiente, NuevoValor),
    retract(habitacion_siguiente(HabitacionRobot)),
    asserta(habitacion_siguiente(HabitacionSiguiente)).

cambiar_direccion(DireccionActual):-
    ((DireccionActual=:= d, retract(direccion(d)), asserta(direccion(i)))
    ;(DireccionActual=:= i, retract(direccion(i)), asserta(direccion(d)))
    ).

mover_cajas_ordenadas([]). % Caso base: no quedan cajas por mover
mover_cajas_ordenadas(Caja) :- % Mover la primera caja y luego las restantes
    habitacion_siguiente(HabitacionSiguiente),
    mover_caja_a_habitacion(Caja, HabitacionSiguiente), % Mover la caja a la Habitación 2
    ubicacion_inicial(HabitacionRobot). % Obtener la ubicación actual del robot



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
    listar_ordenado_para_resolver([Cabeza|Resto]),  % Generar lista de cajas ordenadas por valor
    write('-----------------------------------------------------------------------'), nl,nl,
    write('LISTADO DE MOVIMIENTOS DEL ROBOT---------------------------------------'), nl,
    mover_cajas_ordenadas(Cabeza), % Mover las cajas ordenadas a la habitación 2
    write('-----------------------------------------------------------------------'), nl, nl,
    !. % Cortar para evitar backtracking y finalizar el proceso
