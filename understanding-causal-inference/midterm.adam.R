rm(list = ls())
n = 500000

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
      y = (2*f1(x2,x3,eps1)*x5 - 25*(x5 > 0) + epsy)
    }else{
      y = (2*x1*x5 - 25*(x5 > 0) + epsy)}
  return(y)
}

# generate the observed data
y = Y(x2,x3,x5,eps4,eps1,eps6,epsy)

# 1. generate the counterfactual potential outcomes corresponding to 
# do(x3 = 1) and do(x3 = 0), then set x3=0 and compute the potential outcomes
y1 = Y(x2,rep(1,n),x5,eps4,eps1,eps6,epsy)
y0 = Y(x2,rep(0,n),x5,eps4,eps1,eps6,epsy)

# 2. compute the true average treatment effect (ATE)
tau <- mean(y1 - y0)

#3. compute the naive estimate of the ATE
tau.est <- mean(y[x3==1])- mean(y[x3==0])
# dont know true potential outcome for both treatments, to estimate ATE. Might differ from true ATE due to confounding variables.

# 4. compare the two
# they are not exactly the same but they're very close due to the large sample size and the fact that x3 is exogenous
# these match within 0.01 of tau.est and tau 
print(round(c(tau.est, tau), 3))
print(tau.est - tau)

# 5. now consider some sub-population estimands
# first, how about the population with x6 == 1
print(
  round(
    c(
      mean(y[x3==1 & x6 == 1]) - mean(y[x3==0 & x6 == 1]),  # E(Y1 - Y0 | X3 = 1, X6 = 1) 
      mean(y1[x6==1]) - mean(y0[x6==1])                     # E(Y1 - Y0 | X6 = 1) where y1, y0 are generated 
    ), 2)
)

 # E(Y1 - Y0 | X3 = 0, X6 = 1) approx E(Y1 - Y0 | X6 = 1) because x3 is exogenous and already conditioned on (double-conditioning)
# also, x6 is the descendent of x4, where x4 is a collider. 

# next how about among the population with x6 = 0
print(
  round(
    c(
      mean(y[x3==1 & x6 == 0])- mean(y[x3==0 & x6 == 0]), # E(Y1 - Y0 | X3 = 1, X6 = 0)
      mean(y1[x6==0]) - mean(y0[x6==0])                   # E(Y1 - Y0 | X6 = 0) where y1, y0 are generated
      ),2)
  )
# likewise, doubly-conditioning on x3 (extrageneous) and x6 (descendent of x4) which makes the two very similar

# these can all be estimated without problem from the observed data because x3 is exogenous
# the two numbers do coincide because x3 is exogenous and x6 is a descendent of x4 which is a collider.

#8,9,10 what about the population x1 = 1?
print(
  round(
    c(
      mean(y[x3==1 & x1 == 1])- mean(y[x3==0 & x1 == 1]),
      mean(y1[x1 == 1]) - mean(y0[x1 == 1]))
      ,2
    )
)
# the two are very different now, this is due to the fact that conditioning on x1 is a mediator of the treatment effect
# these two do not coincide because x1 is a mediator of the treatment effect

# 11. d = x1 treatment, setting x3 back to normal
y1 = Y(x2, x3, x5, eps4, eps1, eps6, epsy, x1 = rep(1,n))
y0 = Y(x2, x3, x5, eps4, eps1, eps6, epsy, x1 = rep(0,n))

# 12. compute the true treatment effect
# naive estimate
tau.est <- mean(y[x1==1])- mean(y[x1==0])

# 13. compute the true treatment effect 
tau <- mean(y1) - mean(y0)

# 14. do these numbers match?
print(round(c(tau.est,tau),3))
print(tau - tau.est)

# these values do match approximately since x1 is the treatment effect, because both satisfy the backdoor criterion. 

# 15-16. what if we want the treatment effect among the x4 = 1 subgroup?
tau.naive <- mean(y[x1==1 & x4 == 1])- mean(y[x1==0 & x4 == 1])
tau <- mean(y1[x4 == 1]) - mean(y0[x4 == 1])

print(round(c(tau.naive, tau),3))
print(tau - tau.naive)

# 17. Do these numbers coincide?
# No, these are radically different now since x4 is a collider and conditioning on it will open up the backdoor path

temp1 <- mean(y[x1==1 & x4==1 & x2==1])-mean(y[x1==0 & x4==1 & x2==1])
temp0 <- mean(y[x1==1 & x4==1 & x2==0])-mean(y[x1==0 & x4==1 & x2==0])
tau.right <- mean(x2[x4==1]==1)*temp1 + mean(x2[x4==1]==0)*temp0

df <- data.frame(y = y[x4==1], x1 = x1[x4==1], x2 = x2[x4==1],x5 = x5[x4==1])

# fit two models, one to treated, one to control
fit1 <- rpart(y~x2+x5,data = df, subset = x1==1)
fit0 <- rpart(y~x2+x5,data = df, subset = x1==0)
# 
# predict for everyone for both models; take the difference
cates <- predict(fit1,newdata = df) - predict(fit0,newdata = df)
# 
tau.ml <- mean(cates)
# 
# by taking the average over the full sample, the CATEs are automatically weighted 
# according to the the correct marginal probabilities

print(round(c(tau.naive, tau.right,tau.ml, mean(y1[x4 == 1]) - mean(y0[x4 == 1])),2))

# 18. IV estimator: consider the IV estimator using x3 as an instrument (Z) for x1 in the case where the
# estimand of interest is the subgroup average treatment effect for x4 = 1. Is x3 a valid
# instrument?

# x3 is a valid instrument because it is exogeneous and x1 is a collider, where x2 and x3 feed into x1.
# therefore, x3 can be used as an instrument because we can meddle with x3 and see how it affects response y through x1.


tau.iv = (mean(y[x3==1 & x4 == 1]) - mean(y[x3==0 & x4==1])) / (mean(x1[x3==1 & x4==1])-mean(x1[x3==0 & x4==1]))


#19. Calculate the IV estimate from the observed data. Does it match the true subgroup 
# ATE computed above? Why or why not?

# tau.obs = ?

#  the IV estimate is not the same as the true subgroup ATE because x3 is not a valid instrument for x1 in this case

# from IV estimator formula for tau.iv:
#
#           E( Y | D = 1, X4 = 1) - E( Y | D = 0, X4 = 1) 
#       ----------------------------------------------------------
#         E( Z = X1 | D = 1, X4 = 1) - E( Z = X1 | D = 0, X4 = 1)

print(round(c(tau.iv, mean(y1[x4==1]) - mean(y0[x4==1])),3))

# these do not match since x3 

# 20. the IV estimator actual estimates the LATE, assuming monotonicity
x1.1 = f1(x2,rep(1,n),eps1)
x1.0 = f1(x2,rep(0,n),eps1)
# check monotonicity
mean(x1.1 >= x1.0)

# 21. Use the generated potential outcomes, in both Y and D = X1, to compute the (sub-
# group) local average treatment effect (LATE): E(Y1 −Y0 | D1 − D0 = 1, X4 = 1).
# Does this match the IV estimate calculated above?
LATE = mean(y1[x4 == 1 & (x1.1 - x1.0) == 1]) - mean(y0[x4 == 1 & (x1.1 - x1.0) == 1])

print(round(c(tau.iv, LATE),2))
# No this does not match. The LATE is the true subgroup ATE, but the IV estimator is not the same as the true subgroup ATE

# 22. Estimate the subgroup average treatment effect (for x4 = 1 as above) by blocking
# on x2 as a control variable. That is, compute separate estimates of the ATE on the
# x2 = 1 and x2 = 0 data and combine them with weights proportional to the size of the
# subpopulation.

taux2.1 = mean(y[x1== 1 & x4 == 1 & x2 == 1])- mean(y[x1==0 & x4 == 1 & x2 ==1])
taux2.0 = mean(y[x1== 1 & x4 == 1 & x2 == 0])- mean(y[x1==0 & x4 == 1 & x2 ==0])

temp1 = mean(x2[x4==1]==1)*taux2.1 + mean(x2[x4==1]==0)*taux2.0
temp2 = mean(y1[x4==1]) - mean(y0[x4==1])
print(round(c(temp1,temp2),2))

# 23. Does this match the true subgroup average treatment effect calculated above? Why or why not?
# Yes, within 0.05 of the true value because x2 is exogeneous and x4 is a collider, so conditioning on x2 is valid and does not open up the backdoor path