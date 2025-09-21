function [gk, sampled_points] = compute_gk(xk, g, epsilon_k, m)
% COMPUTE_GK Approximates the gradient at point xk using gradient sampling.
%
% Inputs:
%   xk        - Current point (column vector)
%   g         - Function handle for gradient evaluation
%   epsilon_k - Sampling radius
%   m         - Number of sample points
%
% Outputs:
%   gk             - Approximated gradient at xk
%   sampled_points - Points sampled around xk where gradients were evaluated

% Initialize matrix to store gradients: each column is a gradient vector
G = zeros(length(xk), m + 1);

% Initialize array to store sampled points
sampled_points = zeros(length(xk), m);

% Evaluate gradient at the current point xk
G(:, 1) = g(xk);

% Sample m points uniformly from the ball centered at xk with radius epsilon_k
for i = 2 : m + 1
    sampled_points(:, i - 1) = xk + generateUniformOverBall(length(xk), epsilon_k);
    G(:, i) = g(sampled_points(:, i - 1));
end

% Set up the quadratic programming problem:
% minimize (1/2) * t' * (G' * G) * t
% subject to sum(t) = 1 and t >= 0
H = G' * G;               % Hessian matrix (symmetric positive semi-definite)
f = zeros(m + 1, 1);      % Linear term (zero vector)
Aeq = ones(1, m + 1);     % Equality constraint matrix for sum(t) = 1
beq = 1;                  % Equality constraint scalar
lb = zeros(m + 1, 1);     % Lower bound (non-negativity constraint)

% Solve the quadratic program using quadprog with output suppressed
options = optimoptions('quadprog', 'Display', 'off');
t = quadprog(H, f, [], [], Aeq, beq, lb, [], [], options);

% Compute the approximated gradient as a convex combination of sampled gradients
gk = G * t;
end
