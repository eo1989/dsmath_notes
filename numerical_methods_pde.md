
# Numerical Methods for PDE

## Exercise 1

Solve the following advection equation $u_{t} - u_{x} = 0$ for $x \in (0, 1)$ and $T = 2$ with FTCS, BTCS,
& Leapfrog schemes. The initial data is given by
$$
u(0, x) = e^{\frac{-(x-0.2)^2}{0.01}}
$$
using the periodic boundary condition.

```python
# import scipy.sparse.linalg as spla
# from scipy.sparse import csr_matrix
import numpy as np
import matplotlib.pyplot as plt
import scipy.sparse as sp
import matplotlib.animation as animation
from matplotlib.animation import FuncAnimation
from matplotlib import rc
rc('animation', html = 'jshtml')
```

```python
# tmax = 1
# xmax = 1

# temporeal & spatial domains
tmin, tmax = 0, 1

xmin, xmax = 0, 1

# parameter of the eq u_t - u_x = 0
a = -1

# initial condition
def init_u(x):
    return np.exp(-np.power((x - 0.2), 2) / 0.01)

# grid points
N, J = 500, 50

# each value of the U array contains the sol for all x vals at each timestep
U = []

dt = (tmax - tmin)/N
h = (xmax - xmin)/(J - 1)

_lambda = dt/h

# x grid of J points (to plot the graph)
X, dx = np.linspace(xmin, xmax, J, retstep=True)
```

FTCS graph scheme below:

```python
def u(x, t):
    if t == 0:
        return init_u(x)

    uvals = []  # u values for this timestep

    for j in range(len(x)):
        if j == 0:
            uvals.append(U[t - 1][j] + a * _lambda / 2 * (U[t - 1][J - 1] - U[t - 1][j + 1]))
        elif j == J - 1:
            uvals.append(
                U[t - 1][j] + a * _lambda / 2 * (U[t - 1][J - 1] - U[t - 1][0])
            )
        else:
            uvals.append(
                U[t - 1][j]
                + a * _lambda / 2 * (U[t - 1][J - 1] - U[t - 1][j + 1])
            )
    return uvals


# solve for 500 time steps
for t in range(N):
    U.append(u(X, t))


# plot
plt.style.use('mpl20')
fig, ax = plt.figure()
ax1 = fig.add_subplot(1, 1, 1)

k = 0

def animate(i) -> None:
    global k
    x = U[k]
    k += 1
    ax1.clear()
    ax1.grid(True)
    ax1.set_xlim([0, 1])
    ax1.set_ylim([-2, 2])
    ax1.plot(X, x, color='cyan')


anim = animation.FuncAnimation(fig, animate, frames=360, interval = 20)

```
