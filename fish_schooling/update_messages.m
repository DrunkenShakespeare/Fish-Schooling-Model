function [nagent,nn]=update_messages(agent,prev_n)

%copy all surviving and new agents in to a new agent list - dead agents
%will be empty structures

%agent - list of existing agents, including those that have died in the
%current iteration
%prev_n - previous number of agents at the start of this iteration
%temp_n - number of existing agents, including those that have died in the
%current iteration
%nagent - list of surviving agents and empty structures
%nn - number of surviving agents

%global variables
%N_IT current iteration no
%IT_STATS data structure for saving model statistics
%MESSAGES is a data structure containing information that agents need to
%broadcast to each other
   %    MESSAGES.atype - n x 1 array listing the type of each agent in the model
   %    (1=rabbit, 2-fox, 3=dead agent)
   %    MESSAGES.pos - list of every agent position in [x y]
   %    MESSAGE.dead - n x1 array containing ones for agents that have died
   %    in the current iteration
%ENV_DATA - is a data structure containing information about the model
   %environment

global MESSAGES  N_IT ENVIRONMENT IT_STATS

nagent=cell(1,prev_n);                  %initialise list for surviving agents
nn=0;                                   %tracks number of surviving agents
for cn=1:prev_n
    if isempty(agent{cn})               %agent died in a previous iteration (not the current one)
        dead=1;
    else 
        dead=MESSAGES.dead(cn);         %will be one for agents that have died, zero otherwise	
    end
    if dead==0                          %if agent is not dead
        nagent{cn}=agent{cn};           %copy object into the new list
        pos=get(agent{cn},'position');
        MESSAGES.pos(cn,:)=pos;                    
         if isa(agent{cn},'krill')
             MESSAGES.atype(cn)=1;
             IT_STATS.tot_k(N_IT+1)=IT_STATS.tot_k(N_IT+1)+1;
         elseif isa(agent{cn},'herring')
             MESSAGES.atype(cn)=2;
         end
         MESSAGES.dead(cn)=0;           %clear death message
         nn=nn+1;
    else                                %agent has died
        MESSAGES.atype(cn)=0;           %set type to dead
        MESSAGES.dead(cn)=0;            %clear death message
        if MESSAGES.thisIter(cn)==1     
            coords = MESSAGES.pos(cn,:);
            ENVIRONMENT.krill(coords(1),coords(2))=ENVIRONMENT.krill(coords(1),coords(2))-1;
            MESSAGES.thisIter(cn)=0;
        end
    end
end