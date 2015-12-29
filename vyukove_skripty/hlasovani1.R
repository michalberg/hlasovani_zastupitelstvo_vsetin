load("scaper_vyuka.RData")

# INPUT PARAMETERS
# _X_SOURCE, _LO_LIMIT_1
# raw data in csv using db structure, i.e., a single row contains:
# code of representative: voter_id, code of division: vote_event_id, vote option according to Popolo standar: option (i.e., one of "yes", "no", "abstain", "not voting", "absent"))
# first row is the header
# for example:
# "voter_id","vote_event_id","option"
# “Joe Europe”,”Division-007”,”yes”
X_source <- votes
X_source <- subset(X_source, grepl("2015", X_source$vote_event_id))
# lower limit to eliminate from calculations, e.g., .1; number
lo_limit = 0

# reorder data; divisions x persons
# we may need to install and/or load some additional libraries
# install.packages("reshape2")
library("reshape2")

X_source$vote_event_id = as.factor(X_source$vote_event_id)
X_source$voter_id = as.factor(X_source$voter_id)

X_source$option_numeric = rep(0,length(X_source$option))
X_source$option_numeric[X_source$option=='AYE'] = 1
X_source$option_numeric[X_source$option=='NOT_VOTING'] = -1
X_source$option_numeric[X_source$option=='NO'] = -1    #may be 0 in some parliaments
X_source$option_numeric[X_source$option=='ABSTAINED'] = -1
X_source$option_numeric[X_source$option=='MISSING'] = 0
X_source$option_numeric = as.numeric(X_source$option_numeric)

#prevent reordering, which is behaviour of acast:
X_source$voter_id = factor(X_source$voter_id, levels=unique(X_source$voter_id))
X_raw = t(acast(X_source,voter_id~vote_event_id,fun.aggregate=mean,value.var='option_numeric'))
X_people = dimnames(X_raw)[[2]]
X_vote_events = dimnames(X_raw)[[1]]
#X_raw = apply(X_raw,1,as.numeric)
mode(X_raw) = 'numeric'



# WEIGHTS
# weights 1 for divisions, based on number of persons in division
w1 = apply(abs(X_raw)==1,1,sum,na.rm=TRUE)/max(apply(abs(X_raw)==1,1,sum,na.rm=TRUE))
w1[is.na(w1)] = 0
# weights 2 for divisions, "100:100" vs. "195:5"
w2 = 1 - abs(apply(X_raw==1,1,sum,na.rm=TRUE) - apply(X_raw==-1,1,sum,na.rm=TRUE))/apply(!is.na(X_raw),1,sum)
w2[is.na(w2)] = 0
# total weights:
w = w1 * w2

# analytical charts for weights:
plot(w1)
plot(w2)
plot(w)


# MISSING DATA
# index of missing data; divisions x persons
I = X_raw
I[!is.na(X_raw)] = 1
I[is.na(X_raw)] = 0


# EXCLUSION OF REPRESENTATIVES WITH TOO FEW VOTES (WEIGHTED)
# weights for non missing data; division x persons
I_w = I*w
# sum of weights of divisions for each persons; vector of length “persons”
s = apply(I_w,2,sum)
person_w = s/sum(w)
# index of persons kept in calculation; vector of length “persons”
person_I = person_w > lo_limit

# cutted (omitted) persons with too few weighted votes; division x persons
X_c = X_raw[,person_I]
# scale data; divisions x persons (mean=0 and sd=1 for each division); scaled cutted persons with too few weighted votes; division x persons
X_c_scaled = t(scale(t(X_c),scale=TRUE))
# scaled with NA->0 and cutted persons with too few weighted votes; division x persons
X_c_scaled_0 = X_c_scaled
X_c_scaled_0[is.na(X_c_scaled_0)] = 0
# weighted scaled with NA->0 and cutted persons with too few weighted votes; division x persons
X = X_c_scaled_0 * sqrt(w)  # X is shortcut for X_c_scaled_0_w

# “X’X” MATRIX
# weighted X’X matrix with missing values substituted and excluded persons; persons x persons
C = t(X) %*% X

# DECOMPOSITION
# eigendecomposition
Xe=eigen(C)
# W (rotation values of persons)
V = Xe$vectors
# projected divisions into dimensions
Xy = X %*% V

# analytical charts of projection of divisions and lambdas
plot(Xy[,1],Xy[,2])
plot(sqrt(Xe$values[1:min(10,dim(Xy))]))

# lambda matrix
sigma = sqrt(Xe$values)
sigma[is.na(sigma)] = 0
lambda = diag(sigma)

# projection of persons into dimensions
X_proj = V %*% lambda
# unit-standardized projection of persons into dimensions
X_proj_unit = X_proj / sqrt(apply(X_proj^2,1,sum))

# analytical charts
plot(X_proj[,1],X_proj[,2])
plot(X_proj_unit[,1],X_proj_unit[,2])

# lambda^-1 matrix
lambda_1 = diag(sqrt(1/Xe$values))
lambda_1[is.na(lambda_1)] = 0

# U (rotation values of divisions)
U = X %*% V %*% lambda_1

# analytical charts
# second projection
X_proj2 = t(X) %*% U
# second unit scaled projection of persons into dimensions
X_proj2_unit = X_proj2 / sqrt(apply(X_proj2^2,1,sum))
# they should be equal:
plot(X_proj[,1],X_proj2[,1])
#plot(X_proj[,2],X_proj2[,2])

# save first two dimensions with persons' ids:

# CUTTING LINES
# additional parameters:
# _N_FIRST_DIMENSIONS
# how many dimensions?
n_first_dimensions = 2

# loss function
LF = function(beta0) -1*sum(apply(cbind(y*(x%*%beta+beta0),zeros),1,min))

# preparing variables
normals = Xy[,1:n_first_dimensions]
loss_f = data.frame(matrix(0,nrow=dim(X_raw)[1],ncol=4))
colnames(loss_f)=c("Parameter1","Loss1","Parameter_1","Loss_1")
parameters = data.frame(matrix(0,nrow=dim(X_raw)[1],ncol=3))
colnames(parameters)=c("Parameter","Loss","Direction")

# x-values
#xfull = t(t(Xe$vectors[,1:n_first_dimensions]) * sqrt(Xe$values[1:n_first_dimensions]))
#xfull = X_proj[,1:n_first_dimensions]
# unit x-values
xfullu = X_proj_unit[,1:n_first_dimensions]


#calculating all cutting lines
for (i in as.numeric(1:dim(X_raw)[1])) {
  beta = Xy[i,1:n_first_dimensions]
  y = t(as.matrix(X_raw[i,]))[,person_I]
  x = xfullu[which(!is.na(y)),]
  y = y[which(!is.na(y))]
  zeros = as.matrix(rep(0,length(y)))
  # note: “10000” should be enough for any real-life case:
  res1 = optim(c(1),LF,method="Brent",lower=-10000,upper=10000)        
  # note: the sign is arbitrary, the real result may be -1*; we need to minimize the other way as well
  y=-y
  res2 = optim(c(1),LF,method="Brent",lower=-10000,upper=10000) 
  
  # the real parameter is the one with lower loss function
  # note: theoretically should be the same (either +1 or -1) for all divisions(rows), however, due to missing data, the calculation may lead to a few divisions with the other direction
  loss_f[i,] = c(res1$par,res1$value,res2$par,res2$value)
  if (res1$value<=res2$value) {
    parameters[i,] = c(res1$par,res1$value,1)
  } else {
    parameters[i,] = c(res2$par,res2$value,-1)
  }
}
CuttingLines = list(normals=normals,parameters=parameters,loss_function=loss_f,weights=cbind(w1,w2))

# analytical charts
# cutting lines
# additional parameters:
# _MODULO, _LO_LIMIT_3
# to show only each _MODULO-division (for huge numbers of divisions may be useful to use it) # if set to 1, every division is shown
# _LO_LIMIT_3 is a lower limit used to plot only important divisions; number between [0,1]
lo_limit3 = 0
modulo = 1
plot(X_proj_unit[,1],X_proj_unit[,2])
I = w1*w2 > lo_limit3
for (i in as.numeric(1:dim(X_raw)[1])) {
  if (I[i] && ((i %% modulo) == 0)) {
    beta = CuttingLines$normals[i,]
    beta0 = CuttingLines$parameters$Parameter[i]
    abline(-beta0/beta[2],-beta[1]/beta[2])
  }
}
# normals of cutting lines, possibly with some limitations, e.g. 50, 20: 
plot(CuttingLines$parameters$Parameter/CuttingLines$normals[,1],ylim=c(-50,50))
plot(CuttingLines$parameters$Parameter/CuttingLines$normals[,2],ylim=c(-20,20))

X_proj2_unit <- cbind(row.names(X_proj2_unit), X_proj2_unit)

dir.create("koprivnice")

voters <- X_source[!duplicated(X_source$voter_id), ]
voters$name <- paste0(voters$family_name, ", ", voters$given_name, " (", voters$group, ")")
voters <- voters[c("voter_id", "name", "group")]
voters <- merge(voters, X_proj2_unit[, 1:3], by.x = c("voter_id"), by.y = c("V1"), all = FALSE)
voters$r <- 0.1
voters$result <- 1
voters$opacity <- 0.7
voters$color <- voters$group
voters$color <- gsub("ODS bpp", "blue", voters$color)
voters$color <- gsub("ODS", "blue", voters$color)
voters$color <- gsub("NK bpp", "grey", voters$color)
voters$color <- gsub("NK", "grey", voters$color)
voters$color <- gsub("NEZ bpp", "grey", voters$color)
voters$color <- gsub("ANO bpp", "cyan", voters$color)
voters$color <- gsub("ANO", "cyan", voters$color)
voters$color <- gsub("PSZ bpp", "steelblue", voters$color)
voters$color <- gsub("PSZ", "steelblue", voters$color)
voters$color <- gsub("PZK bpp", "black", voters$color)
voters$color <- gsub("PZK", "black", voters$color)
voters$color <- gsub("KDU-ÄŒSL bpp", "gold", voters$color)
voters$color <- gsub("KDU-ÄŒSL", "gold", voters$color)
voters$color <- gsub("KDU bpp", "gold", voters$color)
voters$color <- gsub("ÄŒSSD bpp", "orange", voters$color)
voters$color <- gsub("ÄŒSSD", "orange", voters$color)
voters$color <- gsub("KSÄŒM bpp", "red", voters$color)
voters$color <- gsub("KSÄŒM", "red", voters$color)

names(voters) <- c("id", "name", "group", "wpca:d1", "wpca:d2", "r", "result", "opacity", "color")

write.csv(voters, "koprivnice/voters.csv", row.names = FALSE)