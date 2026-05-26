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
  libglpk-dev \
  libfribidi-dev \
  libharfbuzz-dev \
  libuv1-dev \
  && rm -rf /var/lib/apt/lists/*

# Remove examples
WORKDIR /srv/shiny-server
RUN rm -rf *

# Set up user-level R compilation configuration to prevent OOM
RUN mkdir -p /home/shiny/.R && chown -R shiny:shiny /home/shiny
COPY --chown=shiny:shiny docker/Makevars /home/shiny/.R/Makevars

# Install R dependencies
COPY --chown=shiny:shiny .Rprofile renv.lock ./
COPY --chown=shiny:shiny renv/activate.R renv/

# Temporarily rename .Rprofile so it doesn't override Makevars and MAKEFLAGS during restore
RUN mv .Rprofile .Rprofile.bak

RUN sudo -u shiny Rscript -e 'source("renv/activate.R"); options(Ncpus = 1, renv.config.install.parallel = FALSE); renv::restore(clean = TRUE)'

# Restore .Rprofile for application runtime
RUN mv .Rprofile.bak .Rprofile

RUN sudo mkdir /srv/shiny-server/app_cache && chown shiny:shiny /srv/shiny-server/app_cache
RUN chown -R shiny:shiny /usr/local/lib/R/

# Copy app
COPY --chown=shiny:shiny app.R ./
COPY --chown=shiny:shiny config.yml ./
COPY --chown=shiny:shiny rhino.yml ./
COPY --chown=shiny:shiny app app/

COPY --chown=shiny:shiny docker/shiny-server.conf /etc/shiny-server/
