baseBoston = function(apps=NULL,vacs=NULL,get_wl=T,get_probs=F,iters=1,
                   tiebreak='application',seed=1234,get_assignment=T,
                   get_cutoffs=T){
  
  ## Validation:
  if(!tiebreak %in% c('applicant','application')){stop('Wrong tiebreak. Valids are "applicant" and "application"')}
  
  ## Seeds:
  cat('Random numbers...')
  if(iters == 1){
    iter_seeds <- seed
  } else if (iters > 1){
    a <- 1:(iters*100)
    b <- SyncRNG(seed=seed)
    iter_seeds = b$shuffle(a)[1:iters]
  }
  
  ## Supply:
  cat('\nExpand vacancies...')
  vacs <- vacs[regular_vacancies > 0]
  vacs <- vacs[, .(seat_order = seq_len(regular_vacancies)), by = program_id]
  
  ## Loop:
  cat('\nStart assignment...')
  assignment = NULL
  cutoffs = NULL
  for(i in 1:iters){
    
    ## Print:
    cat(paste0('\n    Iteration: ',i))
    
    ## Sort:
    apps2 <- copy(apps)
    apps2 <- apps2[order(program_id,-applicant_id)]
    
    ## Add tiebreak:
    if(!'lottery_number' %in% names(apps2)){ ## If not lottery number provided
      apps2[,lottery_number:=NA]
    }
    
    if(iters == 1 & any(is.na(apps2$lottery_number)) == F){ ## If lottery number provided, use it
      cat(paste0('\n        Random numbers detected'))
    } else if(iters > 1 | any(is.na(apps2$lottery_number)) == T){ ## If any lottery number provided, all new
      cat(paste0('\n        Creating random numbers'))
      v <- 1:nrow(apps2)
      s <- SyncRNG(seed=iter_seeds[i])
      apps2$lottery_number = s$shuffle(v)
      apps2[,lottery_number := lottery_number/10^max(str_length(lottery_number))]
      if(tiebreak == 'applicant'){ ## If one lottery number per applicant, first one
        apps2[,lottery_number:=first(lottery_number),by=.(applicant_id)]
      }
    }
    
    ## Check tiebreak:
    if(any(apps2[,.(count=.N),.(program_id,lottery_number)]$count != 1)){
      stop('Repeated tiebreak in school - grade')
    }
    
    ## Create score:
    apps2[,score := priority_profile + lottery_number]
    
    ## Start iteration:
    assigned = NULL
    preference = 1
    it = 1
    cat(paste0('\n        Starting Boston algorithm'))
    while(nrow(apps2) > 0){
      
      ## Filter:
      a <- apps2[ranking == preference,]
      
      ## Append:
      assigned <- rbind(assigned,a,fill=T)
      assigned <- assigned[order(program_id,-score,na.last=T)]
      assigned[,seat_order:=1:.N,by=.(program_id)]
      assigned <- assigned[paste0(program_id,'-',seat_order) %in% paste0(vacs$program_id,'-',vacs$seat_order)]
      
      ## Drop:
      apps2 <- apps2[ranking != preference,]
      apps2 <- apps2[!applicant_id %in% assigned$applicant_id,]
      preference <- preference + 1
      rm(a) 
    }
    
    ## Add original ranking:
    assigned[,iter:=i]
    assigned[,ranking:=NULL]
    assigned = merge(assigned,apps[,.(applicant_id,program_id,ranking)],by=c('applicant_id','program_id'))
    
    ## Print:
    if(get_cutoffs == T){
      cat(paste0('\n        Get cutoffs'))
      
      cuts = vacs[,.(seat_order=max(seat_order)),by=.(program_id)]
      cuts = merge(cuts,assigned[,.(program_id,seat_order,ranking,score)],
                   by=c('program_id','seat_order'),all.x=T)
      cuts[,not_filled:=ifelse(is.na(score),T,F)]
      cuts[is.na(score),score:=1]
      cuts = cuts[,.(iter=i,program_id,not_filled,ranking,score)]
      cutoffs = rbind(cutoffs,cuts)
      rm(cuts)
    }
    
    ## Save iter results:
    assigned = assigned[,.(iter,applicant_id,program_id,ranking,score)]
    if(get_assignment==T){
      assignment = rbind(assignment,assigned) 
    }
    rm(assigned)
  }
  
  ## Export results:
  cat('\nEnd of simulations')
  return(list('assignment'=assignment,'cutoffs'=cutoffs))
  gc()
}
