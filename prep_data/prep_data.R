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

## Load data:
{
  ## Select files:
  files = c('A1','B1','C1','F1') ## 1 = round 1; 2 = round 2
  
  ## Load files:
  for(i in files){
    assign(i,fread(paste0(mainFolder,'/data/source/',i,'.csv'),encoding='UTF-8',integer64='character',dec=','))
  }
}

## General edits:
{
  ## Program ID:
  programs = A1[order(rbd,cod_nivel,cod_curso)]
  programs[,program_id:=.I]
  
  ## Crosswalk:
  crosswalk = programs[,.(rbd,cod_curso,program_id)]
  
  ## Quotas:
  programs = programs[,.(school_id=rbd,grade_id=cod_nivel,program_id,
                         quota_1=vacantes_pie,
                         quota_2=vacantes_alta_exigencia_r,
                         quota_3=vacantes_prioritarios,
                         regular_vacancies=vacantes_regular,
                         total_vacancies=vacantes)]
  
  ## Applications:
  applications = merge(C1,B1,by=c('mrun','cod_nivel'))
  applications = merge(applications,crosswalk,by=c('rbd','cod_curso'))
  applications[,loteria_original:=loteria_original/10^max(str_length(loteria_original))]
  applications = applications[order(-cod_nivel,mrun,preferencia_postulante)]
  applications = applications[,.(applicant_id=mrun,
                                 grade_id=cod_nivel,
                                 program_id,
                                 ranking=preferencia_postulante,
                                 low_income=prioritario,
                                 special_needs=es_pie,
                                 high_perf_prio=alto_rendimiento,
                                 staff_prio=prioridad_hijo_funcionario,
                                 ex_student_prio=prioridad_exalumno,
                                 sibling_prio=prioridad_hermano,
                                 continuity_prio=agregada_por_continuidad,
                                 order_1=orden_pie,
                                 order_2=orden_alta_exigencia_transicion,
                                 order_3=NA,
                                 lottery_number=loteria_original)]
  
  ## Clean:
  rm(list = ls(pattern = '1|2'))
  gc()
}

## Example 1 - base algorithms:
{
  ## Programs:
  programs1 = programs[,.(school_id,grade_id,program_id,regular_vacancies=total_vacancies)]
  
  ## Priority profile:
  applications1 = copy(applications)
  applications1[sibling_prio == 1, priority_profile := 4]
  applications1[is.na(priority_profile) & staff_prio == 1, priority_profile := 3]
  applications1[is.na(priority_profile) & ex_student_prio, priority_profile := 2]
  applications1[is.na(priority_profile), priority_profile := 1]
  applications1 = applications1[,.(applicant_id,grade_id,program_id,ranking,priority_profile,lottery_number)]
  
  ## Check:
  table(applications$priority_profile,exclude=F)
  
  ## Export:
  fwrite(programs1,paste0(mainFolder,'/data/example_1/vacancies.csv'))
  fwrite(applications1,paste0(mainFolder,'/data/example_1/applications.csv'))
  rm(applications1,programs1)
}

## Example 2 - quota:
{
  ## Programs:
  programs2 = programs[,.(school_id,grade_id,program_id,regular_vacancies=total_vacancies)]
  
  ## Priority profile:
  applications2 = copy(applications)
  applications2[continuity_prio == 1, priority_profile := 5]
  applications2[sibling_prio == 1, priority_profile := 4]
  applications2[is.na(priority_profile) & staff_prio == 1, priority_profile := 3]
  applications2[is.na(priority_profile) & ex_student_prio, priority_profile := 2]
  applications2[is.na(priority_profile), priority_profile := 1]
  applications2 = applications2[,.(applicant_id,grade_id,program_id,ranking,priority_profile,lottery_number)]
  
  ## Check:
  table(applications$priority_profile,exclude=F)
  
  ## Export:
  fwrite(programs2,paste0(mainFolder,'/data/example_2/vacancies.csv'))
  fwrite(applications2,paste0(mainFolder,'/data/example_2/applications.csv'))
  rm(applications2,programs2)
}

## Clean:
rm(list = ls(all.names = T))



