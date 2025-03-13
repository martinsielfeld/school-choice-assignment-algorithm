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

## Functions:
specify_decimal <- function(x, k) trimws(format(round(x, k), nsmall=k))

## Load data:
{
  ## Inputs
  applications = fread('data/example_3/applications_r.csv')
  
  ## Results
  bpyv1 = fread('data/example_3/results_boston_py_v1.csv')
  brv1 = fread('data/example_3/results_boston_r_v1.csv')
  dpyv1 = fread('data/example_3/results_da_py_v1.csv')
  drv1 = fread('data/example_3/results_da_r_v1.csv')
  bpyv2 = fread('data/example_3/results_boston_py_v2.csv')
  brv2 = fread('data/example_3/results_boston_r_v2.csv')
  dpyv2 = fread('data/example_3/results_da_py_v2.csv')
  drv2 = fread('data/example_3/results_da_r_v2.csv')
}

## Get length:
{
  maxl = max(str_length(c(bpyv1$score,bpyv2$score,brv1$score,brv2$score,
                          dpyv1$score,dpyv2$score,drv1$score,drv2$score)))
}

## Check:
{
  ## Boston basic - r vs python:
  bpyv1 = bpyv1[order(iter,program_id,quota_id,-score)]
  brv1 = brv1[order(iter,program_id,quota_id,-score)]
  data_boston_v1 = rbind(bpyv1,brv1)
  data_boston_v1[,score := specify_decimal(score,maxl)]
  nrow(unique(data_boston_v1)) == nrow(bpyv1)
  
  ## DA basic - r vs python:
  dpyv1 = dpyv1[order(iter,program_id,quota_id,-score)]
  drv1 = drv1[order(iter,program_id,quota_id,-score)]
  data_da_v1 = rbind(dpyv1,drv1)
  data_da_v1[,score := specify_decimal(score,maxl)]
  nrow(unique(data_da_v1)) == nrow(dpyv1)
  
  ## Boston basic - r vs python:
  bpyv2 = bpyv2[order(iter,program_id,quota_id,-score)]
  brv2 = brv2[order(iter,program_id,quota_id,-score)]
  data_boston_v2 = rbind(bpyv2,brv2)
  data_boston_v2[,score := specify_decimal(score,maxl)]
  nrow(unique(data_boston_v2)) == nrow(bpyv2)
  
  ## DA basic - r vs python:
  dpyv2 = dpyv2[order(iter,program_id,quota_id,-score)]
  drv2 = drv2[order(iter,program_id,quota_id,-score)]
  data_da_v2 = rbind(dpyv2,drv2)
  data_da_v2[,score := specify_decimal(score,maxl)]
  nrow(unique(data_da_v2)) == nrow(dpyv2)
}

## Total assignment:
{
  data1 = rbind(brv1[,.(alg='Boston',cat='Hard quotas',assigned=.N),by=.(iter)],
                brv2[,.(alg='Boston',cat='Soft quotas',assigned=.N),by=.(iter)],
                drv1[,.(alg='Deferred Acceptance',cat='Hard quotas',assigned=.N),by=.(iter)],
                drv2[,.(alg='Deferred Acceptance',cat='Soft quotas',assigned=.N),by=.(iter)])
  
  ggplot(data1,aes(x=assigned,color=cat)) +
    geom_density() +
    facet_wrap(~alg) +
    scale_x_continuous(n.breaks = 10) +
    theme_bw() +
    labs(x='Total assigned',y=NULL,fill=NULL) +
    theme(legend.position = 'bottom')
  
  data2 = rbind(brv1[,.(alg='Boston',cat='Hard quotas',assigned=.N),by=.(iter,ranking)],
                brv2[,.(alg='Boston',cat='Soft quotas',assigned=.N),by=.(iter,ranking)],
                drv1[,.(alg='Deferred Acceptance',cat='Hard quotas',assigned=.N),by=.(iter,ranking)],
                drv2[,.(alg='Deferred Acceptance',cat='Soft quotas',assigned=.N),by=.(iter,ranking)])
  data2 = data2[,.(mean=mean(assigned),sd=sd(assigned),N=.N),by=.(alg,cat,ranking)]
  data2[,inter := qt(p=0.05/2, df=N-1,lower.tail=F) * sd/sqrt(N)]
  data2[,max := mean + inter]
  data2[,min := mean - inter]
  
  ggplot(data2) +
    geom_col(mapping=aes(x=factor(ranking),y=mean,fill=cat),position = position_dodge()) +
    geom_errorbar(mapping=aes(x=factor(ranking),ymin=min,ymax=max,group=interaction(cat,ranking)),
                  position = position_dodge()) +
    facet_wrap(~alg) +
    scale_y_continuous(n.breaks = 10) +
    theme_bw() +
    labs(x='Ranking',y='Assigned',fill=NULL) +
    theme(legend.position = 'bottom')
}
