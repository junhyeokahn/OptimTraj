% DEV - Pendulum with Gradients
%
% Development and testing of analytic gradients
%
% Demonstrates simple swing-up for a single pendulum with a torque motor.
% This is an easy problem, used for demonstrating how to use analytic
% gradients with trajOpt.
%

clc; clear;
addpath ../../

% Physical parameters of the pendulum
p.k = 1;  % Normalized gravity constant
p.c = 0.1;  % Normalized damping constant

% User-defined dynamics and objective functions
problem.func.dynamics = @(t,x,u)( dynamics(x,u,p) );
problem.func.pathObj = @(t,x,u)( objective(u) );

% bound objective for testing
xF_des = [pi-.1;.1];
problem.func.bndObj = @(t0,x0,tF,xF)( obj_boundObj(xF,xF_des) );

% Problem bounds
problem.bounds.initialTime.low = 0;
problem.bounds.initialTime.upp = 0;
problem.bounds.finalTime.low = 0.5;
problem.bounds.finalTime.upp = 2.5;

problem.bounds.state.low = [-2*pi; -inf];
problem.bounds.state.upp = [2*pi; inf];
problem.bounds.initialState.low = [0;0];
problem.bounds.initialState.upp = [0;0];
problem.bounds.finalState.low = [pi;0];
problem.bounds.finalState.upp = [pi;0];

problem.bounds.control.low = -5; %-inf;
problem.bounds.control.upp = 5; %inf;

% Guess at the initial trajectory
problem.guess.time = [0,1];
problem.guess.state = [0, 0; pi, 0];
problem.guess.control = [0, 0];



%%%% HACK %%%%
% Put in some terrible initial condition
problem.guess.time = linspace(0,1,10);
problem.guess.state = randn(2,10);
problem.guess.control = 2*randn(1,10);
% Still seems to work
%%%% DONE %%%%



%%%% FIRST ITERATION
problem.options(1).nlpOpt = optimset(...
    'Display','iter',...
    'GradObj','on',...
    'GradConstr','on',...
    'DerivativeCheck','on',...
    'MaxFunEvals',1e5);   %Fmincon automatically checks derivatives
problem.options(1).method = 'rungeKutta';
problem.options(1).defaultAccuracy = 'low';

%%%% SECOND ITERATION
problem.options(2) = problem.options(1);


% Solve the problem
tic;
soln = trajOpt(problem);
toc

t = soln(end).grid.time;
q = soln(end).grid.state(1,:);
dq = soln(end).grid.state(2,:);
u = soln(end).grid.control;

% Plot the solution:
figure(1); clf;

subplot(3,1,1)
plot(t,q)
ylabel('q')
title('Single Pendulum Swing-Up');

subplot(3,1,2)
plot(t,dq)
ylabel('dq')

subplot(3,1,3)
plot(t,u)
ylabel('u')


