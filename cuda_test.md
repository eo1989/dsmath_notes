---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.17.1
  kernelspec:
    display_name: Gen
    language: python
    name: python3
---

```python
import time
import torch as to
```

```python
# device = "cuda" if to.cuda.is_available() else "cpu"
# device
```

```python
class Device:
    def __init__(self, name: str):
        self.name = name


def device_benchmark():
    device_name = "cuda" if to.cuda.is_available() else "cpu"

    device = Device(name=device_name)

    def measure_time(device):
        match device:
            case "cuda":
                # gpu computation timing
                to.cuda.synchronize()
                start_time = to.cuda.Event(enable_timing=True)
                end_time = to.cuda.Event(enable_timing=True)

                start_time.record()
                result = (
                    to.rand(500, 500, 500, device="cuda")
                    @ to.rand(500, 500, 500, device="cuda")
                ).sum()
                end_time.record()
                to.cuda.synchronize()

                return start_time.elapsed_time(end_time) / 1000  # convert to seconds
                # print(f"t_gpu = {gpu_time:.5f} seconds")

                # print(f"t_gpu = {(to.rand(500, 500, 500).cuda()@to.rand(500, 500, 500).cuda())}")
            case "cpu":
                # cpu computation timing
                start_time = time.time()
                result = (
                    to.rand(500, 500, 500, device="cpu")
                    @ to.rand(500, 500, 500, device="cpu")
                ).sum()

                return time.time() - start_time
                # print(f"t_cpu = {cpu_time:5f} seconds")
                # print(f"t_cpu = {(to.rand(500, 500, 500, device = args['cpu'])@to.rand(500, 500, 500, device = args['cpu'])).sum()}")
            # case _:
            #     print("Unsupported device detected.")

    # Match-case logic for device
    match device.name:
        case "cuda":
            t_cpu = measure_time("cpu")
            t_gpu = measure_time("cuda")
            print(f"t_cpu = {t_cpu:.5f} seconds")
            print(f"t_gpu = {t_gpu:.5f} seconds")
            return t_cpu, t_gpu
        case "cpu":
            t_cpu = measure_time("cpu")
            print(f"t_cpu = {t_cpu:.5f} seconds")
            print("t_gpu = None (GPU not available)")
            return t_cpu, None
        case _:
            print("Unsupported device detected.")
            return None, None


t_cpu, t_gpu = device_benchmark()
# device_benchmark()

# match device:
#     case "cuda":
#         device_type = "gpu"
#         device_name = to.cuda.get_device_name()
#         # t_gpu = to.rand(500, 500, 500).cuda()
#     case "cpu" | _:
#         t_cpu = to.rand(500, 500, 500)
# t_cpu = to.rand(500, 500, 500)
# t_gpu = [if to.cuda.get_device_name(i) for i in range(to.cuda.device_count()) == True: then t_]

```

```python
# t_gpu = to.rand(500, 500, 500).cuda()
# %timeit t_gpu @ t_gpu
```

```python

```
