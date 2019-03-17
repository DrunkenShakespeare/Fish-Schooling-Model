function fish_schooling(size, nh,nk, nsteps,fmode)
%FISH_SCHOOLING Summary of this function goes here
%   Detailed explanation goes here
% FISH_SCHOOLING agent-based herring schooling model
% COM3001

%ecolab(size,nf,perception_length,nsteps)
%size = size of model environment in m
%nf - number of fish agents
%nsteps - number of iterations required

%clear any global variables/ close figures from previous simulations
clear global
close all
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MODEL INITIALISATION
initialise_params;                      %sets the parameters for this simulation
create_environment(size);           %creates environment data structure, given an environment size
create_control();
random_selection(1);                %randomises random number sequence (NOT agent order). If input=0, then simulation should be identical to previous for same initial values
[agents]=create_agents(nh,nk);       %creates nf fish agents and places them in a cell array called 'agents'
create_messages(nh,nk,agents);
initialise_results(nh,nk,nsteps);   %initilaises structure for storing results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global N_IT ENVIRONMENT PARAM MESSAGES IT_STATS
% definition of global variables
% N_IT - current iteration number 
% PARAM - contains the max density 
% ENVIRONMENT - data structure representing the environment

%MODEL EXECUTION
%execute for number of iterations
N_IT=0;
%plot_results(agents,nsteps,false,true); %updates results figures and structures
%disp(ENVIRONMENT.herring);
for n_it=1:nsteps
    N_IT=n_it;
    % update agents for number of agents 
    [agents,n]=agnt_solve(agents);     %the function which calls the rules
   plot_results(agents,nsteps,true,true); %updates results figures and structures
end



typ=MESSAGES.atype;                                         %extract types of all agents
plot_results(agents,nsteps,true,true); %updates results figures and structures
disp(length(find(typ==0)));    
disp(length(find(typ==1)));         
disp(length(find(typ==2)));         
clear global
end



