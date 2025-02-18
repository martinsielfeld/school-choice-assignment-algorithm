expandPriorities = function(prg_id=NULL,quo=NULL,prio_id=NULL){
  
  grid = data.table(expand.grid(program_id=prg_id,quota_id=quo,priority_profile=prio_id))
  grid = grid[order(program_id,quota_id,-priority_profile)]
  
  return(grid)
}
