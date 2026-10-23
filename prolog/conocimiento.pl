:- encoding(utf8).

:- discontiguous materia_catalogo/3.
:- discontiguous prerrequisitos/2.

materia_catalogo(fundamentos_programacion, 'Fundamentos de Programación', 1).
materia_catalogo(matematicas_discretas, 'Matemáticas Discretas', 1).
materia_catalogo(calculo, 'Cálculo', 1).
materia_catalogo(comunicacion_oral_escrita, 'Comunicación Oral y Escrita', 1).
materia_catalogo(mecanica_electromagnetismo, 'Mecánica y Electromagnetismo', 1).
materia_catalogo(fundamentos_economicos, 'Fundamentos Económicos', 1).

materia_catalogo(algoritmos_estructuras_datos, 'Algoritmos y Estructuras de Datos', 2).
materia_catalogo(fundamentos_diseno_digital, 'Fundamentos de Diseño Digital', 2).
materia_catalogo(calculo_multivariable, 'Cálculo Multivariable', 2).
materia_catalogo(ingenieria_etica_sociedad, 'Ingeniería, Ética y Sociedad', 2).
materia_catalogo(algebra_lineal, 'Álgebra Lineal', 2).
materia_catalogo(finanzas_empresariales, 'Finanzas Empresariales', 2).

materia_catalogo(analisis_diseno_algoritmos, 'Análisis y Diseño de Algoritmos', 3).
materia_catalogo(paradigmas_programacion, 'Paradigmas de Programación', 3).
materia_catalogo(ecuaciones_diferenciales, 'Ecuaciones Diferenciales', 3).
materia_catalogo(bases_datos, 'Bases de Datos', 3).
materia_catalogo(diseno_sistemas_digitales, 'Diseño de Sistemas Digitales', 3).
materia_catalogo(liderazgo_personal, 'Liderazgo Personal', 3).

materia_catalogo(fundamentos_ia, 'Fundamentos de Inteligencia Artificial', 4).
materia_catalogo(probabilidad_estadistica, 'Probabilidad y Estadística', 4).
materia_catalogo(matematicas_avanzadas, 'Matemáticas Avanzadas para la Ingeniería', 4).
materia_catalogo(tecnologias_web, 'Tecnologías para el Desarrollo de Aplicaciones Web', 4).
materia_catalogo(analisis_diseno_sistemas, 'Análisis y Diseño de Sistemas', 4).
materia_catalogo(procesamiento_digital_senales, 'Procesamiento Digital de Señales', 4).

materia_catalogo(aprendizaje_maquina, 'Aprendizaje de Máquina', 5).
materia_catalogo(vision_artificial, 'Visión Artificial', 5).
materia_catalogo(teoria_computacion, 'Teoría de la Computación', 5).
materia_catalogo(procesamiento_senales, 'Procesamiento de Señales', 5).
materia_catalogo(algoritmos_bioinspirados, 'Algoritmos Bioinspirados', 5).
materia_catalogo(tecnologias_lenguaje_natural, 'Tecnologías de Lenguaje Natural', 5).

materia_catalogo(computo_paralelo, 'Cómputo Paralelo', 6).
materia_catalogo(redes_neuronales, 'Redes Neuronales y Aprendizaje Profundo', 6).
materia_catalogo(ingenieria_software_si, 'Ingeniería de Software para Sistemas Inteligentes', 6).
materia_catalogo(optativa_a, 'Optativa A', 6).
materia_catalogo(optativa_b, 'Optativa B', 6).
materia_catalogo(metodologia_investigacion, 'Metodología de la Investigación y Divulgación Científica', 6).

materia_catalogo(reconocimiento_voz, 'Reconocimiento de Voz', 7).
materia_catalogo(trabajo_terminal_1, 'Trabajo Terminal I', 7).
materia_catalogo(formulacion_proyectos, 'Formulación y Evaluación de Proyectos Informáticos', 7).
materia_catalogo(optativa_c, 'Optativa C', 7).
materia_catalogo(optativa_d, 'Optativa D', 7).

materia_catalogo(gestion_empresarial, 'Gestión Empresarial', 8).
materia_catalogo(trabajo_terminal_2, 'Trabajo Terminal II', 8).
materia_catalogo(estancia_profesional, 'Estancia Profesional', 8).
materia_catalogo(habilidades_sociales, 'Desarrollo de Habilidades Sociales para la Alta Dirección', 8).

prerrequisitos(fundamentos_programacion, []).
prerrequisitos(matematicas_discretas, []).
prerrequisitos(calculo, []).
prerrequisitos(comunicacion_oral_escrita, []).
prerrequisitos(mecanica_electromagnetismo, []).
prerrequisitos(fundamentos_economicos, []).

prerrequisitos(algoritmos_estructuras_datos, [fundamentos_programacion]).
prerrequisitos(fundamentos_diseno_digital, []).
prerrequisitos(calculo_multivariable, [calculo]).
prerrequisitos(ingenieria_etica_sociedad, []).
prerrequisitos(algebra_lineal, []).
prerrequisitos(finanzas_empresariales, [fundamentos_economicos]).

prerrequisitos(analisis_diseno_algoritmos, [algoritmos_estructuras_datos, matematicas_discretas]).
prerrequisitos(paradigmas_programacion, [algoritmos_estructuras_datos]).
prerrequisitos(ecuaciones_diferenciales, [calculo_multivariable]).
prerrequisitos(bases_datos, [algoritmos_estructuras_datos]).
prerrequisitos(diseno_sistemas_digitales, [fundamentos_diseno_digital]).
prerrequisitos(liderazgo_personal, []).

prerrequisitos(fundamentos_ia, [paradigmas_programacion, matematicas_discretas]).
prerrequisitos(probabilidad_estadistica, [calculo_multivariable]).
prerrequisitos(matematicas_avanzadas, [ecuaciones_diferenciales, algebra_lineal]).
prerrequisitos(tecnologias_web, [bases_datos]).
prerrequisitos(analisis_diseno_sistemas, [bases_datos]).
prerrequisitos(procesamiento_digital_senales, [ecuaciones_diferenciales, algebra_lineal]).

prerrequisitos(aprendizaje_maquina, [fundamentos_ia, probabilidad_estadistica]).
prerrequisitos(vision_artificial, [fundamentos_ia, procesamiento_digital_senales]).
prerrequisitos(teoria_computacion, [analisis_diseno_algoritmos]).
prerrequisitos(procesamiento_senales, [procesamiento_digital_senales]).
prerrequisitos(algoritmos_bioinspirados, [fundamentos_ia, analisis_diseno_algoritmos]).
prerrequisitos(tecnologias_lenguaje_natural,[fundamentos_ia]).

prerrequisitos(computo_paralelo, [analisis_diseno_algoritmos]).
prerrequisitos(redes_neuronales, [aprendizaje_maquina]).
prerrequisitos(ingenieria_software_si, [analisis_diseno_sistemas, fundamentos_ia]).
prerrequisitos(optativa_a, [fundamentos_ia]).
prerrequisitos(optativa_b, [fundamentos_ia]).
prerrequisitos(metodologia_investigacion, []).

prerrequisitos(reconocimiento_voz, [procesamiento_senales, aprendizaje_maquina]).
prerrequisitos(trabajo_terminal_1, [ingenieria_software_si, metodologia_investigacion]).
prerrequisitos(formulacion_proyectos, [finanzas_empresariales]).
prerrequisitos(optativa_c, [fundamentos_ia]).
prerrequisitos(optativa_d, [fundamentos_ia]).

prerrequisitos(gestion_empresarial, [finanzas_empresariales]).
prerrequisitos(trabajo_terminal_2, [trabajo_terminal_1]).
prerrequisitos(estancia_profesional, [trabajo_terminal_1]).
prerrequisitos(habilidades_sociales, [liderazgo_personal]).

max_desfase(2).

cumple(Aprobadas, Materia) :-
    prerrequisitos(Materia, Requisitos),
    forall(member(R, Requisitos), memberchk(R, Aprobadas)).

faltantes(Aprobadas, Materia, Faltantes) :-
    prerrequisitos(Materia, Requisitos),
    findall(R, (member(R, Requisitos), \+ memberchk(R, Aprobadas)), Faltantes).

atrasadas(Aprobadas, Materia, Atrasadas) :-
    materia_catalogo(Materia, _, Sem),
    max_desfase(D),
    findall(X, ( materia_catalogo(X, _, SemX),
                 \+ memberchk(X, Aprobadas),
                 Sem - SemX > D ),
            Atrasadas).

sin_desfase(Aprobadas, Materia) :-
    atrasadas(Aprobadas, Materia, []).

puede_cursar(Aprobadas, Materia) :-
    cumple(Aprobadas, Materia),
    sin_desfase(Aprobadas, Materia).

impedimentos(Aprobadas, Materia, Impedimentos) :-
    faltantes(Aprobadas, Materia, F),
    atrasadas(Aprobadas, Materia, A),
    append(F, A, L),
    list_to_set(L, Impedimentos).

disponible(Aprobadas, Materia) :-
    materia_catalogo(Materia, _, _),
    \+ memberchk(Materia, Aprobadas),
    puede_cursar(Aprobadas, Materia).

bloqueada(Aprobadas, Materia, Faltantes) :-
    materia_catalogo(Materia, _, _),
    \+ memberchk(Materia, Aprobadas),
    impedimentos(Aprobadas, Materia, Faltantes),
    Faltantes \== [].

ruta(Aprobadas, Meta, Pasos) :-
    materia_catalogo(Meta, _, _),
    ( memberchk(Meta, Aprobadas)
    -> Pasos = []
    ; atrasadas(Aprobadas, Meta, Atras),
        antecedentes_de([Meta|Atras], Todas),
        findall(M, ( member(M, Todas), \+ memberchk(M, Aprobadas) ), Pend0),
        list_to_set(Pend0, Pendientes),
        pasos(Pendientes, Aprobadas, Pasos)
    ).

antecedentes_de(Materias, Lista) :-
    list_to_set(Materias, Base),
    antecedentes_(Base, Base, Lista).

antecedentes_([], Vistos, Vistos).
antecedentes_([M|Resto], Vistos, Lista) :-
    prerrequisitos(M, Requisitos),
    findall(R, ( member(R, Requisitos), \+ memberchk(R, Vistos), \+ memberchk(R, Resto) ), Nuevos),
    append(Resto, Nuevos, Cola),
    append(Vistos, Nuevos, Vistos1),
    antecedentes_(Cola, Vistos1, Lista).

pasos([], _, []) :- !.
pasos(Pendientes, Aprobadas, [Semestre|Resto]) :-
    findall(M, ( member(M, Pendientes), puede_cursar(Aprobadas, M) ), Semestre),
    Semestre \== [],
    append(Aprobadas, Semestre, Aprobadas2),
    subtract(Pendientes, Semestre, Pendientes2),
    pasos(Pendientes2, Aprobadas2, Resto).

combinacion(Aprobadas, Max, Materias) :-
    findall(M, disponible(Aprobadas, M), Disponibles),
    length(Disponibles, N),
    Tope is min(Max, N),
    Tope >= 1,
    numlist(1, Tope, Tamanos),
    reverse(Tamanos, Descendente),
    member(K, Descendente),
    elegir(K, Disponibles, Materias).

elegir(0, _, []) :- !.
elegir(K, [X|Xs], [X|Ys]) :-
    K > 0, K1 is K - 1,
    elegir(K1, Xs, Ys).
elegir(K, [_|Xs], Ys) :-
    K > 0,
    elegir(K, Xs, Ys).
