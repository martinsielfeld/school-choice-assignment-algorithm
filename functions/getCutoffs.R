getCutoffs = function(apps=NULL,vacs=NULL,assigned=NULL,cutoffs=NULL,iterat=NULL){
  cat(paste0('\n        Get cutoffs'))
  
  apps[,score:=priority_profile+lottery_number]
  apps = merge(apps,assigned[,.(applicant_id,program_id,assigned=1)],
               by=c('applicant_id','program_id'),all.x=T)
  apps[is.na(assigned),assigned:=0]
  apps = apps[order(program_id,-score)]
  uc = apps[assigned == 1,.(upper_cutoff=min(score,na.rm=T)),by=.(program_id)]
  lc = apps[assigned == 0,.(lower_cutoff=max(score,na.rm=T)),by=.(program_id)]
  
  vacs = unique(vacs[,.(program_id)])
  vacs = merge(vacs,uc,all.x=T)
  vacs = merge(vacs,lc,all.x=T)
  vacs[,not_filled:=ifelse(is.na(upper_cutoff),T,F)]
  vacs[is.na(upper_cutoff),upper_cutoff:=1]
  vacs[is.na(lower_cutoff),lower_cutoff:=1]
  vacs = vacs[,.(iter=iterat,program_id,not_filled,lower_cutoff,upper_cutoff)]
  cutoffs = rbind(cutoffs,vacs)
  return(cutoffs)
}