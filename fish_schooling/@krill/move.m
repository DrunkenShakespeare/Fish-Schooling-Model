function [updatedKrill] = move(krill)
% This function is used to update a fish's position 

global ENVIRONMENT PARAM MESSAGES

% struct containing weights for all directions
d=struct('up',0,'down',0,'left',0,'right',0,'upperLeft',0,...
    'upperRight',0,'lowerLeft',0,'lowerRight',0);
changes=[0,0,0,0,0,0,0,0];

% vectors basedon perception e.g. fish.perception = 3 is 
% [1,2,3]
perception = 1:1:(krill.perception);
perceptionReverse = sort(perception,'descend');
mult=1000;  %multiplier for how much more the positions of herring affect the weighting 

% environment densities
dens = ENVIRONMENT.krill;
denh = ENVIRONMENT.herring;

%calculate weighting for upper left
 for i = perceptionReverse*-1
     for j = perceptionReverse*-1
         % check if this area is off the grid, if so then weight is
         % calculated off current position,
         % if not then go ahead and calculate weight of
         % the positions in that direction 
         if (((krill.position(1)+j>0) && krill.position(2)+i>0))   
             d.upperLeft = d.upperLeft + dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j))...
                 - mult*dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j));
             changes(1)=1;
         end
     end
 end
 
% calculate weighting for upper right
 for i = perceptionReverse
     for j = perceptionReverse*-1
         if ((krill.position(1)+j>0) && (krill.position(2)+i<=ENVIRONMENT.size))
             d.upperRight = d.upperRight + dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j))...
                  - mult*denh(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j));
             changes(2)=1;
         end
     end
 end
 
 %calculate weighting for lower left
 for i = perceptionReverse*-1
      for j = perceptionReverse
          if((krill.position(1)+j<=ENVIRONMENT.size) && (krill.position(2)+i>0))
             d.lowerLeft = d.lowerLeft + dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j))...
                 - mult*denh(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j));
             changes(3)=1;
          end
      end
 end

 % calculate weighting for lower right
 for i = perceptionReverse
      for j = perceptionReverse
          if((krill.position(1)+j<=ENVIRONMENT.size) && (krill.position(2)+i<=ENVIRONMENT.size))
             d.lowerRight = d.lowerRight + dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j))...
                 - mult*denh(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j));
             changes(4)=1;
          end
      end
 end

%calculates weighting for up, down, left, right 
 for i = perception
     if((krill.position(2)+i<=ENVIRONMENT.size))
         d.right = d.right + dens(krill.position(1), krill.position(2)+i)./abs(i)...
              - mult*denh(krill.position(1), krill.position(2)+i)./abs(i);;
         changes(5)=1;
     end
     if((krill.position(2)-i>0))
         d.left = d.left + dens(krill.position(1), krill.position(2)-i)./abs(i)...
              - mult*(denh(krill.position(1), krill.position(2)-i)./abs(i));;
         changes(6)=1;
     end
     if((krill.position(1)-i>0))
         d.up = d.up + dens(krill.position(1)-i, krill.position(2))./abs(i)...
             - mult*denh(krill.position(1)-i, krill.position(2))./abs(i); ;   
         changes(7)=1;
     end
     if((krill.position(1)+i<=ENVIRONMENT.size))
         d.down = d.down + dens(krill.position(1)+i, krill.position(2))./abs(i)...
             - mult*(denh(krill.position(1)+i, krill.position(2))./abs(i)); 
         changes(8)=1;
     end
 end 

% sort weights from highest to lowest 
Q = sort([d.up,d.down,d.left,d.right,d.upperLeft,d.lowerLeft,d.upperRight,d.lowerRight],'descend');
Q =Q(1:5);

% choose a weight based on % chances
i = rand;
switch true
    case ((0<=i)&&(i<0.75))
        weight = Q(1);
    case ((0.75<=i)&&(i<0.87))
        weight = Q(2);
    case ((0.87<=i)&&(i<0.93))
        weight = Q(3);
    case ((0.93<=i)&&(i<0.97))
        weight = Q(4);
    case ((0.97<=i)&&(i<=1.00))
        weight = Q(5);
end

row = krill.position(1);
col = krill.position(2);

    function up
        if(changes(7)==1) && (dens(row-1,col)<PARAM.KRILL_DENSITY)  
           dens(row-1,col)=dens(row-1,col)+1;
           dens(row,col)= dens(row,col)-1;
           pos = [row-1,col];
        else
           pos = [row,col];
        end
    end
    function upperLeft
        if(changes(1)==1) && (dens(row-1,col-1)<PARAM.KRILL_DENSITY)
            dens(row-1,col-1)=dens(row-1,col-1)+1;
            dens(row,col)= dens(row,col)-1;
            pos = [row-1,col-1];
        else
            pos = [row,col];
        end
    end
    function down
        if(changes(8)==1) && (dens(row+1,col)<PARAM.KRILL_DENSITY)           
            dens(row+1,col)=dens(row+1,col)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row+1,col];
         else
            pos = [row,col];

         end
    end
    function left
          if(changes(6)==1) && (dens(row,col-1)<PARAM.KRILL_DENSITY)
            dens(row,col-1)=dens(row,col-1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row,col-1];
         else
            pos = [row,col];
          end
    end
    function right
         if(changes(5)==1) && (dens(row,col+1)<PARAM.KRILL_DENSITY)
            dens(row,col+1)=dens(row,col+1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row,col+1];
         else
            pos = [row,col];
         end
    end
    function lowerLeft
        if(changes(3)==1)  && (dens(row+1,col-1)<PARAM.KRILL_DENSITY)
            dens(row+1,col-1)=dens(row+1,col-1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row+1,col-1];
         else
            pos = [row,col];

        end
    end
    function lowerRight
         if(changes(4)==1) && (dens(row+1,col+1)<PARAM.KRILL_DENSITY)
            dens(row+1,col+1)=dens(row+1,col+1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row+1,col+1];
         else
            pos = [row,col];
         end
    end
    function upperRight
        if(changes(2)==1) && (dens(row-1,col+1)<PARAM.KRILL_DENSITY)
            dens(row-1,col+1)=dens(row-1,col+1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row-1,col+1];
        else
            pos = [row,col];
        end
    end
%make moves                
switch true
    % if greatest weight is 0 then pick a random direction which has weight 0 
    case(weight==0)
        strDi = ["up","down","left","right","upperLeft","upperRight","lowerLeft","lowerRight"];
        dir=[];
        for n=1:8
            if (d.(strDi(n))==0)
                dir = [dir,strDi(n)];
            end
        end             
        dir = dir(randperm(length(dir)));
        di = dir(1); 
        eval(di);
    case(weight == d.up)
        up
    case (weight == d.upperLeft)
        upperLeft
    case(weight == d.upperRight)
         upperRight
    case(weight == d.right)
         right
    case(weight == d.left) 
         left
    case(weight == d.down)
         down
    case(weight == d.lowerLeft)
         lowerLeft
    case(weight == d.lowerRight)
         lowerRight
end
% change environment 
ENVIRONMENT.krill = dens;
% new fish position 
krill.position = pos;
%return an updated fish
updatedKrill = krill();
end

