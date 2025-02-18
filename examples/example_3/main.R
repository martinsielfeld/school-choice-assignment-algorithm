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

## Install and load packages:
packages <- c("data.table","ggplot2","stringr","scales","SyncRNG")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)){install.packages(new_packages)}
sapply(packages,require,character.only=T,quietly=T)

## Load function:
source('src/baseSAA.R',encoding='UTF-8')

## Load data:
{
  ## For algorithm:
  vacancies = fread('data/example_3/vacancies_r.csv')
  applications = fread('data/example_3/applications_r.csv')
}

## Prep data:
{
  ## Soft Boston:
  softBoston = applications[,.(applicant_id,grade_id,program_id,ranking,quota_id,
                               priority_profile=priority_profile_ori)]
  
  ## DA:
  baseDA = applications[,.(applicant_id,grade_id,program_id,ranking,quota_id,
                           priority_profile=priority_profile_edi)]
}

## Lets compare Soft Boston vs. DA assignment - no transfer:
{
  ## Soft Boston:
  results_1 = baseSAA(apps=softBoston,vacs=vacancies,get_cutoffs=F,transfer_capacity=F,
                      iters=100)
  
  ## DA:
  results_2 = baseSAA(apps=baseDA,vacs=vacancies,get_cutoffs=F,transfer_capacity=F,
                      iters=100)
  
  ## Compare results:
  results_1 = results_1$assignment
  results_2 = results_2$assignment
  results_1 = merge(results_1,applications[,.(applicant_id,grade_id,program_id)],by=c('applicant_id','program_id'))
  results_2 = merge(results_2,applications[,.(applicant_id,grade_id,program_id)],by=c('applicant_id','program_id'))
  
  table(results_1[iter<11]$iter,results_1[iter<11]$grade_id)
  table(results_2[iter<11]$iter,results_2[iter<11]$grade_id)
  
  results_1 = results_1[,.(Boston=.N),by=.(iter,program_id)]
  results_2 = results_2[,.(DA=.N),by=.(iter,program_id)]
  results = NULL
  for(i in 1:100){
    a = merge(vacancies,results_1[iter == i,],by='program_id',all.x=T)
    a[,iter := i,]
    results = rbind(results,a)
    rm(a)
  }
  results = merge(results,results_2,by=c('iter','program_id'),all.x=T)
  results = merge(results,manuel,by.x=c('iter','school_id','grade_id'),by.y=c('iter','program_id','grade_id'),all.x=T)
  results[is.na(results)] = 0
  
  ## Check results:
  results[,.(Boston=sum(Boston),DA=sum(DA)),by=.(iter)]
  
  ## Plot:
  ggplot(results[program_id == 321]) +
    geom_density(aes(x=DA,color='DA')) +
    geom_density(aes(x=manuel,color='Manuel'))
  
  ## Soft Boston:
  results_3 = baseSAA(apps=softBoston,vacs=vacancies,get_cutoffs=F,transfer_capacity=F,
                      get_probs=T,get_assignment=F,iters=100)
  
  ## DA:
  results_4 = baseSAA(apps=baseDA,vacs=vacancies,get_cutoffs=F,transfer_capacity=F,
                      get_probs=T,get_assignment=F,iters=100)
}

