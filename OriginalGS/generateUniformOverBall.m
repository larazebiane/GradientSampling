function u = generateUniformOverBall(n,epsilon)

% Generate a vector with each entry from a standard normal distribution
u = randn(n,1);

% Transform so that result is uniform over Euclidean ball with radius epsilon in R^n
u = epsilon * rand^(1/n) * u / norm(u);

