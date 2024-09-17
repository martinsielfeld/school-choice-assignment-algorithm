lotteryNum = function(apps=NULL,type='py&r',breaktype='application',iterat=1,seed=NULL){
  
  ## Add tiebreak:
  if(!'lottery_number' %in% names(apps)){ ## If not lottery number provided
    apps[,lottery_number:=NA]
  }
  
  ## Validation:
  if(!type %in% c('py&r','local')){stop('Wrong type for lottery numbers')}
  if(!(all(is.na(apps$lottery_number)) | all(!is.na(apps$lottery_number)))){stop('Some lottery numbers are missing. Not valid input')}
  
  if(iterat == 1 & any(is.na(apps$lottery_number)) == F){ ## If lottery numbers provided, use them 
    
    cat(paste0('\n        Random numbers detected'))
    
  } else if(iterat > 1 | any(is.na(apps$lottery_number)) == T){ ## If any lottery number provided, all new
    
    cat(paste0('\n        Creating random numbers'))
    if(type == 'py&r'){
      
      v <- 1:nrow(apps)
      s <- SyncRNG(seed=seed)
      apps$lottery_number = s$shuffle(v)
      
    } else if(type == 'local'){
      
      set.seed(seed)
      apps$lottery_number = sample.int(10^nchar(nrow(apps))-1,nrow(apps),replace=F)
      
    }
  
    apps[,lottery_number := lottery_number/10^max(str_length(lottery_number))]
  
    if(breaktype == 'applicant'){ ## If one lottery number per applicant, first one
    
      apps[,lottery_number:=first(lottery_number),by=.(applicant_id)]
    }
  }
  
  ## Check tiebreak:
  if(any(apps[,.(count=.N),.(program_id,lottery_number)]$count != 1)){
    stop('Repeated tiebreak in school - grade')
  }
  
  ## Create score:
  apps[,score := priority_profile + lottery_number]
  
  ## Export:
  return(apps)
}
