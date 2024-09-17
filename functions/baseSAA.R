baseSAA = function(apps=NULL,vacs=NULL,get_wl=T,get_probs=F,iters=1,
                   tiebreak='application',seed=1234,type='DA',
                   get_assignment=T,get_cutoffs=T,rand_type='py&r'){
  
  ## Load functions:
  source(paste0(mainFolder,'/functions/expandVacs.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/functions/lotteryNum.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/functions/Boston.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/functions/DA.R'),encoding='UTF-8')
  source(paste0(mainFolder,'/functions/getCutoffs.R'),encoding='UTF-8')
  
  ## Validation:
  if(!type %in% c('DA','Boston')){stop('Wrong type. Valids algorithms are "DA" and "Boston"')}
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
    apps2 = lotteryNum(apps2,breaktype=tiebreak,type=rand_type,iterat=iters,seed=iter_seeds[i])
    
    ## Start iteration:
    if(type == 'DA'){
      assigned = DA(apps2,vacs)
    } else if(type=='Boston'){
      assigned = Boston(apps2,vacs)
    }
    
    ## Add original ranking:
    assigned[,iter:=i]
    assigned[,ranking:=NULL]
    assigned = merge(assigned,apps[,.(applicant_id,program_id,ranking)],by=c('applicant_id','program_id'))
    
    ## Save cutoffs:
    if(get_cutoffs == T){
      cutoffs = getCutoffs(assigned,vacs,cutoffs)
    }
    
    ## Save assignment:
    if(get_assignment==T){
      assigned = assigned[,.(iter,applicant_id,program_id,ranking,score)]
      assignment = rbind(assignment,assigned) 
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
  
  cat('\nEnd of simulations')
  return(results)
  gc()
}
