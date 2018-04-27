function  [xxx, yyy] = function_guess_locations(x,y,xx,yy,k)

ax = x(1:k);
ay = y(1:k);
bx = xx(1:k);
by = yy(1:k);
ex = x((k+1):end);
ey = y((k+1):end);

[d,Z,transform] = procrustes([bx by],[ax ay]);
c = transform.c;
T = transform.T;
b = transform.b;
Z = b*[ex ey]*T;

Z(:,1) = Z(:,1)+c(1,1);
Z(:,2) = Z(:,2)+c(1,2);

Z =  [[bx by]; Z];
xxx= Z(:,1);
yyy= Z(:,2);


end

