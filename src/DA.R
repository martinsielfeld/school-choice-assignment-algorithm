DA = function(apps=NULL,vacs=NULL,reg_cap_id=NULL,trans_cap=NULL){
  
  cat(paste0('\n        Starting DA algorithm'))
  
  if(reg_cap_id > 1 & trans_cap == T){
    a = apps[quota_id != reg_cap_id,]
    a[,quota_id := reg_cap_id]
    apps = rbind(apps,a)
    rm(a)
  }
  
  apps = apps[order(applicant_id,ranking,quota_id)]
  apps[,quota_order := 1:.N,by=.(applicant_id,ranking)]
  apps[,order := 1:.N,by=.(applicant_id)]
  
  assigned = NULL
  while(nrow(apps) > 0){
    
    ## Filter:
    a <- apps[order == 1 & !applicant_id %in% assigned$applicant_id,]
    
    ## Append:
    assigned <- rbind(assigned,a,fill=T)
    assigned <- assigned[order(program_id,quota_id,-score,na.last=T)]
    assigned[,seat_order:=1:.N,by=.(program_id,quota_id)]
    assigned <- assigned[paste0(program_id,'-',seat_order,'-',quota_id) %in% vacs[,paste0(program_id,'-',seat_order,'-',quota_id)],]
    
    ## Drop:
    apps = apps[!paste0(applicant_id,'-',order) %in% assigned[,paste0(applicant_id,'-',order)],]
    apps = apps[order > 1,]
    apps = apps[order(applicant_id,order,quota_id)]
    if(nrow(apps) == 0){ 
      break
    }
    
    ## New ranking
    apps[,order:=1:.N,by=.(applicant_id)]
    rm(a)
  }
  
  ## Export:
  return(assigned)
}
