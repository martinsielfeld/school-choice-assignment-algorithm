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
packages <- c("data.table","stringr","scales","SyncRNG")
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

## Base model:
{
  ## Execute base DA:
  results_DA = baseDA(apps=applications,vacs=vacancies)
  
  ## Execute base Boston:
  results_Boston = baseBoston(apps=applications,vacs=vacancies)
  
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
  }
}

## Base model without original random order:
{
  ## Drop lottery number:
  applications[,lottery_number:=NULL]
  
  ## Execute base DA:
  results_DA = baseDA(apps=applications,vacs=vacancies)
  
  ## Execute base Boston:
  results_Boston = baseBoston(apps=applications,vacs=vacancies)
  
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
  }
}

## Faster base model without original random order:
{
  ## Execute base DA:
  results_DA = baseDA(apps=applications,vacs=vacancies,rand_type='local')
  
  ## Execute base Boston:
  results_Boston = baseBoston(apps=applications,vacs=vacancies,rand_type='local')
  
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
  }
}

## ## Cutoff distribution and assignment probability:
{
  ## Execute base DA:
  iters_DA = baseDA(apps=applications,vacs=vacancies,get_cutoffs=T,get_assignment=F,
                    iters=200,rand_type='local')
  
  ## Execute base Boston:
  iters_Boston = baseBoston(apps=applications,vacs=vacancies,get_cutoffs=T,get_assignment=F,
                            iters=200,rand_type='local')
  
  ## Cutoff distribution:
  {
    cutoffs = iters_DA$cutoffs
    cuts = cutoffs[,.(count=sum(!not_filled),sd=sd(upper_cutoff)),by=.(program_id)]
    
    ggplot(cutoffs[program_id == 44247,],) +
      stat_ecdf(aes(x=lower_cutoff,color='Lower Cutoff'),geom = "step") +
      stat_ecdf(aes(x=upper_cutoff,color='Upper Cutoff'),geom = "step") +
      scale_y_continuous(breaks=seq(0,1,0.1),labels=number_format(suffix='%',scale=100)) +
      scale_x_continuous(breaks=seq(1,5,0.05)) +
      labs(title = 'Cummulative cutoff distribution',
           subtitle = 'Program 44247 - 200 simulations',
           x='Cutoff distribution',y='Cummulative density',color=NULL) +
      theme_bw() +
      theme(plot.title.position = 'plot',
            legend.position=c(0.1,0.9),
            legend.background = element_rect(color='black'))
  }
}
