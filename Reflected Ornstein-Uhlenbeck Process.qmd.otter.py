
















import matplotlib.pyplot as plt
from matplotlib import cm
import numpy as np
import scipy as sc
import scipy.stats as st
import scipy.sparse as sp
























#| freeze: true

np.random.seed(42)

N = 15_000      # time steps
paths = 5_000   # num of steps
T = 1
T_vec, dt = np.linspace(0, T, N, retstep=True)

kappa = 5
theta = 0       # lets keep a theta, but set to zero
sigma = 4
std_asy = np.sqrt(sigma**2 / (2*kappa))  # asymptotic std for OU

X0 = 0
X = np.zeros((N, paths))
X[0, :] = X0
std_dt = np.sqrt(sigma**2 / (2*kappa) * (1 - np.exp(-2*kappa*dt)))
W = st.norm.rvs(loc = 0, scale = std_dt, size = (N - 1, paths))

exp_ = np.exp(-kappa * dt)
for t in range(N - 1):
    X[t + 1, :] = theta + exp_ * (X[t, :] - theta) + W[t, :]
    X[t + 1, :] = np.where(X[t + 1, :] > 0.0, X[t + 1, :], 0.0)

X_T = X[-1, :]  # values of X at time T
X_1 = X[:, 0]   # a single path




mu = X_T.mean()
std = X_T.std()

print(f"Mean = {mu:.6f}, Std = {std:.6f}")


N_processes = 2     # num of processes
x = np.linspace(X_T.min(), X_T.max(), 100)
pdf_fitted = st.norm.pdf(x, loc = mu, scale = std)

fig = plt.figure(figsize = (16, 5))
ax1 = fig.add_subplot(121)
ax2 = fig.add_subplot(122)

ax1.plot(T_vec, X[:, :N_processes], linewidth = 0.5)
ax1.plot(T_vec, (theta + std_asy) * np.ones_like(T_vec), label = "1 asymptotic std dev", color = "black")
ax1.plot(T_vec, (theta + 3 * std_asy) * np.ones_like(T_vec), label = "3 asymptotic std dev", color = "blue")
ax1.plot(T_vec, theta * np.ones_like(T_vec), label = "Long term mean")
ax1.legend(loc = "upper right")
ax1.set_title(f"{N_processes} OU Proccesses")
ax1.set_xlabel("T")

ax2.plot(x, pdf_fitted, color = "r", label = "Normal Density")
ax2.hist(X_T, density = True, bins = 50, facecolor = "LightBlue", label = "Frequency of X(T)")
ax2.legend()
ax2.set_title("Histogram vs Normal Distribution")
ax2.set_xlabel("X(T)")
plt.show()










T_to_asy = np.argmax(X >= 1 * std_asy, axis=0) * dt  # first exit time
print(
  f"Are there paths that never touch the line? {(T_to_asy == 0).any()}\n",
  f"The expected time is {T_to_asy.mean()} with standard error {st.sem(T_to_asy)}"
  )









































Nspace = 500_000  # space steps
x_max = 1 * std_asy
x_0 = 0
x, dx = np.linspace(x_0, x_max, Nspace, retstep=True)  # space discretization

U = np.zeros(Nspace)             # grid initialization
consterm = -np.ones(Nspace - 1)  # -1

# construction of the tri-diagonal matrix D
sig2_dx = (sigma * sigma) / (dx * dx)
a = kappa * x[:-1] / dx + 0.5 * sig2_dx
b = -kappa * x[:-1] / dx - sig2_dx
c = 0.5 * sig2_dx * np.ones_like(a)

b[0] = -0.5 * sig2_dx            # term added from BC at x0

# aa = a[1:]
# cc = c[:-1]                      # upper and lower diagonals
# D = sp.diags([aa, b, cc], [-1, 0, 1], shape=(Nspace - 1, Nspace - 1)).tocsc()  # matrix D

from scipy.linalg import solve_banded

n = Nspace - 1

# diagonals (same)
lower = a[1:]    # length n - 1
main  = b        # length n
upper = c[:-1]   # length n - 1

# banded matrix
ab = np.zeros((3, n))
ab[0, 1:]  = upper
ab[1, :]   = main
ab[2, :-1] = lower




# from scipy.sparse.linalg import spsolve
# U[:-1] = spsolve(D, consterm)

rhs = consterm   # length n, all -1

U[:-1] = solve_banded((1, 1), ab, rhs)
**U**[-1] = 0.0

fig = plt.figure(figsize=(8, 5))
plt.title("Expected time to reach std_asy as func of the starting pt.")
plt.plot(x, U)
plt.xlabel("x")
plt.ylabel("Expected Time")






# from scipy.linalg import solve_banded
# n = Nspace - 1

# diagonals (same)
# lower = a[1:]    # length n - 1
# main  = b        # length n
# upper = c[:-1]   # length n - 1

# banded matrix
# ab = np.zeros((3, n))
# ab[0, 1:]  = upper
# ab[1, :]   = main
# ab[2, :-1] = lower

# rhs = consterm   # length n, all -1

# U[:-1] = solve_banded((1, 1), ab, rhs)
# U[-1] = 0.0

print(f"Expected time to reach 1 std_asy starting from zero: {U[0]:4g}")
