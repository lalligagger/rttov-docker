# Use Python3 base
FROM python:3

# Copy files, including unpacked RTTOV source, from local system
COPY . /tmp

# ------ Environment variables ------ #

# Determines which HDF5 to build
ENV HDF5_MINOR_REL      hdf5-1.10.5 
ENV HDF5_SRC_URL   	http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10                  

# RTTOV variables
ENV RTTOV_INSTALL_DIR	rttov131
ENV RTTOV_MINOR_REL	rttov131

# Library path
ENV LD_LIBRARY_PATH	/usr/local/hdf5/lib

# Install miniconda
# From: https://stackoverflow.com/questions/58269375/how-to-install-packages-with-miniconda-in-dockerfile
ENV PATH="/root/miniconda3/bin:$PATH"
ARG PATH="/root/miniconda3/bin:$PATH"
RUN apt-get update

RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
RUN conda --version

# Create conda environment "rttov"
RUN cd /tmp && conda env create -f environment.yml

# Build the image
RUN apt-get update && apt-get -y install gfortran libhdf5-serial-dev python-dev; \
	apt-get update && apt-get -y install build-essential; \
	cd /tmp && ./build_hdf5; \
	cd /tmp && ./build_rttov; \
	rm -r /tmp/*