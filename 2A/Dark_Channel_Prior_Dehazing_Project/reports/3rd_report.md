---
title: "3ème rapport - Projet Image - Single Image Haze Removal Using Dark Channel Prior"
author: "Elena Fleury, Yan Rabefaniraka"
date: "14 Avril 2026"
geometry: "margin=2.5cm"
fontsize: 11pt
linestretch: 1.5
papersize: a4
header-includes:
  - \usepackage{amsmath}
  - \usepackage{graphicx}
  - \usepackage{float}
  - \usepackage{fvextra}
  - \DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,commandchars=\\\{\}}
---

# Work carried out during the session
We tried to drastically speed up the dark channel computation as using native Python *for loops* made it extruciatingly slow. We tried by using both Opencv's *erode* function that does the same thing as our loops and obtained the exact same result.

Similarly, we tried to parallelise the *for loop* version using *Taichi* (python parallelisation library) which got us the same speed and the exact same result

Example of an estimated dark channel yielded by our now faster code:

![Dark Channel Computation Result](dark_channel2.png)

## Difficulties encountered
Rediscovering the taichi library can be extrenuous since it almost changes the language's paradigm.

# Future sessions
Continue pipeline implementations and test atmospheric light results.