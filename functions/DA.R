DA = function(apps=NULL,vacs=NULL){
  assigned = NULL
  preference = 1
  it = 1
  cat(paste0('\n        Starting DA algorithm'))
  while(nrow(apps) > 0){
    
    ## Filter:
    a <- apps[ranking == 1 & !applicant_id %in% assigned$applicant_id,]
    
    ## Append:
    assigned <- rbind(assigned,a,fill=T)
    assigned <- assigned[order(program_id,-score,na.last=T)]
    assigned[,seat_order:=1:.N,by=.(program_id)]
    assigned <- assigned[paste0(program_id,'-',seat_order) %in% paste0(vacs$program_id,'-',vacs$seat_order)]
    
    ## Drop:
    apps <- apps[ranking > 1 | (applicant_id %in% assigned$applicant_id & ranking == 1),]
    apps <- apps[order(applicant_id,ranking)]
    if(nrow(apps) == 0){ 
      break
    } else if(it > 1){
      if(nrow(apps) == td2){
        rm(td2,a,it)
        break
      }
    }
    
    ## New ranking
    apps[,ranking:=1:.N,by=.(applicant_id)]
    td2 <- nrow(apps)
    it <- it + 1
    rm(a)
  }
  
  ## Export:
  return(assigned)
}
