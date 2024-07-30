# start from the rstudio/plumber image
FROM rocker/r-ver:4.4.1

# install the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y  libssl-dev  libcurl4-gnutls-dev  libpng-dev



#Alternative packages installation
RUN R -e 'install.packages("remotes")' 
RUN R -e 'install.packages("tidyverse")'
RUN R -e 'install.packages("caret")'
RUN R -e 'install.packages("ggplot2")'
RUN R -e 'install.packages("plotly")'
RUN R -e 'install.packages("reshape2")'
RUN R -e 'install.packages("Metrics")'
RUN R -e 'install.packages("ranger")'
RUN R -e "install.packages('plumber')"



# Set the working directory inside the container
WORKDIR /app

# Copy specific files from the current directory to the container
COPY myAPI.R /app/
COPY Dockerfile /app/
COPY diabetes_binary_health_indicators_BRFSS2015.csv /app/
COPY Docker_project.Rproj /app/

# open port to traffic
EXPOSE 8000

# when the container starts, starting the myAPI script

ENTRYPOINT ["R", "-e", \
    "pr <- plumber::plumb('myAPI.R'); pr$run(host='0.0.0.0', port=8000)"]