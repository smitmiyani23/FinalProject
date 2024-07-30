# start from the rstudio/plumber image
FROM rocker/r-ver:4.4.1

# install the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y  libssl-dev  libcurl4-gnutls-dev  libpng-dev



#Alternative packages installation
RUN R -e 'install.packages("remotes")' 
RUN Rscript -e 'remotes::install_version("tidyverse", version = "2.0.0", upgrade="never")'
RUN Rscript -e 'remotes::install_version("caret", version = "6.0-94", upgrade="never")'
RUN Rscript -e 'remotes::install_version("ggplot2", version = "3.5.1", upgrade="never")'
RUN Rscript -e 'remotes::install_version("plotly", version = "4.10.4", upgrade="never")'
RUN Rscript -e 'remotes::install_version("reshape2", version = "1.4.4", upgrade="never")'
RUN Rscript -e 'remotes::install_version("Metrics", version = "0.1.4", upgrade="never")'
RUN Rscript -e 'remotes::install_version("ranger", version = "0.16.0", upgrade="never")'



# copy everything from the current directory into the container
COPY myAPI.R myAPI.R

# open port to traffic
EXPOSE 8000

#
RUN apt update -qq \
&& apt install --yes --no-install-recommends \
r-cran-plumber

# when the container starts, starting the myAPI script

ENTRYPOINT ["R", "-e", \
    "library(plumber); library(tidyverse); library(caret); library(ggplot2);\
    library(plotly); library(reshape2); library(Metrics); library(ranger);\
    plumb('myAPI.R')$run(port=8000, host='0.0.0.0')"]