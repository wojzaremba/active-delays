function [f d] = uFunction(u,A,B,C)

if u<eps
    f=realmax;
    d=realmax;
    return;
end

%% relevant portion of the log likelihood


%% derivative
d = A*log(u) + B*u^2 - C*u;    

%% want negative of these because using fminunc

d=-d;
f=-f;

return;