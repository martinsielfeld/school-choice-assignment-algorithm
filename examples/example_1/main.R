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
## Source: Datos Abiertos MINEDUC
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
packages <- c("data.table","stringr","SyncRNG")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)){install.packages(new_packages)}
sapply(packages,require,character.only=T,quietly=T)

## Load data:
{
  vacancies = fread(paste0(mainFolder,'/data/example_1/vacancies.csv'))
  applications = fread(paste0(mainFolder,'/data/example_1/applications.csv'))
}

## Load function:
source(paste0(mainFolder,'/functions/baseDA.R'),encoding='UTF-8')
source(paste0(mainFolder,'/functions/baseBoston.R'),encoding='UTF-8')

## Execute base DA:
results_DA = baseDA(apps=applications,vacs=vacancies,get_cutoffs=T)

## Execute base Boston:
results_Boston = baseBoston(apps=applications,vacs=vacancies,get_cutoffs=T)

## Check:
{
  ## Prep results:
  results = unique(applications[,.(applicant_id,grade_id)])
  results = merge(results,results_DA$assignment[,.(applicant_id,ranking_DA=ranking)],by='applicant_id',all.x=T)
  results = merge(results,results_Boston$assignment[,.(applicant_id,ranking_Boston=ranking)],by='applicant_id',all.x=T)
  results[ranking_DA > 5,ranking_DA := 5]
  results[ranking_Boston > 5,ranking_Boston := 5]
  results[is.na(ranking_DA),ranking_DA:=6]
  results[is.na(ranking_Boston),ranking_Boston:=6]
  results[,ranking_DA:=factor(ranking_DA,levels=1:6,labels=c(1:4,'5 o menor','Sin asignacion'))]
  results[,ranking_Boston:=factor(ranking_Boston,levels=1:6,labels=c(1:4,'5 o menor','Sin asignacion'))]
  
  ## Check results:
  table(results$ranking_DA,dnn='DA')
  table(results$ranking_Boston,dnn='Boston')
  table(results$ranking_DA,results$ranking_Boston,dnn=c('DA','Boston'))
  
  ## Cutoffs:
  results_DA$cutoffs
  results_Boston$cutoffs
}

## Execute base DA:
iters_DA = baseDA(apps=applications,vacs=vacancies,get_cutoffs=T,iters=200)

## Cutoff distribution:
{
  cutoffs = iters_DA$cutoffs
  cutoffs[,count:=sum(!not_filled),by=.(program_id)]
  cutoffs[,sd:=sd(score),by=.(program_id)]
  
  ggplot(cutoffs[program_id == 17,],aes(x=score)) +
    stat_ecdf(geom = "step",pad = T) +
    scale_x_continuous(breaks = seq(1,5,0.002)) +
    labs(title = 'Cummulative cutoff distribution',
         subtitle = 'Program 17',
         x=NULL,y=NULL) +
    theme_bw() +
    theme(plot.title.position = 'plot')
  
  ggplot(cutoffs[program_id == 28,],aes(x=score)) +
    stat_ecdf(geom = "step",pad = T) +
    scale_x_continuous(breaks = seq(1,5,0.01)) +
    labs(title = 'Cummulative cutoff distribution',
         subtitle = 'Program 28',
         x=NULL,y=NULL) +
    theme_bw() +
    theme(plot.title.position = 'plot')
  
  ggplot(cutoffs[program_id == 119,],aes(x=score)) +
    stat_ecdf(geom = "step",pad = T) +
    scale_x_continuous(breaks = seq(1,5,0.01)) +
    labs(title = 'Cummulative cutoff distribution',
         subtitle = 'Program 119',
         x=NULL,y=NULL) +
    theme_bw() +
    theme(plot.title.position = 'plot')
  
  ggplot(cutoffs[program_id == 55759,],aes(x=score)) +
    stat_ecdf(geom = "step",pad = T) +
    scale_x_continuous(breaks = seq(1,5,0.01)) +
    labs(title = 'Cummulative cutoff distribution',
         subtitle = 'Program 55759',
         x=NULL,y=NULL) +
    theme_bw() +
    theme(plot.title.position = 'plot')
  
  ggplot(cutoffs[program_id == 79065,],aes(x=score)) +
    stat_ecdf(geom = "step",pad = T) +
    scale_x_continuous(breaks = seq(1,5,0.2)) +
    labs(title = 'Cummulative cutoff distribution',
         subtitle = 'Program 79065',
         x=NULL,y=NULL) +
    theme_bw() +
    theme(plot.title.position = 'plot')
}




