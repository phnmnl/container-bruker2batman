FROM ubuntu:16.04

MAINTAINER PhenoMeNal-H2020 Project ( phenomenal-h2020-users@googlegroups.com )

LABEL software.version="1.0"

LABEL version="1.0"
LABEL software="Bruker2BATMAN"

# Install required packages and Bruker2BATMAN script
RUN apt-get update && apt-get install -y --no-install-recommends r-base r-base-dev \
                              libcurl4-openssl-dev libssl-dev && \
    echo 'options("repos"="http://cran.rstudio.com", download.file.method = "libcurl")' >> /etc/R/Rprofile.site && \
    R -e "install.packages(c('getopt','optparse'))" && \
    apt-get purge -y r-base-dev libcurl4-openssl-dev libssl-dev && \
    apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# Add bruker2batman.R to /usr/local/bin
ADD bruker2batman.R /usr/local/bin
RUN chmod 0755 /usr/local/bin/bruker2batman.R

# Define entry point, useful for general use
ENTRYPOINT ["bruker2batman.R"]
