function [xk, info] = origGS(x0, f_hand, g_hand, nonDiffPoints, epsilon0, nu0, m, n, beta, gamma, epsilon_opt, nu_opt, theta_epsilon, theta_nu, maxit)
% origGS - Original Gradient Sampling Algorithm for minimizing nonsmooth functions
%
% Syntax:
%   [xk, info] = origGS(x0, f_hand, g_hand, nonDiffPoints, epsilon0, nu0, m, n, beta, gamma, epsilon_opt, nu_opt, theta_epsilon, theta_nu, maxit)
%
% Inputs:
%   x0           - Initial point (column vector)
%   f_hand       - Handle to objective function f: R^n -> R
%   g_hand       - Handle to gradient function ∇f (where differentiable)
%   nonDiffPoints- Set of known nondifferentiable points (array)
%   epsilon0     - Initial sampling radius
%   nu0          - Initial stationarity tolerance
%   m            - Number of gradient samples per iteration (m > n)
%   n            - Dimension of the problem
%   beta         - Armijo condition parameter (0 < beta < 1)
%   gamma        - Step size reduction factor (0 < gamma < 1)
%   epsilon_opt  - Optimality tolerance for epsilon_k
%   nu_opt       - Optimality tolerance for nu_k
%   theta_epsilon- Reduction factor for epsilon_k (0 < theta_epsilon < 1)
%   theta_nu     - Reduction factor for nu_k (0 < theta_nu < 1)
%   maxit        - Maximum number of iterations
%
% Outputs:
%   xk    - Final approximate solution
%   info  - Struct containing iteration count and other info

% Initialize variables
xk = x0;
epsilon_k = epsilon0;
nu_k = nu0;
iter = 0;
tk = 0; % Step size
info.iter = iter;

% Check input validity
if m <= n
    error('ERROR: Number of samples m must be greater than problem dimension n!');
end

% Print table header for iterations
fprintf('\n%-8s %-12s %-12s %-12s %-12s %-12s %-12s\n', ...
    'Iter', 'xk', 'f(xk)', '||gk||', 'epsilon_k', 'nu_k', 't_k');
fprintf('%s\n', repmat('-', 1, 80)); % horizontal line

while true
    % Compute approximate gradient gk via gradient sampling
    gk = compute_gk(xk, g_hand, epsilon_k, m);

    % Print current iteration data
    fprintf('%-6d %-12.4e %-12.4e %-12.4e %-12.4e %-12.4e %-12.4e\n', ...
        iter, xk, f_hand(xk), norm(gk), epsilon_k, nu_k, tk);

    % Check stopping criteria
    if iter >= maxit
        break; % Maximum iterations reached
    end
    if norm(gk) <= nu_opt && epsilon_k <= epsilon_opt
        break; % Stationarity and sampling radius criteria met
    end

    if norm(gk) <= nu_k
        % Shrink tolerances if approximate gradient is small
        nu_k = theta_nu * nu_k;
        epsilon_k = theta_epsilon * epsilon_k;
        tk = 0; % Reset step size
    else
        % Perform backtracking Armijo line search to find suitable step size tk
        tk = 1;
        while true
            if f_hand(xk - tk * gk) < f_hand(xk) - beta * tk * norm(gk)^2
                break; % Armijo condition satisfied
            else
                tk = gamma * tk; % Reduce step size
                if tk < eps
                    break; % Step size too small, stop line search
                end
            end
        end
    end

    % Update point while avoiding known nondifferentiable points
    tolerance = 1e-6;

    if all(abs(xk - tk * gk - nonDiffPoints) > tolerance)
        % New point is differentiable, accept it
        xk = xk - tk * gk;
    else
        % New point is near a nondifferentiable point, search neighborhood
        radius = min(tk, epsilon_k) * norm(gk);

        while true
            % Generate a random direction in ball of radius
            direction = generateUniformOverBall(length(xk), radius);
            x_candidate = xk - tk * gk - direction;

            % Accept candidate if differentiable and decreases function sufficiently
            if all(abs(x_candidate - nonDiffPoints) > tolerance) && ...
               f_hand(x_candidate) < f_hand(xk) - beta * tk * norm(gk)^2 && ...
               norm(xk - tk * gk - x_candidate) <= radius
                xk = x_candidate;
                break;
            end
        end
    end

    % Increment iteration counter
    iter = iter + 1;
end

% Print final iteration info
fprintf('%-6d %-12.4e %-12.4e %-12.4e %-12.4e %-12.4e %-12.4e\n\n', ...
    iter, xk, f_hand(xk), norm(gk), epsilon_k, nu_k, tk);

% Print termination message
if iter >= maxit
    fprintf('Maximum number of iterations reached.\n');
else
    fprintf('Termination conditions met.\n');
end

% Return info struct with iteration count and the final solution
info.iter = iter;
info.xk = xk;
end
