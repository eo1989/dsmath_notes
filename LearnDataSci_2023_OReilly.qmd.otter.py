

















import numpy as np

urn = ["b", "b", "b", "w", "W"]



print(f"Samples 1:", np.random.choice(urn, size=2, replace=False))
print(f"Samples 2:", np.random.choice(urn, size=2, replace=False))



n = 10_000
samples = [np.random.choice(urn, size=2, replace=False) for _ in range(n)]
is_matching = [marble1 == marble2 for marble1, marble2 in samples]
print(f"Proportion of samples with matching marbles: {np.mean(is_matching)}")



from itertools import combinations

all_samples = ["".join(sample) for sample in combinations("ABCDEFG", 3)]
print(all_samples)
print(f"{'----' * 40}")
print(f"Number of Samples: {len(all_samples)}")



from itertools import permutations

print(["".join(sample) for sample in permutations("ABC")])















urn = [1, 1, 0, 1, 0, 1, 0]
sample = np.random.choice(urn, size=3, replace=False)
print(f"Sample: {sample}")
print(f"Prop Failures: {sample.mean():.3f}")



samples = [np.random.choice(urn, size=3, replace=False) for _ in range(10_000)]
prop_failures = [s.mean() for s in samples]



import pandas as pd

unique_els, counts_els = np.unique(prop_failures, return_counts=True)
pd.DataFrame({
    "Proportion of Failures": unique_els,
    "Fraction of Samples": counts_els / 10_000,
})



simulations_fast = np.random.hypergeometric(
    ngood=4, nbad=3, nsample=3, size=10_000
)
print(simulations_fast)





from scipy.stats import hypergeom

num_failures = [0, 1, 2, 3]
