:- encoding(utf8).
/*  server.pl — Servidor HTTP del "Asesor de Inscripción de Materias"
    ---------------------------------------------------------------
    Sirve (1) la API JSON y (2) los archivos estáticos de /public.
    El razonamiento NO ocurre aquí: este archivo solo valida la entrada,
    llama a los predicados de conocimiento.pl y convierte el resultado a JSON.

    Ejecución:   swipl prolog/server.pl          (puerto = $PORT, por defecto 8080)

    Seguridad:
      * Nunca se construye ni se ejecuta código a partir de texto del usuario.
        Los IDs de materia se comparan (como cadenas) contra los átomos que ya
        existen en materia_catalogo/3; jamás se usa atom_to_term/term_to_atom ni
        se crean átomos nuevos con texto del usuario.
      * Lista blanca de tipos de consulta, límites de tamaño y de resultados,
        y límite de tiempo por consulta.
*/

:- module(server, [iniciar/0, iniciar/1]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(time)).
:- use_module(library(solution_sequences)).

% ---------------------------------------------------------------------------
% Configuración
% ---------------------------------------------------------------------------

limite_resultados(200).        % máximo de soluciones devueltas
limite_explicaciones(20).      % máximo de materias explicadas por consulta
limite_tiempo(5).              % segundos por consulta
limite_cuerpo(65536).          % bytes máximos del cuerpo JSON
max_aprobadas(200).            % tamaño máximo de la lista "aprobadas"
puerto_por_defecto(8080).

tipos_validos([disponibles, bloqueadas, ruta, combinaciones]).

:- dynamic base_dir/1.

% Directorio donde vive este archivo + carga de la base de conocimiento.
% conocimiento.pl se carga en el módulo `user`; si el estudiante lo escribe
% como módulo con export, también funciona (se importa a `user`).
:- prolog_load_context(directory, Dir),
   asserta(base_dir(Dir)),
   directory_file_path(Dir, 'conocimiento.pl', Archivo),
   (   exists_file(Archivo)
   ->  load_files(user:Archivo, [if(not_loaded), silent(true), encoding(utf8)])
   ;   print_message(warning, format("No se encontró ~w", [Archivo]))
   ).

% ---------------------------------------------------------------------------
% Rutas HTTP
% ---------------------------------------------------------------------------

:- http_handler(root(health),           health,        []).
:- http_handler(root(api/materias),     materias,      []).
:- http_handler(root(api/consultar),    consultar,     []).
:- http_handler(root(api),              api_no_existe, [prefix]).
:- http_handler(root(.),                estatico,      [prefix]).

% --- /health ---------------------------------------------------------------

health(_Request) :-
    (   predicate_property(user:materia_catalogo(_,_,_), defined)
    ->  Cargado = true
    ;   Cargado = false
    ),
    reply_json_dict(_{status:"ok", conocimiento:Cargado}).

% --- GET /api/materias -----------------------------------------------------

materias(Request) :-
    con_errores(materias_(Request)).

materias_(Request) :-
    metodo(Request, [get, head]),
    call_with_time_limit(5, catalogo(Cat)),
    maplist(catalogo_json, Cat, Lista),
    reply_json_dict(_{materias:Lista}).

catalogo_json(m(Id, Nombre, Sem), _{id:IdS, nombre:Nombre, semestre:Sem}) :-
    texto(Id, IdS).

% --- POST /api/consultar ---------------------------------------------------

consultar(Request) :-
    con_errores(consultar_(Request)).

consultar_(Request) :-
    metodo(Request, [post]),
    leer_cuerpo(Request, Dict),
    limite_tiempo(T),
    call_with_time_limit(T, (
        catalogo(Cat),
        validar(Dict, Cat, q(Tipo, Apr, Max, Meta)),
        evaluar(Tipo, Apr, Max, Meta, Cat, Resp)
    )),
    reply_json_dict(Resp).

% --- /api/* desconocido ----------------------------------------------------

api_no_existe(_Request) :-
    responder_error(404, 'Ruta de API no encontrada.').

% --- Archivos estáticos (public/) -------------------------------------------

estatico(Request) :-
    base_dir(D),
    directory_file_path(D, '../public', P0),
    absolute_file_name(P0, Publico, [file_type(directory)]),
    (   catch(http_reply_from_files(Publico, [], Request), error(_, _), fail)
    ->  true
    ;   memberchk(path(Ruta), Request),
        throw(http_reply(not_found(Ruta)))
    ).

% ---------------------------------------------------------------------------
% Manejo de errores y respuestas
% ---------------------------------------------------------------------------

falla(Codigo, Mensaje) :-
    throw(api_error(Codigo, Mensaje)).

con_errores(Goal) :-
    catch(Goal, E, error_respuesta(E)).

error_respuesta(api_error(Codigo, Mensaje)) :- !,
    responder_error(Codigo, Mensaje).
error_respuesta(time_limit_exceeded) :- !,
    responder_error(504, 'La consulta tardó demasiado y fue cancelada. Intente con menos materias o un máximo menor.').
error_respuesta(error(existence_error(procedure, PI), _)) :- !,
    format(string(Msg),
           'La base de conocimiento aún no implementa el predicado ~q.', [PI]),
    responder_error(503, Msg).
error_respuesta(E) :-
    % El detalle va a la bitácora del servidor, no al cliente.
    print_message(error, E),
    responder_error(500, 'Error interno controlado al evaluar la consulta.').

responder_error(Codigo, Mensaje) :-
    texto(Mensaje, MsgS),
    reply_json_dict(_{ok:false, error:MsgS}, [status(Codigo)]).

metodo(Request, Permitidos) :-
    memberchk(method(M), Request),
    (   memberchk(M, Permitidos)
    ->  true
    ;   falla(405, 'Método HTTP no permitido para esta ruta.')
    ).

leer_cuerpo(Request, Dict) :-
    limite_cuerpo(Max),
    (   memberchk(content_length(L), Request)
    ->  (   L =< Max
        ->  true
        ;   falla(413, 'El cuerpo de la petición es demasiado grande.')
        )
    ;   falla(411, 'Falta la cabecera Content-Length.')
    ),
    catch(http_read_json_dict(Request, Dict, []), _, fail),
    !.
leer_cuerpo(_, _) :-
    falla(400, 'El cuerpo debe ser JSON válido (Content-Type: application/json).').

% ---------------------------------------------------------------------------
% Catálogo (validado)
% ---------------------------------------------------------------------------
% catalogo(-Lista): Lista de m(IdAtomo, NombreString, SemestreEntero) sin duplicados.

catalogo(Cat) :-
    findall(m(Id, N, S), user:materia_catalogo(Id, N, S), L0),
    include(entrada_valida, L0, L1),
    quitar_duplicados(L1, [], Cat0),
    (   Cat0 == []
    ->  falla(503, 'La base de conocimiento no define materias (materia_catalogo/3 no tiene hechos).')
    ;   maplist(normalizar_entrada, Cat0, Cat)
    ).

entrada_valida(m(Id, _, S)) :- atom(Id), integer(S).

normalizar_entrada(m(Id, N0, S), m(Id, N, S)) :- texto(N0, N).

quitar_duplicados([], _, []).
quitar_duplicados([m(Id,N,S)|T], Vistos, R) :-
    (   memberchk(Id, Vistos)
    ->  quitar_duplicados(T, Vistos, R)
    ;   R = [m(Id,N,S)|R1],
        quitar_duplicados(T, [Id|Vistos], R1)
    ).

% ---------------------------------------------------------------------------
% Validación de la entrada
% ---------------------------------------------------------------------------

validar(D, Cat, q(Tipo, Apr, Max, Meta)) :-
    (   is_dict(D)
    ->  true
    ;   falla(400, 'El cuerpo de la petición debe ser un objeto JSON.')
    ),
    validar_tipo(D, Tipo),
    validar_aprobadas(D, Cat, Apr),
    validar_max(D, Max),
    validar_meta(D, Tipo, Cat, Meta).

validar_tipo(D, Tipo) :-
    tipos_validos(Ts),
    (   get_dict(tipo, D, T), string(T)
    ->  true
    ;   falla(400, 'El campo "tipo" es obligatorio y debe ser texto.')
    ),
    (   member(Tipo, Ts), atom_string(Tipo, T)
    ->  true
    ;   atomic_list_concat(Ts, ', ', Lista),
        format(string(Msg), 'Tipo de consulta no válido. Valores permitidos: ~w.', [Lista]),
        falla(400, Msg)
    ).

validar_aprobadas(D, Cat, Apr) :-
    (   get_dict(aprobadas, D, L), is_list(L)
    ->  true
    ;   falla(400, 'El campo "aprobadas" es obligatorio y debe ser una lista (puede estar vacía).')
    ),
    max_aprobadas(MaxA),
    length(L, N),
    (   N =< MaxA
    ->  true
    ;   falla(400, 'La lista "aprobadas" es demasiado larga.')
    ),
    maplist(id_valido('aprobadas', Cat), L, Apr),
    (   is_set(Apr)
    ->  true
    ;   falla(400, 'La lista "aprobadas" contiene materias repetidas.')
    ).

validar_max(D, Max) :-
    (   get_dict(max, D, M0)
    ->  (   integer(M0), between(1, 10, M0)
        ->  Max = M0
        ;   falla(400, 'El campo "max" debe ser un entero entre 1 y 10.')
        )
    ;   Max = 5
    ).

validar_meta(D, Tipo, Cat, Meta) :-
    (   get_dict(meta, D, S), S \== null, S \== ""
    ->  id_valido('meta', Cat, S, Meta)
    ;   Tipo == ruta
    ->  falla(400, 'La consulta "ruta" requiere el campo "meta" (materia objetivo).')
    ;   Meta = none
    ).

% id_valido(+Campo, +Catalogo, +CadenaUsuario, -Atomo)
% Compara la cadena con átomos YA existentes; no crea átomos nuevos.
id_valido(Campo, Cat, S, A) :-
    (   string(S),
        string_length(S, Len), Len =< 64,
        member(m(A, _, _), Cat),
        atom_string(A, S)
    ->  true
    ;   format(string(Msg),
               'El campo "~w" contiene un identificador de materia que no existe en el catálogo.',
               [Campo]),
        falla(400, Msg)
    ).

% ---------------------------------------------------------------------------
% Evaluación: llama a conocimiento.pl
% ---------------------------------------------------------------------------

evaluar(Tipo, Apr, Max, Meta, Cat, Resp) :-
    resolver(Tipo, Apr, Max, Meta, Cat, R),
    get_dict(explicar, R, Explicar),
    explicaciones(Explicar, Apr, Cat, Exps),
    atom_string(Tipo, TipoS),
    get_dict(resultados, R, Res),
    get_dict(total, R, Total),
    get_dict(truncado, R, Trunc),
    get_dict(mensaje, R, Mensaje),
    Resp = _{ ok:true, tipo:TipoS, total:Total, truncado:Trunc,
              mensaje:Mensaje, resultados:Res, explicacion:Exps }.

% soluciones(+Plantilla, :Goal, -Lista, -Truncado)
soluciones(Plantilla, Goal, Lista, Truncado) :-
    limite_resultados(Lim),
    Lim1 is Lim + 1,
    findall(Plantilla, limit(Lim1, distinct(Plantilla, Goal)), L0),
    length(L0, N),
    (   N > Lim
    ->  length(Lista, Lim), append(Lista, _, L0), Truncado = true
    ;   Lista = L0, Truncado = false
    ).

% --- disponibles ---
resolver(disponibles, Apr, _Max, _Meta, Cat, R) :-
    soluciones(M, user:disponible(Apr, M), Ms, Trunc),
    maplist(obj_materia(Cat), Ms, Objs),
    length(Ms, Total),
    mensaje_vacio(Total, 'Con las materias aprobadas indicadas no hay materias disponibles para cursar.', Msg),
    R = _{resultados:Objs, total:Total, truncado:Trunc, mensaje:Msg, explicar:Ms}.

% --- bloqueadas ---
resolver(bloqueadas, Apr, _Max, _Meta, Cat, R) :-
    findall(M-F,
            ( member(m(M,_,_), Cat),
              \+ memberchk(M, Apr),
              once(user:bloqueada(Apr, M, F)) ),
            Pares0),
    limite_resultados(Lim),
    (   length(Pares0, N0), N0 > Lim
    ->  length(Pares, Lim), append(Pares, _, Pares0), Trunc = true
    ;   Pares = Pares0, Trunc = false
    ),
    maplist(obj_bloqueada(Cat), Pares, Objs),
    pairs_keys(Pares, Ms),
    length(Pares, Total),
    mensaje_vacio(Total, 'No hay materias bloqueadas con los datos indicados.', Msg),
    R = _{resultados:Objs, total:Total, truncado:Trunc, mensaje:Msg, explicar:Ms}.

% --- ruta ---
resolver(ruta, Apr, _Max, Meta, Cat, R) :-
    (   once(user:ruta(Apr, Meta, Pasos))
    ->  (   is_list(Pasos), maplist(is_list, Pasos)
        ->  true
        ;   print_message(error, format("ruta/3 devolvió un formato inesperado: ~q", [Pasos])),
            falla(500, 'ruta/3 devolvió un formato inesperado (se esperaba lista de listas).')
        ),
        numerar_semestres(Pasos, Cat, 1, Objs),
        flatten(Pasos, Planas),
        length(Pasos, Total),
        mensaje_vacio(Total, 'La materia meta ya está aprobada: no se requieren más semestres.', Msg),
        R = _{resultados:Objs, total:Total, truncado:false, mensaje:Msg,
              explicar:[Meta|Planas]}
    ;   R = _{resultados:[], total:0, truncado:false,
              mensaje:"No se encontró una ruta hacia la materia meta con los datos indicados.",
              explicar:[]}
    ).

% --- combinaciones ---
resolver(combinaciones, Apr, Max, _Meta, Cat, R) :-
    soluciones(C, ( user:combinacion(Apr, Max, C), is_list(C), C \== [] ), Cs, Trunc),
    maplist(obj_combinacion(Cat), Cs, Objs),
    length(Cs, Total),
    mensaje_vacio(Total, 'No hay combinaciones posibles con los datos indicados.', Msg),
    primeras(5, Cs, Primeras),
    flatten(Primeras, Ms),
    R = _{resultados:Objs, total:Total, truncado:Trunc, mensaje:Msg, explicar:Ms}.

mensaje_vacio(0, Texto, Msg) :- !, texto(Texto, Msg).
mensaje_vacio(_, _, "").

primeras(N, L, P) :-
    (   length(L, Len), Len > N
    ->  length(P, N), append(P, _, L)
    ;   P = L
    ).

numerar_semestres([], _, _, []).
numerar_semestres([Ms|T], Cat, I, [_{semestre:I, materias:Objs}|R]) :-
    maplist(obj_materia(Cat), Ms, Objs),
    I1 is I + 1,
    numerar_semestres(T, Cat, I1, R).

obj_combinacion(Cat, Ms, _{materias:Objs, cantidad:N}) :-
    maplist(obj_materia(Cat), Ms, Objs),
    length(Ms, N).

obj_bloqueada(Cat, M-F0, Obj) :-
    obj_materia(Cat, M, Base),
    (   is_list(F0) -> F = F0 ; F = [F0] ),
    maplist(obj_materia(Cat), F, FObjs),
    put_dict(faltantes, Base, FObjs, Obj).

obj_materia(Cat, Id, _{id:IdS, nombre:Nombre, semestre:Sem}) :-
    (   memberchk(m(Id, N0, S0), Cat)
    ->  Nombre = N0, Sem = S0
    ;   texto(Id, Nombre), Sem = null
    ),
    texto(Id, IdS).

% --- Explicaciones (opcionales) ---
explicaciones(Ms0, Apr, Cat, Exps) :-
    (   predicate_property(user:explicacion(_,_,_), defined)
    ->  list_to_set(Ms0, Ms1),
        limite_explicaciones(L),
        primeras(L, Ms1, Ms),
        findall(E,
                ( member(M, Ms),
                  catch(once(user:explicacion(M, Apr, Razon)), error(_,_), fail),
                  razon_lista(Razon, Rs),
                  obj_materia(Cat, M, Obj),
                  E = _{materia:Obj, razon:Rs} ),
                Exps)
    ;   Exps = []
    ).

razon_lista(R, Rs) :-
    (   is_list(R) -> L = R ; L = [R] ),
    maplist(texto, L, Rs).

% ---------------------------------------------------------------------------
% Utilidades
% ---------------------------------------------------------------------------

% texto(+Termino, -Cadena): siempre devuelve una cadena. Importante para que
% átomos como true/false/null no se serialicen como literales JSON.
texto(X, S) :-
    (   string(X) -> S = X
    ;   format(string(S), '~w', [X])
    ).

% ---------------------------------------------------------------------------
% Arranque
% ---------------------------------------------------------------------------

:- initialization(iniciar, main).

iniciar :-
    puerto(Puerto),
    iniciar(Puerto).

iniciar(Puerto) :-
    on_signal(term, _, termino),
    on_signal(int,  _, termino),
    http_server(http_dispatch, [port('0.0.0.0':Puerto), workers(4)]),
    format(user_error, "Asesor de Inscripcion escuchando en http://0.0.0.0:~w~n", [Puerto]),
    thread_get_message(_).          % bloquea el hilo principal

termino(_Senal) :-
    halt(0).

puerto(Puerto) :-
    puerto_por_defecto(Def),
    (   getenv('PORT', P0),
        catch(atom_number(P0, P), _, fail),
        integer(P), between(1, 65535, P)
    ->  Puerto = P
    ;   getenv('PORT', _)
    ->  format(user_error, "PORT inválido; usando ~w~n", [Def]),
        Puerto = Def
    ;   Puerto = Def
    ).
