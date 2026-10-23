# Imagen oficial de SWI-Prolog (incluye library(http/*)).
FROM swipl:stable

# UTF-8 para que acentos y ñ funcionen en conocimiento.pl y en las respuestas JSON.
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PORT=8080

WORKDIR /app

# Usuario sin privilegios (buena práctica de seguridad).
RUN useradd --system --uid 10001 --no-create-home app

COPY prolog/ ./prolog/
COPY public/ ./public/

USER app

# Render/Railway inyectan PORT; server.pl lo lee y escucha en 0.0.0.0:$PORT.
EXPOSE 8080

CMD ["swipl", "prolog/server.pl"]
