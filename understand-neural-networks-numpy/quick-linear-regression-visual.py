import numpy as np
import random
from matplotlib import pyplot as plt 

# Parameters: slope (a_), y-intercept (b_), number of points (N), randomness amplitude (R)
a_, b_, N, R = 2, 10, 100, 6

# Create dataset
x = np.linspace(0, 10, N)
y = a_ * x + b_
for i in range(N):
    y[i] += R * (random.random() - 0.5)

# Calculate best fit line
SX2, SX, SXY, SY = sum(x**2), sum(x), sum(x*y), sum(y)
M = np.array([[SX2, SX], [SX, N]])
V = np.array([[SXY], [SY]])
a, b = np.dot(np.linalg.inv(M), V)
y_f = a * x + b

# Plot the results
plt.subplots(figsize=[8, 4.5])
plt.scatter(x, y)
plt.plot(x, y_f, label='Line Fit')

# Plot residuals
for i in range(N):
    plt.plot([x[i], x[i]], [y[i], y_f[i]], ':', color='r', zorder=0)

# Add labels, title, and legend
info_str = f'Fit: y = {float(a[0]):.5f}x + {float(b[0]):.5f}'
plt.xlabel(f'x\n{info_str}')
plt.ylabel('y')
plt.title('Datapoints & Line Fit')
plt.legend(['Line Fit', '${x_i,y_i}$ Data', 'Residuals'])

plt.show()
