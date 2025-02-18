baseSAA = function(apps = NULL,                ## Application DB
                   vacs = NULL,                ## Vacancies DB
                   iters = 1,                  ## Number of iterations. Default is 1.   
                   get_wl = T,                 ## Get waitilng list: TRUE / FALSE. Default is TRUE.
                   get_assignment = T,         ## Get assignment: TRUE / FALSE.  Default is TRUE.
                   get_cutoffs = T,            ## Get programs cutoffs: TRUE / FALSE. Default is TRUE.
                   get_probs = F,              ## Get ratex. Default is FALSE.
                   get_stats = F,              ## Get stats. Default is FALSE.
                   transfer_capacity = F,      ## Transfer applicants from quota if not assigned. Default to FALSE.
                   tiebreak = 'application',   ## Tiebreak level: applicant / application. Default is application.
                   seed = 1234,                ## Seed: initial seed for random numbers.
                   rand_type = 'py&r'){
  
  ## Load functions:
  source(paste0(mainFolder,'/src/expandPriorities.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/src/getCutoffs.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/src/expandVacs.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/src/lotteryNum.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/src/prepStats.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/src/getProbs.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/src/DA.R'),encoding='UTF-8')
  
  ## Validation:
  if(!tiebreak %in% c('applicant','application')){stop('Wrong tiebreak. Valids are "applicant" and "application"')}
  
  ## Seeds:
  cat('\nRandom numbers...')
  if(iters == 1){
    iter_seeds <- seed
  } else if (iters > 1){
    a <- 1:(iters*100)
    b <- SyncRNG(seed=seed)
    iter_seeds = b$shuffle(a)[1:iters]
  }
  
  ## Supply:
  vacs = expandVacs(vacs)
  maxqid = max(vacs$quota_id)
  
  ## Loop:
  cat('\nStart assignment...')
  assignment = NULL
  cutoffs = NULL
  ratex = NULL
  stats = NULL
  for(i in 1:iters){
    
    ## Print:
    cat(paste0('\n    Iteration: ',i))
    
    ## Sort:
    apps2 <- copy(apps)
    apps2 <- apps2[order(program_id,-applicant_id)]
    
    ## Add tiebreak:
    apps2 = lotteryNum(apps2,breaktype=tiebreak,type=rand_type,iterat=iters,seed=iter_seeds[i])
    
    ## Start iteration:
    assigned = DA(apps2,vacs,maxqid,transfer_capacity)
    
    ## Add original ranking:
    assigned[,iter:=i]
    assigned[,ranking:=NULL]
    assigned = merge(assigned,apps[,.(applicant_id,program_id,ranking)],by=c('applicant_id','program_id'))
    
    hard = transfer_capacity == F
    
    ## Save cutoffs:
    if(get_cutoffs == T){
      cutoffs = getCutoffs(apps2,vacs,assigned,cutoffs,i,hard)
    }
    
    ## Save assignment:
    if(get_assignment==T){
      assigned = assigned[,.(iter,applicant_id,program_id,quota_id,ranking,score)]
      assignment = rbind(assignment,assigned) 
    }
    
    ## Save ratex:
    if(get_probs == T | get_stats == T){
      
      ## Expand priorities:
      pp = expandPriorities(unique(vacs$program_id),unique(vacs$quota_id),unique(apps$priority_profile))
      
      ## Prep stats:
      pp = prepStats(apps,vacs,assigned,pp,i)
      
      ## Get ratex:
      if(get_probs==T){
        rat = getProbs(pp)
        ratex = rbind(ratex,rat) 
      }
      
      ## Get stats:
      if(get_stats == T){
        sta = pp[,.()]
        stats = rbind(stats,sta)
      }
    }
  }
  
  ## Export results:
  results = NULL
  if(get_assignment == T){
    results$assignment = assignment
  }
  if(get_cutoffs == T){
    results$cutoffs = cutoffs
  }
  if(get_probs == T){
    cat('\nGet ratex distribution')
    ratex = ratex[,.(ratex_mean=mean(ratex,na.rm=T),ratex_q25=quantile(ratex,0.25,na.rm=T),
                     ratex_q50=quantile(ratex,0.5,na.rm=T),ratex_q75=quantile(ratex,0.75,na.rm=T)),
                  by=.(program_id,quota_id,priority_profile)]
    ratex = ratex[order(program_id,quota_id,-priority_profile)]
    results$ratex = ratex
  }
  
  cat('\nEnd of simulations')
  return(results)
  gc()
}
