expandVacs = function(vacs = NULL){
  
  if(any(names(vacs) %like% 'quota_')){
    n = levels(reorder(names(vacs)[names(vacs) %like% 'quota_'],
                       sort(as.numeric(gsub('quota_','',names(vacs)[names(vacs) %like% 'quota_'])))))
  } else {
    n = NULL
  }
  
  ## Check:
  if(!('program_id' %in% names(vacs) &'regular_vacancies' %in% names(vacs))){
    stop('program_id and regular_vacancies needed. Structure is program_id, quota_1, ..., quota_n, regular_vacancies')
  }
  
  ## Reshape:
  vacs = reshape(vacs,idvar="program_id",varying=c(n,'regular_vacancies'),
                 v.names = "vacancies",direction="long")
  names(vacs)[names(vacs) == 'time'] = 'quota_id'
  
  
  ## Supply:
  cat('\nExpand vacancies...')
  vacs <- vacs[vacancies > 0]
  vacs <- vacs[, .(seat_order = seq_len(vacancies)),by=.(program_id,quota_id)]
  vacs = vacs[order(program_id,quota_id,seat_order)]
  
  return(vacs)
}
