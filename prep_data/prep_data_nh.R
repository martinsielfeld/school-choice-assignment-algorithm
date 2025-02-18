####################################################################
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

## Packages:
packages <- c("data.table","stringr","tidyr")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)){install.packages(new_packages)}
sapply(packages,require,character.only=T,quietly=T)

## Load data:
{
  vacancies = fread(paste0(getwd(),'/data/source/nhps/2024/vacancies.csv'),encoding='UTF-8',integer64='character')
  applications = fread(paste0(getwd(),'/data/source/nhps/2024/applications.csv'),encoding='UTF-8',integer64='character')
}

## Prep applications:
{
  ## Prep applications - filter:
  applications = applications[submitted == 1 & withdrawn == 0 & status == 1 & choice_rank > 0,]
  applications = unique(applications,by=c('student_id','choice_rank'))
  applications = applications[lottery_group %in% vacancies$`Lottery Group ID`,]
  
  ## Filter by date:
  applications[,submitted_day := as.Date(submitted_timestamp)]
  applications = applications[submitted_day <= as.Date('2024-03-01'),]
  
  ## Prep applications -  select variables:
  applications = applications[,.(student_id,
                                 grade,
                                 lottery_group,
                                 lottery_sublottery,
                                 program_id,
                                 ranking=choice_rank,
                                 application_id=id,choice_rank,
                                 priority_super_priority_99,
                                 priority_neighborhood_and_sibling_attending,
                                 priority_sibling_attending,
                                 priority_neighborhood,
                                 priority_sibling_applying,
                                 priority_preferred_town_zip_code)]
  applications[is.na(applications)] = 0
  
  ## Grade id:
  applications[,grade_id := as.numeric(as.character(factor(grade,levels=c('PreK4','PreK3','K',1:12),
                                                                 labels=c(1:15))))]
  
  ## Change quota id:
  applications[,quota_id := as.numeric(as.character(factor(lottery_group,levels=519:509,labels=1:11)))]
  
  ## Prep priority_profiles:
  applications[,priority_profile_ori := 38 - lottery_sublottery]
  applications[,priority_profile_edi := 1]
  applications[priority_preferred_town_zip_code == 1,priority_profile_edi := 2]
  applications[priority_sibling_applying == 1,priority_profile_edi := 3]
  applications[priority_sibling_attending == 1,priority_profile_edi := 4]
  applications[priority_neighborhood == 1,priority_profile_edi := 5]
  applications[priority_neighborhood_and_sibling_attending == 1,priority_profile_edi := 6]
  applications[priority_super_priority_99 == 1,priority_profile_edi := 7]
  
  ## Select variables:
  applications = applications[,.(applicant_id=student_id,grade_id,program_id,ranking,quota_id,priority_profile_ori,
                                 priority_profile_edi)]
  applications = applications[order(applicant_id,ranking)]
}

## Prep seats:
{
  ## Quota id:
  quota_label = unique(vacancies[,.(`Lottery Group`,`Lottery Group ID`)])
  quota_label[order(`Lottery Group ID`)]
  
  ## Grade id:
  vacancies[Grade == 'PreK',Grade := 'PreK4']
  vacancies = vacancies[,.(seats=sum(`Original Cutoff (from settings)`,na.rm=T)),by=.(`Program ID`,Grade,`Lottery Group ID`)]
  vacancies[,grade_id := as.numeric(as.character(factor(Grade,levels=c('PreK4','PreK3','K',1:12),
                                                    labels=c(1:15))))]
  
  ## Rename:
  names(vacancies)[names(vacancies) == 'Program ID'] = 'program_id'
  
  ## Change quota id:
  vacancies[,quota_id := factor(`Lottery Group ID`,levels=519:509,labels=c(paste0('quota_',1:10),'regular_vacancies'))]
  vacancies = dcast.data.table(vacancies,grade_id + program_id ~ quota_id, value.var = 'seats',fill=0)
  
  ## Sort:
  vacancies = vacancies[order(program_id,grade_id,program_id)]
}

## Final changes:
{
  ## Crosswalk:
  crosswalk = unique(vacancies[,.(program_id,grade_id)])
  crosswalk[, id := .I]
  
  ## Merge:
  applications = merge(applications,crosswalk,by=c('program_id','grade_id'))
  vacancies = merge(vacancies,crosswalk,by=c('program_id','grade_id'))
  
  ## Delete program id:
  applications[,program_id:=NULL]
  
  ## Rename:
  names(applications)[names(applications) == 'id'] = 'program_id'
  names(vacancies)[names(vacancies) == 'program_id'] = 'school_id'
  names(vacancies)[names(vacancies) == 'id'] = 'program_id'
  
  ## Final table:
  applications = applications[,.(applicant_id,grade_id,program_id,ranking,quota_id,
                                 priority_profile_ori,priority_profile_edi)]
  vacancies = vacancies[,.(school_id,grade_id,program_id,quota_1,quota_2,quota_3,quota_4,
                           quota_5,quota_6,quota_7,quota_8,quota_9,quota_10,regular_vacancies)]
  
  ## Sort:
  applications = applications[order(applicant_id,ranking)]
  vacancies = vacancies[order(school_id,grade_id,program_id)]
}

## Export:
{
  fwrite(vacancies,paste0(mainFolder,'/data/example_3/vacancies_r.csv'))
  fwrite(applications,paste0(mainFolder,'/data/example_3/applications_r.csv'))
}

## Clean:
rm(list = ls(all.names = T))