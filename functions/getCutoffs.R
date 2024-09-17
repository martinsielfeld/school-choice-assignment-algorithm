getCutoffs = function(assigned=NULL,vacs=NULL,cutoffs=NULL,iterat=NULL){
  cat(paste0('\n        Get cutoffs'))
  
  vacs = vacs[,.(seat_order=max(seat_order)),by=.(program_id)]
  vacs = merge(vacs,assigned[,.(program_id,seat_order,ranking,score)],
               by=c('program_id','seat_order'),all.x=T)
  vacs[,not_filled:=ifelse(is.na(score),T,F)]
  vacs[is.na(score),score:=1]
  vacs = vacs[,.(iter=iterat,program_id,not_filled,ranking,score)]
  cutoffs = rbind(cutoffs,vacs)
  return(cutoffs)
}