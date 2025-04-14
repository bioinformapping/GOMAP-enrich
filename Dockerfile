FROM rocker/shiny:4.4

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update -qq \
  && apt-get install --yes \
    curl \
    libgdal-dev \
    libproj-dev \
    libudunits2-dev \
    libxml2-dev \
    libglpk40 \
    libfribidi-dev \
    libglpk-dev \
    libharfbuzz-dev \
  && rm -rf /var/lib/apt/lists/*

# Remove examples
WORKDIR /srv/shiny-server
RUN rm -rf *

# Install R dependencies
COPY --chown=shiny:shiny .Rprofile renv.lock ./
COPY --chown=shiny:shiny renv/activate.R renv/
# COPY --chown=shiny:shiny .Rprofile ./

# RUN sudo -u shiny Rscript -e 'renv::restore(clean = TRUE)'

RUN sudo -u shiny Rscript -e 'options(renv.config.pak.enabled = TRUE); renv::restore(clean = TRUE)'

RUN sudo mkdir /srv/shiny-server/app_cache && chown shiny:shiny /srv/shiny-server/app_cache
RUN chown -R shiny:shiny /usr/local/lib/R/


# Copy app
COPY --chown=shiny:shiny app.R ./
COPY --chown=shiny:shiny config.yml ./
COPY --chown=shiny:shiny rhino.yml ./
COPY --chown=shiny:shiny app app/

COPY --chown=shiny:shiny docker/shiny-server.conf /etc/shiny-server/
USER shiny

