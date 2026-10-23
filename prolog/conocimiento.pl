:- encoding(utf8).
/*  conocimiento.pl — Base de conocimientos del Asesor de Inscripción
    ------------------------------------------------------------------
    Plan de estudios: Ingeniería en Inteligencia Artificial 2020 (ESCOM-IPN).
    Fuente del catálogo: mapa curricular "mapaCurricularIIA2020.pdf".

    IMPORTANTE (revisar): el mapa curricular NO indica la seriación. Los
    prerrequisitos de la sección 2 son una PROPUESTA razonable (dependencias
    académicas naturales entre materias). Verifícalos/ajústalos con el plan de
    estudios oficial: basta editar los hechos prerrequisitos/2.

    Convenciones:
      - Las materias son átomos (ids en minúsculas, sin acentos).
      - Aprobadas es una lista de átomos.
      - Todos los prerrequisitos de una materia son obligatorios (Y lógico).
      - REGLA DE DESFASE: si tienes sin aprobar una materia del semestre X, no
        puedes cursar ninguna materia con más de 2 semestres de diferencia
        (es decir, de semestre mayor a X+2). Ver max_desfase/1 y atrasadas/3.

    Contrato con server.pl:
      materia_catalogo/3, disponible/2, bloqueada/3, ruta/3, combinacion/3,
      explicacion/3
*/

:- discontiguous materia_catalogo/3.
:- discontiguous prerrequisitos/2.

% ===========================================================================
% 1. CATÁLOGO:  materia_catalogo(Id, Nombre, Semestre)
% ===========================================================================

% --- Semestre 1 ---
materia_catalogo(fundamentos_programacion, 'Fundamentos de Programación', 1).
materia_catalogo(matematicas_discretas,    'Matemáticas Discretas', 1).
materia_catalogo(calculo,                  'Cálculo', 1).
materia_catalogo(comunicacion_oral_escrita,'Comunicación Oral y Escrita', 1).
materia_catalogo(mecanica_electromagnetismo,'Mecánica y Electromagnetismo', 1).
materia_catalogo(fundamentos_economicos,   'Fundamentos Económicos', 1).

% --- Semestre 2 ---
materia_catalogo(algoritmos_estructuras_datos, 'Algoritmos y Estructuras de Datos', 2).
materia_catalogo(fundamentos_diseno_digital,   'Fundamentos de Diseño Digital', 2).
materia_catalogo(calculo_multivariable,             'Cálculo Multivariable', 2).
materia_catalogo(ingenieria_etica_sociedad,    'Ingeniería, Ética y Sociedad', 2).
materia_catalogo(algebra_lineal,               'Álgebra Lineal', 2).
materia_catalogo(finanzas_empresariales,       'Finanzas Empresariales', 2).

% --- Semestre 3 ---
materia_catalogo(analisis_diseno_algoritmos, 'Análisis y Diseño de Algoritmos', 3).
materia_catalogo(paradigmas_programacion,    'Paradigmas de Programación', 3).
materia_catalogo(ecuaciones_diferenciales,   'Ecuaciones Diferenciales', 3).
materia_catalogo(bases_datos,                'Bases de Datos', 3).
materia_catalogo(diseno_sistemas_digitales,  'Diseño de Sistemas Digitales', 3).
materia_catalogo(liderazgo_personal,         'Liderazgo Personal', 3).

% --- Semestre 4 ---
materia_catalogo(fundamentos_ia,               'Fundamentos de Inteligencia Artificial', 4).
materia_catalogo(probabilidad_estadistica,     'Probabilidad y Estadística', 4).
materia_catalogo(matematicas_avanzadas,        'Matemáticas Avanzadas para la Ingeniería', 4).
materia_catalogo(tecnologias_web,              'Tecnologías para el Desarrollo de Aplicaciones Web', 4).
materia_catalogo(analisis_diseno_sistemas,     'Análisis y Diseño de Sistemas', 4).
materia_catalogo(procesamiento_digital_senales,'Procesamiento Digital de Señales', 4).

% --- Semestre 5 ---
materia_catalogo(aprendizaje_maquina,        'Aprendizaje de Máquina', 5).
materia_catalogo(vision_artificial,          'Visión Artificial', 5).
materia_catalogo(teoria_computacion,         'Teoría de la Computación', 5).
materia_catalogo(procesamiento_senales,      'Procesamiento de Señales', 5).
materia_catalogo(algoritmos_bioinspirados,   'Algoritmos Bioinspirados', 5).
materia_catalogo(tecnologias_lenguaje_natural,'Tecnologías de Lenguaje Natural', 5).

% --- Semestre 6 ---
materia_catalogo(computo_paralelo,        'Cómputo Paralelo', 6).
materia_catalogo(redes_neuronales,        'Redes Neuronales y Aprendizaje Profundo', 6).
materia_catalogo(ingenieria_software_si,  'Ingeniería de Software para Sistemas Inteligentes', 6).
materia_catalogo(optativa_a,              'Optativa A', 6).
materia_catalogo(optativa_b,              'Optativa B', 6).
materia_catalogo(metodologia_investigacion,'Metodología de la Investigación y Divulgación Científica', 6).

% --- Semestre 7 ---
materia_catalogo(reconocimiento_voz,   'Reconocimiento de Voz', 7).
materia_catalogo(trabajo_terminal_1,   'Trabajo Terminal I', 7).
materia_catalogo(formulacion_proyectos,'Formulación y Evaluación de Proyectos Informáticos', 7).
materia_catalogo(optativa_c,           'Optativa C', 7).
materia_catalogo(optativa_d,           'Optativa D', 7).

% --- Semestre 8 ---
materia_catalogo(gestion_empresarial,  'Gestión Empresarial', 8).
materia_catalogo(trabajo_terminal_2,   'Trabajo Terminal II', 8).
materia_catalogo(estancia_profesional, 'Estancia Profesional', 8).
materia_catalogo(habilidades_sociales, 'Desarrollo de Habilidades Sociales para la Alta Dirección', 8).

% ===========================================================================
% 2. SERIACIÓN (SUPUESTA — verificar con el plan oficial)
%    prerrequisitos(Materia, ListaDeMateriasQueDebenEstarAprobadas)
% ===========================================================================

% Semestre 1: sin prerrequisitos
prerrequisitos(fundamentos_programacion,    []).
prerrequisitos(matematicas_discretas,       []).
prerrequisitos(calculo,                     []).
prerrequisitos(comunicacion_oral_escrita,   []).
prerrequisitos(mecanica_electromagnetismo,  []).
prerrequisitos(fundamentos_economicos,      []).

% Semestre 2
prerrequisitos(algoritmos_estructuras_datos, [fundamentos_programacion]).
prerrequisitos(fundamentos_diseno_digital,   []).
prerrequisitos(calculo_multivariable,             [calculo]).
prerrequisitos(ingenieria_etica_sociedad,    []).
prerrequisitos(algebra_lineal,               []).
prerrequisitos(finanzas_empresariales,       [fundamentos_economicos]).

% Semestre 3
prerrequisitos(analisis_diseno_algoritmos, [algoritmos_estructuras_datos, matematicas_discretas]).
prerrequisitos(paradigmas_programacion,    [algoritmos_estructuras_datos]).
prerrequisitos(ecuaciones_diferenciales,   [calculo_multivariable]).
prerrequisitos(bases_datos,                [algoritmos_estructuras_datos]).
prerrequisitos(diseno_sistemas_digitales,  [fundamentos_diseno_digital]).
prerrequisitos(liderazgo_personal,         []).

% Semestre 4
prerrequisitos(fundamentos_ia,                [paradigmas_programacion, matematicas_discretas]).
prerrequisitos(probabilidad_estadistica,      [calculo_multivariable]).
prerrequisitos(matematicas_avanzadas,         [ecuaciones_diferenciales, algebra_lineal]).
prerrequisitos(tecnologias_web,               [bases_datos]).
prerrequisitos(analisis_diseno_sistemas,      [bases_datos]).
prerrequisitos(procesamiento_digital_senales, [ecuaciones_diferenciales, algebra_lineal]).

% Semestre 5
prerrequisitos(aprendizaje_maquina,         [fundamentos_ia, probabilidad_estadistica]).
prerrequisitos(vision_artificial,           [fundamentos_ia, procesamiento_digital_senales]).
prerrequisitos(teoria_computacion,          [analisis_diseno_algoritmos]).
prerrequisitos(procesamiento_senales,       [procesamiento_digital_senales]).
prerrequisitos(algoritmos_bioinspirados,    [fundamentos_ia, analisis_diseno_algoritmos]).
prerrequisitos(tecnologias_lenguaje_natural,[fundamentos_ia]).

% Semestre 6
prerrequisitos(computo_paralelo,           [analisis_diseno_algoritmos]).
prerrequisitos(redes_neuronales,           [aprendizaje_maquina]).
prerrequisitos(ingenieria_software_si,     [analisis_diseno_sistemas, fundamentos_ia]).
prerrequisitos(optativa_a,                 [fundamentos_ia]).
prerrequisitos(optativa_b,                 [fundamentos_ia]).
prerrequisitos(metodologia_investigacion,  []).

% Semestre 7
prerrequisitos(reconocimiento_voz,     [procesamiento_senales, aprendizaje_maquina]).
prerrequisitos(trabajo_terminal_1,     [ingenieria_software_si, metodologia_investigacion]).
prerrequisitos(formulacion_proyectos,  [finanzas_empresariales]).
prerrequisitos(optativa_c,             [fundamentos_ia]).
prerrequisitos(optativa_d,             [fundamentos_ia]).

% Semestre 8
prerrequisitos(gestion_empresarial,  [finanzas_empresariales]).
prerrequisitos(trabajo_terminal_2,   [trabajo_terminal_1]).
prerrequisitos(estancia_profesional, [trabajo_terminal_1]).
prerrequisitos(habilidades_sociales, [liderazgo_personal]).

% ===========================================================================
% 3. REGLAS
% ===========================================================================

% max_desfase(-N): máximo de semestres de diferencia permitido (ajustable).
max_desfase(2).

% cumple(+Aprobadas, +Materia): todos sus prerrequisitos están aprobados.
cumple(Aprobadas, Materia) :-
    prerrequisitos(Materia, Reqs),
    forall(member(R, Reqs), memberchk(R, Aprobadas)).

% faltantes(+Aprobadas, +Materia, -Faltantes): prerrequisitos aún no aprobados.
faltantes(Aprobadas, Materia, Faltantes) :-
    prerrequisitos(Materia, Reqs),
    findall(R, (member(R, Reqs), \+ memberchk(R, Aprobadas)), Faltantes).

% atrasadas(+Aprobadas, +Materia, -Atrasadas): materias NO aprobadas cuyo
% semestre está a más de max_desfase/1 semestres por debajo del de Materia.
% Si la lista no está vacía, Materia no puede cursarse por desfase.
atrasadas(Aprobadas, Materia, Atrasadas) :-
    materia_catalogo(Materia, _, Sem),
    max_desfase(D),
    findall(X, ( materia_catalogo(X, _, SemX),
                 \+ memberchk(X, Aprobadas),
                 Sem - SemX > D ),
            Atrasadas).

% sin_desfase(+Aprobadas, +Materia): no hay unidades atrasadas que la impidan.
sin_desfase(Aprobadas, Materia) :-
    atrasadas(Aprobadas, Materia, []).

% puede_cursar(+Aprobadas, +Materia): prerrequisitos cubiertos y sin desfase.
puede_cursar(Aprobadas, Materia) :-
    cumple(Aprobadas, Materia),
    sin_desfase(Aprobadas, Materia).

% impedimentos(+Aprobadas, +Materia, -Faltantes): prerrequisitos pendientes
% más materias atrasadas (sin repetidos).
impedimentos(Aprobadas, Materia, Impedimentos) :-
    faltantes(Aprobadas, Materia, F),
    atrasadas(Aprobadas, Materia, A),
    append(F, A, L),
    list_to_set(L, Impedimentos).

% disponible(+Aprobadas, ?Materia): se puede cursar (no aprobada, con
% prerrequisitos cubiertos y sin desfase).
disponible(Aprobadas, Materia) :-
    materia_catalogo(Materia, _, _),
    \+ memberchk(Materia, Aprobadas),
    puede_cursar(Aprobadas, Materia).

% bloqueada(+Aprobadas, ?Materia, -Faltantes): no aprobada y con algún
% impedimento (prerrequisito pendiente o materia atrasada).
bloqueada(Aprobadas, Materia, Faltantes) :-
    materia_catalogo(Materia, _, _),
    \+ memberchk(Materia, Aprobadas),
    impedimentos(Aprobadas, Materia, Faltantes),
    Faltantes \== [].

% ---------------------------------------------------------------------------
% ruta(+Aprobadas, +Meta, -Pasos)
%   Pasos = lista de listas, una por semestre. Cada paso contiene las materias
%   necesarias que ya se pueden cursar (prerrequisitos + regla de desfase) con
%   lo aprobado hasta el paso previo. Las materias necesarias son: la Meta, sus
%   antecedentes transitivos y las materias atrasadas que, por la regla de
%   desfase, impedirían cursar la Meta. Si la Meta ya está aprobada, Pasos = [].
% ---------------------------------------------------------------------------
ruta(Aprobadas, Meta, Pasos) :-
    materia_catalogo(Meta, _, _),
    (   memberchk(Meta, Aprobadas)
    ->  Pasos = []
    ;   atrasadas(Aprobadas, Meta, Atras),
        antecedentes_de([Meta|Atras], Todas),
        findall(M, ( member(M, Todas), \+ memberchk(M, Aprobadas) ), Pend0),
        list_to_set(Pend0, Pendientes),
        pasos(Pendientes, Aprobadas, Pasos)
    ).

% antecedentes_de(+Materias, -Lista): Materias más sus antecesores transitivos.
antecedentes_de(Materias, Lista) :-
    list_to_set(Materias, Base),
    antecedentes_(Base, Base, Lista).

antecedentes_([], Vistos, Vistos).
antecedentes_([M|Resto], Vistos, Lista) :-
    prerrequisitos(M, Reqs),
    findall(R, ( member(R, Reqs), \+ memberchk(R, Vistos), \+ memberchk(R, Resto) ), Nuevos),
    append(Resto, Nuevos, Cola),
    append(Vistos, Nuevos, Vistos1),
    antecedentes_(Cola, Vistos1, Lista).

% pasos(+Pendientes, +Aprobadas, -Semestres)
pasos([], _, []) :- !.
pasos(Pendientes, Aprobadas, [Semestre|Resto]) :-
    findall(M, ( member(M, Pendientes), puede_cursar(Aprobadas, M) ), Semestre),
    Semestre \== [],                        % evita ciclos infinitos
    append(Aprobadas, Semestre, Aprobadas2),
    subtract(Pendientes, Semestre, Pendientes2),
    pasos(Pendientes2, Aprobadas2, Resto).

% ---------------------------------------------------------------------------
% combinacion(+Aprobadas, +Max, -Materias)
%   Subconjuntos no vacíos de las materias disponibles, de tamaño Max a 1
%   (primero las combinaciones más completas). Backtracking.
% ---------------------------------------------------------------------------
combinacion(Aprobadas, Max, Materias) :-
    findall(M, disponible(Aprobadas, M), Disponibles),
    length(Disponibles, N),
    Tope is min(Max, N),
    Tope >= 1,
    numlist(1, Tope, Tamanos),
    reverse(Tamanos, Descendente),
    member(K, Descendente),
    elegir(K, Disponibles, Materias).

% elegir(+K, +Lista, -Subconjunto): subconjuntos de K elementos conservando el orden.
elegir(0, _, []) :- !.
elegir(K, [X|Xs], [X|Ys]) :-
    K > 0, K1 is K - 1,
    elegir(K1, Xs, Ys).
elegir(K, [_|Xs], Ys) :-
    K > 0,
    elegir(K, Xs, Ys).

% ---------------------------------------------------------------------------
% explicacion(+Materia, +Aprobadas, -Razon)
%   Razon: lista de cadenas con las reglas aplicadas.
% ---------------------------------------------------------------------------
explicacion(Materia, Aprobadas, Razon) :-
    materia_catalogo(Materia, Nombre, Sem),
    prerrequisitos(Materia, Reqs),
    max_desfase(D),
    format(string(L0), 'Materia: ~w (semestre ~w).', [Nombre, Sem]),
    (   memberchk(Materia, Aprobadas)
    ->  Razon = [L0, 'Ya está en tu lista de aprobadas.']
    ;   faltantes(Aprobadas, Materia, Falt),
        atrasadas(Aprobadas, Materia, Atras),
        linea_prereq(Reqs, Falt, LP),
        (   Falt == [], Atras == []
        ->  format(string(LD), 'Regla de desfase: no tienes materias pendientes con más de ~w semestres de diferencia.', [D]),
            Razon = [L0, LP, 'Regla disponible/2: prerrequisitos cubiertos y sin desfase.', LD]
        ;   findall(Linea, causa(Falt, Atras, D, Linea), Causas),
            Razon = [L0, LP|Causas]
        )
    ).

linea_prereq([], _, 'Prerrequisitos: ninguno.') :- !.
linea_prereq(Reqs, _, Linea) :-
    nombres(Reqs, N),
    format(string(Linea), 'Prerrequisitos: ~w.', [N]).

causa(Falt, _, _, Linea) :-
    Falt \== [],
    nombres(Falt, N),
    format(string(Linea), 'Regla bloqueada/3: aún no aprobaste los prerrequisitos: ~w.', [N]).
causa(_, Atras, D, Linea) :-
    Atras \== [],
    nombres(Atras, N),
    format(string(Linea),
           'Regla de desfase: tienes pendientes con más de ~w semestres de diferencia (~w); apruébalas para poder cursar esta materia.',
           [D, N]).

% nombres(+Ids, -Texto): "Nombre1, Nombre2".
nombres(Ids, Texto) :-
    findall(N, ( member(I, Ids), materia_catalogo(I, N, _) ), Ns),
    atomic_list_concat(Ns, ', ', Texto).
