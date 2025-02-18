getProbs = function(ratex=NULL){
  cat(paste0('\n        Prep ratex'))
  
  ratex[,ratex:=seats/n_considered]
  ratex[seats==0,ratex:=0]
  ratex[n_considered==0&seats>0,ratex:=1]
  ratex[ratex>1,ratex:=1]
  
  return(ratex)
}