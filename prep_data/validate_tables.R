#####################################################################
##
## Prep data
##
## The following code prepares the data for the School Assignment 
## Algorithm examples
##
## Author: Martin Sielfeld
## Last editor: Martin Sielfeld
##
## Created: 2024/09/12
## Last edition: 2024/09/12
##
## Source: Datos Abiertos MINEDUC - SAE 2020
##
#####################################################################

## Settings:
rm(list = ls())
options(scipen = 999)

## Set working directory:
if(Sys.info()["user"] == 'mds237'){
  mainFolder = 'C:/Users/mds237/Desktop/Yale/Codes/school-choice-assignment-algorithm'
} else if(Sys.info()["user"] == ''){ ## Add user
  mainFolder = '' ## Add folder to data folder
}

## Install and load packages:
packages <- c("data.table","stringr")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)){install.packages(new_packages)}
sapply(packages,require,character.only=T,quietly=T)

## Check example 1 iputs:
{
  ## Load:
  programs1_r = fread(paste0(mainFolder,'/data/example_1/vacancies_r.csv'),integer64='character')
  applications1_r = fread(paste0(mainFolder,'/data/example_1/applications_r.csv'),integer64='character')
  programs1_py = fread(paste0(mainFolder,'/data/example_1/vacancies_py.csv'),integer64='character')
  applications1_py = fread(paste0(mainFolder,'/data/example_1/applications_py.csv'),integer64='character')
  
  ## Check programs:
  nrow(unique(rbind(programs1_py,programs1_r))) == nrow(programs1_r)
  nrow(unique(rbind(programs1_py,programs1_r))) == nrow(programs1_py)
  
  ## Check applications:
  nrow(unique(rbind(applications1_py,applications1_r))) == nrow(applications1_r)
  nrow(unique(rbind(applications1_py,applications1_r))) == nrow(applications1_py)
}
