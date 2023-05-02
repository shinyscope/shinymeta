updateCatTable <- function(cat_table, cat_num, inputs){
  cat_table$Categories[cat_num] <- inputs[1] #name
  cat_table$Weights[cat_num] <- inputs[2] #weights
  #cat_table[cat_num, 3] <- inputs[3] assignments are null right now
  cat_table$Drops[cat_num] <- inputs[3] #drops
  cat_table$Grading_Policy[cat_num] <- inputs[4] #grading policy
  # cat_table[cat_num, 6] <- inputs[6] #clobber
  # cat_table[cat_num, 7] <- inputs[7] #lateness
  return (cat_table)
}