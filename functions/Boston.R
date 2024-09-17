Boston = function(apps=NULL,vacs=NULL){
  assigned = NULL
  preference = 1
  it = 1
  cat(paste0('\n        Starting Boston algorithm'))
  while(nrow(apps) > 0){
    
    ## Filter:
    a <- apps[ranking == preference,]
    
    ## Append:
    assigned <- rbind(assigned,a,fill=T)
    assigned <- assigned[order(program_id,-score,na.last=T)]
    assigned[,seat_order:=1:.N,by=.(program_id)]
    assigned <- assigned[paste0(program_id,'-',seat_order) %in% paste0(vacs$program_id,'-',vacs$seat_order)]
    
    ## Drop:
    apps <- apps[ranking != preference,]
    apps <- apps[!applicant_id %in% assigned$applicant_id,]
    preference <- preference + 1
    rm(a) 
  }
  
  ## Export:
  return(assigned)
}