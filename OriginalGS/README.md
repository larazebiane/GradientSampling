# Gradient Sampling Algorithm

This repository implements the **Gradient Sampling (GS) algorithm**, a powerful method for solving nonsmooth, nonconvex optimization problems.

Traditional gradient-based optimization methods can struggle when the objective function is not differentiable everywhere. The GS algorithm addresses this by sampling gradients in a neighborhood around the current point, forming a convex hull of these gradients, and then using this information to construct descent directions.

---

## 🔍 Algorithm Overview

The GS algorithm works by:

1. Sampling gradients of the objective function in a small ball around the current iterate.
2. Computing a generalized descent direction based on the convex hull of sampled gradients.
3. Performing a line search to ensure sufficient decrease.
4. Updating parameters and repeating until convergence.

The method is particularly useful for problems where the objective function is **locally Lipschitz but not differentiable everywhere**, such as in robust statistics, machine learning with ReLU networks, and piecewise-linear models.

---

## 📌 Pseudocode

The following pseudocode outlines the complete Gradient Sampling algorithm for minimizing an objective function:

$$
f : \mathbb{R}^n \rightarrow \mathbb{R}
$$

where $f$ is **locally Lipschitz** and **continuously differentiable** in an open set $\mathcal{D} \subset \mathbb{R}^n$ with full measure.


<p align="center">
  <img src="assets/alg1.png" width="600" alt="Gradient Sampling Pseudocode">
</p>

---

## 💻 Code Availability

The pseudocode above is implemented in the MATLAB file [`GS.m`](./GS.m), which provides the full Gradient Sampling algorithm. The main function has the following signature:

```matlab
[x_opt, info] = GS(x0, f,g, nonDiffPoints, epsilon0, nu0, m, n, beta, gamma, epsilon_opt, nu_opt, theta_epsilon, theta_nu, maxit);
```

To test the implementation, see the script [`GS.m`](./GS.m), which sets up an example objective function, its gradient, and relevant parameters.

---

## 🧪 Results & Analysis

The following table summarizes the results obtained by running the `GS.m` algorithm on the **piecewise-defined, nonsmooth function** implemented in [`testGS.m`](./testGS.m). This example showcases how the Gradient Sampling method performs in practice when minimizing a function that is not differentiable everywhere.

| Iter | xₖ       | f(xₖ)   | ‖gₖ‖      | εₖ     | νₖ     | tₖ |
|------|----------|---------|---------|--------|--------|----------------|
| 0    | 3.00000  | 3.5000  | 0.5000  | 0.1    | 0.001  |   1            |
| 1    | 2.50000  | 3.2500  | 0.5000  | 0.1    | 0.001  | 1              |
| 2    | 1.98483  | 2.9848  | 0.5000  | 0.1    | 0.001  | 1              |
| 3    | 1.48483  | 2.4848  | 0.5000  | 0.1    | 0.001  | 1              |
| 4    | 0.484832 | 1.4848  | 1.0000  | 0.1    | 0.001  | 1              |
| 5    | -0.515168| 0.4848  | 1.0000  | 0.1    | 0.001  | 0.5            |
| 6    | -1.01517 | 0.0152  | 0.0000  | 0.001  | 0.001  | 1              |
| 7    | -1.01517 | 0.0152  | 0.0000  | 0.001  | 0.001  | 1.56e-02     |
| 8    | -0.999543| 0.0005  | 0.0000  | 0.001  | 0.001  | 1              |

A step-by-step explanation of how the algorithm behaves in this case:

Starting at $x_0=3$, the gradient in the neighborhood is constant at 0.5, so the algorithm moves to $x_1=2.5$ using a full step size. Another full step would take us to $x_2=2$, but since the function is nondifferentiable there, the algorithm instead moves to a nearby differentiable point $x_2=1.98483$. The algorithm continues similarly until iteration 6, where it finds an approximate stationary point $x_6=−1.01517$ with gradient close to zero. At this point, the sampling radius shrinks and the algorithm stays at the same point for one iteration before finally terminating at $x_8$ ​ after meeting the stopping criteria.

---

