![Logo](bruker2batman.png)

# Bruker2BATMAN
Version: 1.0

## Short Description
This tool converts Bruker raw files into tabulated txt file for BATMAN.

## Description
This tool converts Bruker raw files into tabulated txt file for BATMAN.


## Key features
- Format Converter

## Functionality

- Format Converter for BATMAN

## Approaches

- Metabolomics
  
## Instrument Data Types

- NMR / 1D NMR

## Tool Authors 

- Originally developed by Tim Ebbels and Jie Hao (Imperial College London)
- Maintained by Jianliang and Vagelis (Imperial College London)

## Container Contributors

- Jianliang and Vagelis

## Git Repository

- https://github.com/jianlianggao/container-bruker2batman.git

 
## Installation

in the folder where Dockerfile is hosted and run
`docker build -t <your_docker_image_name>:latest .`

## Usage Instructions
Copy Bruker raw data files into `<path/to/data/folder>`

Change work dir to `<path/to/data/folder>` and run

`docker run -v $PWD:/data -ti <your_docker_image_name> -i /data/`

### Galaxy usage

A rudimentary Galaxy node description is included as `bruker2batman.xml`.


