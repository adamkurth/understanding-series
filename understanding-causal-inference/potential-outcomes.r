# lecture 2: 
# potential outcomes vs. conditional means for causal inference

# generate epsilons
n <- 50000
eps1 <- runif(n) 
eps2 <- runif(n) 
eps3 <- runif(n) 
eps4 <- runif(n) 
epsd <- runif(n)
epsy1 <- runif(n)
epsy2 <- runif(n,-0.9, -0.5)

x1 <- qnorm(eps1) # uniform to normal using inverse cdf
x2 <- qnorm(eps2) + x1 # x2 depends on x1 (deterministic, but not linear)
plot(x1,x2, pch=20, cex=0.1)

x4 <- qbeta(eps4, shape1 = 5, shape2 = 2) # uniform to beta using inverse cdf
x3 <- qnorm(eps3, mean = 2, sd = 0.5 + x4) # x3 depends on x4
plot(x4,x3)

# treatment 0,1
dprob <- 1/(1+exp(-2 - x1 + x3 + 0.25*epsd)) # deterministic treatment assignment
d <- rbinom(n, size = 1, prob = dprob) # treatment assignment
hist(dprob)

mean(x2)
mean(x2[d==1]) # treatment effect
mean(x2[d==0]) # control effect

# probability does not 
y <- epsy2*d + x2 + x4 + epsy # outcome

y1 <-  epsy2*1 + x2 + x4 + epsy
y0 <- epsy2*0 + x2 + x4 + epsy
tauhat.naive <- mean(y[d==1]) - mean(y[d==0]) # naive estimate

ATE_true <- mean(y1) - mean(y0) # true treatment effect
tauhat.naive <-mean(y[d==1]) - mean(y[d==0]) # naive estimate
print(rbind(ATE_true, tauhat.naive))
# note: ATE not exactly -0.7

# this illustrates that Y | Z = z is not the same as Y^z 

# note that these are different!
# d==1
hist(y1,40,freq=FALSE)
hist(y[d==1],40,freq=FALSE, col="red", add=TRUE)
# d==0
hist(y1,40,freq=FALSE)
hist(y[d==0],40,freq=FALSE, col="red", add=TRUE)
