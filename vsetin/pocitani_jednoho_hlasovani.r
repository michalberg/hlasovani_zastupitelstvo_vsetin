
baselink <- "https://dl.dropboxusercontent.com/u/2424343/zeleni/zastupitelé/hlasovani/"
terminy <- c("z201401","z201402","z201403","z201404","z201501","z201501","z201502","z201503")

for (iii in 1:1) {
  
  #print(terminy[i])
  link <- paste(baselink, terminy[iii], sep="")
  baselink2 <- link
  print (link)
  if (iii==1) delka<-16
  if (iii==2) delka<-5
  if (iii==3) delka<-31
  if (iii==4) delka<-17
  if (iii==5) delka<-48
  if (iii==6) delka<-62
  if (iii==7) delka<-55
  
  
  for (ii in 1:delka) {
    print(delka)
    print(ii)
    if (ii<10) link <- paste(link, "/000", sep="") 
    if (ii>9) link <- paste(link, "/00", sep="")
   link <- paste(link,ii,sep="")
   link <- paste(link,".xml",sep="")
     
   #zde vložit parsovací skript
   print(link)
     
     
html <- readLines(link, encoding = "utf-8")
html <- data.frame(html)
html$include <- sapply(html$html, function(x) ifelse(grepl("Deputy id", x) == T, 1, 0))
html <- html[which(html$include == 1), ]
html <- data.frame(do.call('rbind', strsplit(as.character(html$html), "=")))

# poznámka

voter_id <- data.frame(do.call('rbind', strsplit(as.character(html$X2), '"')))
voter_id <- data.frame(voter_id$X2)
names(voter_id) <- "voter_id"

title <- data.frame(do.call('rbind', strsplit(as.character(html$X5), '"')))
title <- data.frame(title$X2)
names(title) <- "title"

given_name <- data.frame(do.call('rbind', strsplit(as.character(html$X6), '"')))
given_name <- data.frame(given_name$X2)
names(given_name) <- "given_name"

family_name <- data.frame(do.call('rbind', strsplit(as.character(html$X7), '"')))
family_name <- data.frame(family_name$X2)
names(family_name) <- "family_name"

group <- data.frame(do.call('rbind', strsplit(as.character(html$X8), '"')))
group <- data.frame(group$X2)
names(group) <- "group"

option <- data.frame(do.call('rbind', strsplit(as.character(html$X9), '"')))
option <- data.frame(option$X2)
names(option) <- "option"

result <- cbind(voter_id, title)
result <- cbind(result, given_name)
result <- cbind(result, family_name)
result <- cbind(result, group)
result <- cbind(result, option)
result$vote_event_id <- link

rm(list = ls() [!ls() %in% c("html", "link", "baselink", "baselink2", "delka", "terminy", "ii", "iii", "votes")])

for (i in c(2, 5:9)) {
  
  data <- data.frame(do.call('rbind', strsplit(as.character(html[, i]), '"')))
  data <- data.frame(data$X2)
  
  if (i == 2) {
    
    result <- data
    
  } else {
    
    result <- cbind(result, data)
    
  } # if (i == 2)
  
} # for (i in c(2, 5:9))

names(result) <- c("voter_id", "title", "family_name", "given_name", "group", "option")

result$vote_event_id <- link
link <- baselink2


#zde se sčítají do tabulky "votes" všechna hlasování

  if (exists("votes") == FALSE) {
    
    votes <- result
    
  } else {
    
    votes <- rbind(votes, result)
    
  } # if (exists("votes") == FALSE)
  
  } #for (ii in 1:delka)
  
} #for (i in 1:7)

