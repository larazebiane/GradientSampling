% test_origGS.m
% Test script for Original Gradient Sampling algorithm on a piecewise linear function
% with nondifferentiable points at x = -1 and x = 2.

% Objective function and gradient handles
f = @(x) f_hand(x);
g = @(x) g_hand(x);

% Algorithm parameters
x0 = 3;               % Initial guess
epsilon0 = 0.1;       % Initial sampling radius
nu0 = 1e-3;           % Initial stationarity tolerance
n = 1;                % Dimension of the problem (1D)
m = 10;               % Number of gradient samples (m > n)
beta = 0.001;         % Armijo line search parameter
gamma = 0.5;          % Step size reduction factor during line search
epsilon_opt = 1e-3;   % Termination tolerance for epsilon_k
nu_opt = 1e-3;        % Termination tolerance for nu_k
theta_epsilon = 0.01; % Reduction factor for epsilon_k
theta_nu = 1;         % Reduction factor for nu_k (constant here)
maxit = 1000;         % Maximum number of iterations

% Known nondifferentiable points
nonDiffPoints = [-1; 2];

% Run Gradient Sampling Algorithm
[x_opt, info] = origGS(x0, f, g, nonDiffPoints, epsilon0, nu0, m, n, ...
                   beta, gamma, epsilon_opt, nu_opt, theta_epsilon, theta_nu, maxit);

% Display results
fprintf('Optimal point found: %.6f\n', x_opt);
fprintf('Function value at optimum: %.6f\n', f_hand(x_opt));
fprintf('Number of iterations: %d\n', info.iter);

% Objective function (piecewise linear with nondifferentiable points)
function f = f_hand(x)
    if x > 2
        f = 0.5 * x + 2;
    elseif x >= -1 && x <= 2
        f = x + 1;
    else % x < -1
        f = -x - 1;
    end
end

% Gradient of the objective function
function g = g_hand(x)
    tolerance = 1e-10; % Tolerance for nondifferentiability detection
    
    if abs(x - 2) < tolerance
        error('Gradient undefined at x = 2 (nondifferentiable point)');
    elseif x > 2
        g = 0.5;
    elseif x > -1 && x < 2
        g = 1;
    elseif x < -1
        g = -1;
    else
        error('Input x is outside the expected domain.');
    end
end
