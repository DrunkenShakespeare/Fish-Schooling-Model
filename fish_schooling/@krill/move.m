function [updatedKrill] = move(krill)
% This function is used to update a fish's position 

global ENVIRONMENT PARAM 

%variables for weight values
upperLeft=0;
upperRight=0;
left=0;
right=0;
up=0;
down=0;
lowerLeft=0;
lowerRight=0;
changes=[0,0,0,0,0,0,0,0];

% vectors basedon perception e.g. fish.perception = 3 is 
% [1,2,3]
perception = 1:1:(krill.perception);
perceptionReverse = sort(perception,'descend');

% environment densities
dens = ENVIRONMENT.krill;

%calculate weighting for upper left
 for i = perceptionReverse*-1
     for j = perceptionReverse*-1
         % check if this area is off the grid, if so then weight is
         % calculated off current position,
         % if not then go ahead and calculate weight of
         % the positions in that direction 
         if (((krill.position(1)+j>0) && krill.position(2)+i>0))   
             upperLeft = upperLeft + dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j));
             changes(1)=1;
         end
     end
 end
 
% calculate weighting for upper right
 for i = perceptionReverse
     for j = perceptionReverse*-1
         if ((krill.position(1)+j>0) && (krill.position(2)+i<ENVIRONMENT.size))
             upperRight = upperRight + dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j));
             changes(2)=1;
         end
     end
 end
 
 %calculate weighting for lower left
 for i = perceptionReverse*-1
      for j = perceptionReverse
          if((krill.position(1)+j<=ENVIRONMENT.size) && (krill.position(2)+i>0))
             lowerLeft = lowerLeft + dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j));
             changes(3)=1;
          end
      end
 end

 % calculate weighting for lower right
 for i = perceptionReverse
      for j = perceptionReverse
          if((krill.position(1)+j<=ENVIRONMENT.size) && (krill.position(2)+i<=ENVIRONMENT.size))
             lowerRight = lowerRight + dens(krill.position(1) + j, krill.position(2) + i)./max(abs(i), abs(j));
             changes(4)=1;
          end
      end
 end

%calculates weighting for up, down, left, right 
 for i = perception
     if((krill.position(2)+i<=ENVIRONMENT.size))
         right = right + dens(krill.position(1), krill.position(2)+i)./abs(i);
         changes(5)=1;
     end
     if((krill.position(2)-i>0))
         left = left + dens(krill.position(1), krill.position(2)-i)./abs(i);   
         changes(6)=1;
     end
     if((krill.position(1)-i>0))
         up = up + dens(krill.position(1)-i, krill.position(2))./abs(i);    
         changes(7)=1;
     end
     if((krill.position(1)+i<=ENVIRONMENT.size))
         down = down + dens(krill.position(1)+i, krill.position(2))./abs(i);  
         changes(8)=1;
     end
 end 

% sort weights from highest to lowest 
Q = sort([up,down,left,right,upperLeft,lowerLeft,upperRight,lowerRight],'descend');
Q = Q(1:5);
%disp("Q");
%disp(Q);

i = rand;

% choose a weight based on % chances
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

% check if that weight was an edge case, if so then fish remains in current
% position, if not then densities are adjusted accordingly 
switch true
    case (weight == upperLeft)
        if(changes(1)==1) && (dens(row-1,col-1)<PARAM.KRILL_DENSITY)
            dens(row-1,col-1)=dens(row-1,col-1)+1;
            dens(row,col)= dens(row,col)-1;
            pos = [row-1,col-1];
        else
            pos = [row,col];
        end
    case(weight == upperRight)
        if(changes(2)==1) && (dens(row-1,col+1)<PARAM.KRILL_DENSITY)
            dens(row-1,col+1)=dens(row-1,col+1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row-1,col+1];
        else
            pos = [row,col];
        end
     case(weight == right)
         if(changes(5)==1) && (dens(row,col+1)<PARAM.KRILL_DENSITY)
            dens(row,col+1)=dens(row,col+1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row,col+1];
         else
            pos = [row,col];
         end
     case(weight == left) 
         if(changes(6)==1) && (dens(row,col-1)<PARAM.KRILL_DENSITY)
            dens(row,col-1)=dens(row,col-1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row,col-1];
         else
            pos = [row,col];
         end
     case(weight == up)
         if(changes(7)==1) && (dens(row-1,col)<PARAM.KRILL_DENSITY)  
            dens(row-1,col)=dens(row-1,col)+1;
            dens(row,col)= dens(row,col)-1;
            pos = [row-1,col];
         else
            pos = [row,col];

         end
     case(weight == down)
         if(changes(8)==1) && (dens(row+1,col)<PARAM.KRILL_DENSITY)           
            dens(row+1,col)=dens(row+1,col)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row+1,col];
         else
            pos = [row,col];

         end
     case(weight == lowerLeft)
         if(changes(3)==1)  && (dens(row+1,col-1)<PARAM.KRILL_DENSITY)
            dens(row+1,col-1)=dens(row+1,col-1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row+1,col-1];
         else
            pos = [row,col];

         end
     case(weight == lowerRight)
         if(changes(4)==1) && (dens(row+1,col+1)<PARAM.KRILL_DENSITY)
            dens(row+1,col+1)=dens(row+1,col+1)+1;
            dens(row,col)= dens(row,col)-1;

            pos = [row+1,col+1];
         else
            pos = [row,col];
         end
end
% change environment 
ENVIRONMENT.krill = dens;
% new fish position 
krill.position = pos;
%return an updated fish
updatedKrill = krill();
end
