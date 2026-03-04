---
layout: page
title: "Profiling Python programs on GPUs: tracing with Tau2"
description: 
date: 2026/03/04
img: assets/img/3.jpg
importance: 0
category: software
---

Finding bottleneck kernels in parallel programs is key to
unlocking the peak performance of a software application. 
System-wide profiling tools prove a developers best friend
for such a task; aggregating low-level metrics from hardware 
and software program counters into standard file formats
(i.e., [JSON](https://en.wikipedia.org/wiki/JSON)) that can 
be intuitively visualized with [flame graphs](https://www.brendangregg.com/flamegraphs.html). 
Major GPU developers offer bespoke profilers for their hardware:
[Nsight Systems](https://developer.nvidia.com/nsight-systems) from NVIDIA,
[ROCm Systems](https://rocm.docs.amd.com/projects/rocprofiler-systems/en/latest/index.html) from AMD, 
and the [VTune™ Profiler](https://www.intel.com/content/www/us/en/developer/tools/oneapi/vtune-profiler.html) from Intel.
Addressing this vendor-beholden fractured landscape, 
the good folks in the CS department at University of Oregon provide
[TAU Performance System®](https://www.cs.uoregon.edu/research/tau/home.php), 
a portable and open-source system-wide profiler
for high-performance computing applications.
