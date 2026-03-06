---
layout: page
title: "Profiling Python programs on GPUs: tracing with TAU"
description: 
date: 2026/03/04
img: assets/img/3.jpg
importance: 0
category: software
---

# System-wide Profilers

Finding & optimizing bottleneck kernels is key to
unlocking peak performance of parallel programs. 
System-wide profiling tools are a developers best friend
for such tasks; aggregating low-level metrics from hardware 
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

# A Toy Problem


<div align="center">
  <img src="../../assets/img/bicubic_interpolation.svg" alt="Bicubic interpolation on a uniform grid">
</div>


Consider the problem of [bicubic interpolation](https://en.wikipedia.org/wiki/Bicubic_interpolation) pictured above: 
given values of some function $$f(ih, jh)$$ on a uniform grid with mesh spacing $$h$$ and $$i,j = 0,1,...$$, compute the interpolated function value $$p$$ at given coordinates $$(x,y)$$ via the formula
\begin{equation}
    p(x,y) = \sum_{d_i=-1}^{2}\sum_{d_j=-1}^{2} w_{i,j} f((a_x+d_i)h, (a_y+d_j)h),
\end{equation} 
where $$(a_x, a_y) := (\lfloor x \rfloor, \lfloor y \rfloor)$$ are the *anchors* and $$w_{i,j}$$ are some weights determined by the offsets $$N_x = a_x - x$$ and $$N_y = a_y- y$$; for this example, we choose weights generate by [Lagrange polynomials](https://en.wikipedia.org/wiki/Lagrange_polynomial).  
