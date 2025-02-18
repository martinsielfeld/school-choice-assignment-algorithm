prepStats = function(apps=NULL,vacs=NULL,assigned=NULL,prio=NULL,iteration=NULL){
  cat(paste0('\n        Prep stats'))
  
  ## Get considered:
  d3 = merge(apps,assigned[,.(applicant_id,ass_priority_profile=trunc(score))],by='applicant_id',all.x=T)
  d3[is.na(ass_priority_profile),ass_priority_profile:=0]
  d3 = d3[ass_priority_profile >= priority_profile,] ## If more preferred or was assigned
  d3 = d3[,.(n_considered = .N),by=.(program_id,quota_id,priority_profile)]
  d3 = d3[order(program_id,quota_id,priority_profile)]
  
  tot_apps = apps[,.(total_applicants=.N),by=.(program_id,quota_id)]
  
  pp = merge(prio,assigned[,.(assigned=.N),by=.(program_id,quota_id,priority_profile=trunc(score))],all.x=T)
  pp = merge(pp,tot_apps,by=c('program_id','quota_id'),all.x=T)
  pp = merge(pp,d3,by=c('program_id','quota_id','priority_profile'),all.x=T)
  pp[is.na(pp)] = 0
  pp = pp[order(program_id,quota_id,-priority_profile)]
  pp[,cum_ass:=cumsum(assigned),by=.(program_id,quota_id)]
  pp = merge(pp,vacs[,.(seats=max(seat_order)),by=.(program_id,quota_id)],by=c('program_id','quota_id'),all.x=T)
  pp[is.na(pp)] = 0
  pp[,iter:=iteration]
  
  ## Create variables:
  pp = pp[order(iter,program_id,quota_id,-priority_profile)]
  pp[,assigned := shift(cum_ass,n=1,type='lag'),by=.(iter,program_id,quota_id)]
  pp[is.na(pp)] = 0
  pp[,assigned := cum_ass - assigned]
  pp[,cum_ass := cum_ass - assigned]
  pp[,total_seats := seats]
  pp[,seats:=seats - cum_ass]
  
  return(pp)
}