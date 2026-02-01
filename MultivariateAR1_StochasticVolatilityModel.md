---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.17.1
  kernelspec:
    display_name: python3 (ipykernel)
    language: python
    name: python3
---

# Multivariate AR(1) with Stochastic Volatility

```python
import pytensor
import pytensor.tensor as pt
import pymc as pm
from pymc.pytensorf import collect_default_updates
import arviz as az

```

```python
lags = 2 # number of lags
trials = 100 # time series length
n_ts = 5

def ar_dist(ar_init, rho, sigma, size):
    def ar_step(x_tm2, x_tm1, rho, sigma):
        mu = x_tm1 * rho[0] + x_tm2 * rho[1]
        x = mu + pm.Normal.dist(sigma=sigma)
        return x, collect_default_updates([x])

    ar_innov, _ = pytensor.scan(
        fn=ar_step,
        outputs_info=[{"initial": ar_init, "taps": range(-lags, 0)}],
        non_sequences=[rho, sigma],
        n_steps=trials - lags,
        strict=True,
    )

    return ar_innov

```

```python
coords = {
    "lags": range(-lags, 0),
    "steps": range(trials - lags),
    "trials": range(trials),
    "batch": range(n_ts),
}

with pm.Model(coords=coords, check_bounds=False) as batch_model:
    rho = pm.Normal(name = "rho", mu = 0, sigma = 0.2, dims = ("lags", "batch"))
    sigma = pm.HalfNormal(name = 'sigma', sigma = 0.2, dims = ("batch"))

    ar_init = pm.Normal(name = 'ar_init', dims = ("lags", "batch"))

    ar_innov = pm.CustomDist(
        "ar_dist",
        ar_init,
        rho,
        sigma,
        dist = ar_dist,
        dims = ("steps", "batch"),
    )

    ar = pm.Deterministic(
        name = "ar",
        var = pt.concatenate([ar_init, ar_innov], axis=0),dims = ('trials', 'batch')
    )

```

```python
import matplotlib.pyplot as plt

with batch_model:
    prior_idata = pm.sample_posterior_predictive()
```

```python

```
