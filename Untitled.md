---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: "1.3"
      jupytext_version: 1.17.0
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---


```python
import numpy as np
import scipy.stats as stat

seed = 42

# rando data
m1 = [0., 0.]
m2 = [4., -4.]
m3 = [-4., 4.]
x1 = stat.multivariate_normal.rvs(m1, size = 100, random_state = seed)
x2 = stat.multivariate_normal.rvs(m2, size = 100, random_state = seed)
x3 = stat.multivariate_normal.rvs(m3, size = 100, random_state = seed)
x = np.vstack([x1, x2, x3])
y = np.zeros(300, dtype=np.int8)
y[100:200] = 1
y[200:300] = 2

import matplotlib.pyplot as plt
plt.scatter(x[:, 0], x[:, 1], c = y)

def calc_grad(x, pk, m):
    nx = np.zeros((300, 3))
    for i in range(3):
        nx[:, i] = stat.multi
```
