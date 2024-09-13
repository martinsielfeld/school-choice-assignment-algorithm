baseSAA = function(apps=NULL,vacs=NULL,get_wl=T,get_probs=F,iters=1,
                   tiebreak='application',seed=1234,type='DA'){
  
  ## Seeds:
  cat('Random numbers...')
  if(iters == 1){
    iter_seeds <- seed
  } else if (iters > 1){
    a <- 1:(iters*100)
    b <- SyncRNG(seed=seed)
    iter_seeds = b$shuffle(a)[1:iters]
  } else {
    stop('Not valid iteration value')
  }
  
  ## Supply:
  cat('\nExpand vacancies...')
  vacs <- vacs[regular_vacancies > 0]
  vacs <- vacs[, .(seat_order = seq_len(regular_vacancies)), by = program_id]
  
  ## Loop:
  cat('\nStart assignment...')
  assignment = NULL
  for(i in 1:iters){
    
    ## Print:
    cat(paste0('\n    Iteration: ',i))
    set.seed(iter_seeds[i])
    
    ## Sort:
    apps2 <- copy(apps)
    apps2 <- apps2[order(program_id,-applicant_id)]
    
    ## Add tiebreak:
    if(!'lottery_number' %in% names(apps2)){apps2[,lottery_number:=NA]}
    if(iters == 1 & any(is.na(apps2$lottery_number)) == F){
      cat(paste0('\n        Random numbers detected'))
    } else if(iters > 1 | any(is.na(apps2$lottery_number)) == T){
      cat(paste0('\n        Creating random numbers'))
      v <- 1:nrow(apps2)
      s <- SyncRNG(seed=iter_seeds[i])
      apps2$lottery_number = s$shuffle(v)
      apps2[,lottery_number := lottery_number/10^max(str_length(lottery_number))]
      if(tiebreak == 'applicant'){
        apps2[,lottery_number:=first(lottery_number),by=.(applicant_id)]
      } else if(tiebreak != 'application'){
        stop('Wrong tiebreak category')
      }
    } else {
      stop('Cannot have more than one iteration and keep same random number')
    }
    
    ## Create score:
    apps2[,score := priority_profile + lottery_number]
    
    ## Check
    if(any(apps2[,.(count=.N),.(program_id,lottery_number)]$count != 1)){
      stop('Repeated tiebreak in school - grade')
    }
    
    ## Start iteration:
    assigned = NULL
    preference = 1
    it = 1
    cat(paste0('\n        Starting ',type,' algorithm'))
    while(nrow(apps2) > 0){
      
      ## Filter:
      a <- apps2[ranking == 1 & !applicant_id %in% assigned$applicant_id,]
      
      ## Append:
      assigned <- rbind(assigned,a)
      assigned <- assigned[order(program_id,-score,na.last=T)]
      assigned[,seat_order:=1:.N,by=.(program_id)]
      assigned <- assigned[paste0(program_id,'-',seat_order) %in% paste0(vacs$program_id,'-',vacs$seat_order)]
      assigned[,seat_order:=NULL]
      
      ## Drop:
      apps2 <- apps2[ranking > 1 | (applicant_id %in% assigned$applicant_id & ranking == 1),]
      apps2 <- apps2[order(applicant_id,ranking)]
      if(nrow(apps2) == 0){ 
        break
      } else if(it > 1){
        if(nrow(apps2) == td2){
          rm(td2,a,it)
          break
        }
      }
      
      ## New ranking
      apps2[,ranking:=1:.N,by=.(applicant_id)]
      td2 <- nrow(apps2)
      it <- it + 1
      rm(a)
    }
    
    ## Add original ranking:
    assigned[,iter:=i]
    assigned[,ranking:=NULL]
    assigned = merge(assigned,apps[,.(applicant_id,program_id,ranking)],by=c('applicant_id','program_id'))
    assignment = rbind(assignment,assigned)
    rm(assigned)
  }
  
  ## Export results:
  cat('\nEnd of simulations')
  return(assignment)
}