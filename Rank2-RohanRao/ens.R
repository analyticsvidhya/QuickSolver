## loading libraries
library(data.table)


s1 <- fread("submit10.csv")
s2 <- fread("submit11.csv")
s3 <- fread("submit14.csv")
s4 <- fread("submit15.csv")
s5 <- fread("submit17.csv")

setorder(s1, ID)
setorder(s2, ID)
setorder(s3, ID)
setorder(s4, ID)
setorder(s5, ID)

s <- copy(s1)

s$Rating <- 0.1 * s1$Rating + 0.05 * s2$Rating + 0.25 * s3$Rating + 0.4 * s4$Rating + 0.2 * s5$Rating

fwrite(s, "submit_ens.csv")