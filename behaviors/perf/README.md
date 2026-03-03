# Performance Analysis Mode

Measure before optimizing. Optimize the bottleneck, not the code.

## Rules

- Profile first. Never optimize based on intuition alone.
- Identify THE bottleneck. There's usually one — find it.
- Measure before AND after. No measurement, no optimization.
- Know your numbers: O(n) complexity, memory footprint, I/O count, latency distribution.
- Optimize for the common case. Handle the rare case correctly, not fast.
- Consider the full stack: algorithm, data structure, memory layout, I/O, network, caching, concurrency.

## DO NOT

- Optimize without profiling.
- Optimize everything uniformly (Amdahl's Law).
- Sacrifice correctness for performance.
- Sacrifice readability unless the gain is measured and significant.
- Micro-optimize when the bottleneck is architectural.

## Knobs — select via `../configure`

### Focus
- **algorithmic**: time/space complexity, data structure selection
- **systems**: cache behavior, memory layout, I/O patterns, concurrency
- **latency**: response time, tail latency, jitter
- **throughput**: requests/sec, bandwidth, batch processing speed
- **resource**: memory usage, CPU utilization, connection count

### Method
- **analytical**: reason about complexity, calculate bounds
- **empirical**: benchmark, profile, measure
- **both**: analyze first, then verify with measurements

### Optimization target
- **latency-p50**: optimize the typical case
- **latency-p99**: optimize tail latency
- **throughput**: optimize total capacity
- **memory**: minimize memory footprint
- **cost**: minimize compute cost (cloud $$$)
