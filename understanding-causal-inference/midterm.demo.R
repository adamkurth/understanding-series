n = 15000

# exogenous variables
x2 = rbinom(n,1,0.25)
#x2 = rnorm(n)
x3 = rbinom(n,1,0.5)
x5 =  1 + 5*rnorm(n)

eps4 = rnorm(n)
eps6 = rnorm(n)
eps1 = rnorm(n)
epsy = 0.1*rnorm(n)


f4 = function(x2,x5,eps4){
  z4 =  -1 + 2*x2 + 0.5*x5 - x2*x5
  return((z4 + eps4) >= 0)
}

x4 = f4(x2,x5,eps4)

f1 = function(x2,x3,eps1){
z1 = 0.5 - 2*x2 + (2 + -3*x2)*x3
return((z1 + eps1) >= 0)
}

x1 = f1(x2,x3,eps1)

f6 = function(x1,x4,eps6){
z6 = (x4 == 0)*0.7
return((z6 + eps6)  > 0)
}

x6 = f6(x1,x4,eps6)

Y = function(x2,x3,x5,eps4,eps1,eps6,epsy,x1=NULL,x4=NULL,x6=NULL){
 
   if (length(x1)==0){
  y = (2*f1(x2,x3,eps1)*x5 - 25*(x5 > 0) + epsy)}else{
  y = (2*x1*x5 - 25*(x5 > 0) + epsy)}
  return(y)
}


# generate the observed data
y = Y(x2,x3,x5,eps4,eps1,eps6,epsy)

# generate the counterfactual potential outcomes corresponding to 
# do(x3 = 1) and do(x3 = 0)
#
y1 = Y(x2,rep(1,n),x5,eps4,eps1,eps6,epsy)
y0 = Y(x2,rep(0,n),x5,eps4,eps1,eps6,epsy)

# compute the true treatment effect
tau = mean(y1) - mean(y0)


# compute the naive estimate 
tau.est = mean(y[x3==1])- mean(y[x3==0])


# compare the two
print(round(c(tau.est,tau),0))

# now consider some sub-population estimands

# first, how about the population with x6 == 1

print(round(c(mean(y[x3==1 & x6 == 1])- mean(y[x3==0 & x6 == 1]),mean(y1[x6==1]) - mean(y0[x6==1])),2))

# next how about among the population with x6 = 0

print(round(c(mean(y[x3==1 & x6 == 0])- mean(y[x3==0 & x6 == 0]),mean(y1[x6==0]) - mean(y0[x6==0])),2))

# these can all be estimated without problem from the observed data because x3 is exogenous

# what about the population x1 = 1?

print(round(c(mean(y[x3==1 & x1 == 1])- mean(y[x3==0 & x1 == 1]),mean(y1[x1 == 1]) - mean(y0[x1 == 1])),2))
                                   
# this we cannot estimate naively because x1 is a mediating variable                                       

# now what about the causal effect of x1?

y1 = Y(x2,x3,x5,eps4,eps1,eps6,epsy,eps5,x1 = rep(1,n))
y0 = Y(x2,x3,x5,eps4,eps1,eps6,epsy,eps5,x1 = rep(0,n))

# compute the naive estimate 
tau.est = mean(y[x1==1])- mean(y[x1==0])

# compute the true treatment effect
tau = mean(y1) - mean(y0)

# compare the two
print(round(c(tau.est,tau),2))

# the naive estimator still works because treatment is 
# marginally independent (exogeneous) with respect to x5

# what if we want the treatment effect among the x4 = 1 subgroup?
tau.naive <- mean(y[x1==1 & x4 == 1])- mean(y[x1==0 & x4 == 1])

# estimating the CATE on the x2 subgroups
temp1 <- mean(y[x1==1 & x4==1 & x2==1])-mean(y[x1==0 & x4==1 & x2==1])
temp0 <- mean(y[x1==1 & x4==1 & x2==0])-mean(y[x1==0 & x4==1 & x2==0])

# computes the ATE (x4=1 CATE) from the CATEs by taking a weighted average
# this is referred to by Pearl as the "back-door adjustment" 
# and by statisticians as a regression adjustment for confounding
tau.right <- mean(x2[x4==1]==1)*temp1 + mean(x2[x4==1]==0)*temp0



# now let's look at how this would be done in practice

library(rpart)

df <- data.frame(y = y[x4==1], x1 = x1[x4==1], x2 = x2[x4==1],x5 = x5[x4==1])

# fit two models, one to treated, one to control
fit1 <- rpart(y~x2+x5,data = df, subset = x1==1)
fit0 <- rpart(y~x2+x5,data = df, subset = x1==0)
# 
# 
# # predict for everyone for both models; take the difference
 cates <- predict(fit1,newdata = df) - predict(fit0,newdata = df)
# 
 tau.ml <- mean(cates)
# 
# # by taking the average over the full sample, the CATEs are automatically weighted 
# # according to the the correct marginal probabilities 
# 
 print(round(c(tau.naive, tau.right,tau.ml, mean(y1[x4 == 1]) - mean(y0[x4 == 1])),2))
# 
# 

# this does not work because conditional on x4, x5 is no longer exogenous (x5 and x1 are conditionally 
# dependent)

tau.iv = (mean(y[x3==1 & x4 == 1])- mean(y[x3==0 & x4==1]))/(mean(x1[x3==1 & x4==1])-mean(x1[x3==0 & x4==1]))

print(round(c(tau.iv, mean(y1[x4==1]) - mean(y0[x4==1])),3))

# the IV estimator actual estimates the LATE, assuming monotonicity

x1.1 = f1(x2,rep(1,n),eps1)
x1.0 = f1(x2,rep(0,n),eps1)

# check monotonicity
mean(x1.1 >= x1.0)

LATE = mean(y1[x4 == 1 & (x1.1 - x1.0) == 1]) - mean(y0[x4 == 1 & (x1.1 - x1.0) == 1])

print(round(c(tau.iv, LATE),2))

# if we control for x2, we should be able to get what we want
# from the naive estimates

taux2.1 = mean(y[x1== 1 & x4 == 1 & x2 == 1])- mean(y[x1==0 & x4 == 1 & x2 ==1])
taux2.0 = mean(y[x1== 1 & x4 == 1 & x2 == 0])- mean(y[x1==0 & x4 == 1 & x2 ==0])

temp1 = mean(x2[x4==1]==1)*taux2.1 + mean(x2[x4==1]==0)*taux2.0
temp2 = mean(y1[x4==1]) - mean(y0[x4==1])
print(round(c(temp1,temp2),2))
