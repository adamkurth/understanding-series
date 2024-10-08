# instrumental variables
# cause of smoking on cancer (Y), 
# with using instrument such as tax on cigarettes (Z), and 
# D being the dose of cigarettes smoked per day
# U is the unobserved confounder

# Z ~ N(5, 2^2) 
# U ~ N(0, 1)
# D = BZ + alpha*U + e_alpha, D is continuous
# Y = tau*D + gamma*U + e_Y

# E(Y|D) = E( E(Y | D,U )) # iterated expectation
#  = E( tau*D + gamma*U)
#  = tau*D + gamma*E(U | D)

# tau*(D+1) + gamma*E(U | D+1) - (tau*D + gamma*E(U | D))
# tau + gamma*[ E( U | D > d+1) - E( U | D=d)] # omitted variable bias 
# gamma*[ E( U | D > d+1) - E( U | D=d)] term is 0.8 when we change alpha from 4 to -4

# ==================================================

# generate data
n <- 500000
alpha <- 4
beta <- -1
sig_d <- 0.1
sig_y <- 0.5
tau <- 3
gamma <- 4

z <- rnorm(n,5,2)
u <- rnorm(n,0,1)
d <- beta*z + alpha*u + sig_d*rnorm(n,0,1)
y <- tau*d + gamma*u + sig_y*rnorm(n,0,1)

summary(lm(y~d)) # doesnt work, unobserved variable bias
# include omitted variable u 
summary(lm(y~d+u)) # eworks but infesible because no u
# include instrumental variable z
summary(lm(y~d+z)) # does not work as we want

# ==================================================
# in the directions of the arrows substitute the equation of D into Y.
# Y = tau( beta*Z + alpha*U + e_alpha ) + gamma*U + e_Y
#  = tau*beta*z + (tau*alpha*u + tau*eps_alpha + gamma*U + e_Y) 

# called Two Stage Least Squares (2SLS) estimation
#1. Y ~ Z => tau*beta
#2. D ~ Z => beta

# where D is the normal equation D = beta*Z + alpha*U + e_alpha

fit_yz <- lm(y~z)
fit_dz <- lm(d~z)

fit_yz$coefficients[2] / fit_dz$coefficients[2] # tau
# ==================================================
