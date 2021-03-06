function [D, Q] = DoubleHessenbergQRIter(D, Q, tol)
% DoubleHessenbergQRIter   QR iteration for upper real Hessenberg marix.
%   T = DoubleHessenbergQRIter(H) is the upper quasi-triangular form of 
%   the real upper Hessenberg matrix H. Francis double shift is used in 
%   this algorithm.
%
%   [T, Q] = DoubleHessenbergQRIter(H) produces a upper quasi-triangle T 
%   and a unitary matrix Q so that T = Q*H*Q'.
% 
%   [T, Q] = DoubleHessenbergQRIter(H, P) assumes that P is a unitary 
%   matrix of the same size as H and produces a upper quasi-triangle D and 
%   a unitary matrix Q so that T = Q*P'*H*P*Q'.
%
%   [T, Q] = DoubleHessenbergQRIter(H, P, TOL) specifies the tolerance of 
%   QR iteration. If TOL is [] the default value, 1e-10, will be used.
%
%   See also DoubleHessenbergQRIter, BidiagQRITer, TridiagQRIter, Eigen.

%   Copyright 2017 Junshen Xu

flagQ = nargout > 1;
n = size(D, 1);
if flagQ && ~exist('Q', 'var')
    Q = eye(n);
end
if ~exist('tol','var')
    tol = 1e-10;
end
FancisCount = 0;
while(1)
    for i = 1:n-1
        if abs(D(i+1,i)) < tol*(abs(D(i,i) + abs(D(i+1,i+1))))
            D(i+1,i) = 0;
        end
    end
    [i, j] = FindUnreduced(D, n);
    if j == 1
        break;
    end
    FancisCount = FancisCount + 1;
    if FancisCount > 5
        x = D(i, i);
        y = D(i+1, i);
        z = D(i+2, i);
        FancisCount = 0;
    else
        [x,y,z] = FrancisStep(D, i, j);
    end
    for k = i-1:j-3
        [v, beta] = HouseVec([x;y;z]);
        q = max(i, k);
        r = min(k+4,j);
        if flagQ
            D(k+1:k+3,q:end) = D(k+1:k+3,q:end) - beta*v*(v'*D(k+1:k+3,q:end));
            D(1:r,k+1:k+3) = D(1:r,k+1:k+3) - beta*(D(1:r,k+1:k+3)*v)*v';
            Q(:,k+1:k+3) = Q(:,k+1:k+3) - beta*(Q(:,k+1:k+3)*v)*v';
        else
            D(k+1:k+3,q:j) = D(k+1:k+3,q:j) - beta*v*(v'*D(k+1:k+3,q:j));
            D(i:r,k+1:k+3) = D(i:r,k+1:k+3) - beta*(D(i:r,k+1:k+3)*v)*v';
        end
        x = D(k+2, k+1);
        y = D(k+3, k+1);
        if k < j - 3
            z = D(k+4, k+1);
        end
    end
    [v, beta] = HouseVec([x;y]);
    if flagQ
        D(j-1:j, j-2:end) = D(j-1:j, j-2:end) - beta*v*(v'*D(j-1:j, j-2:end));
        D(1:j,j-1:j) = D(1:j,j-1:j) - beta*(D(1:j,j-1:j)*v)*v';
        Q(:,j-1:j) = Q(:,j-1:j) - beta*(Q(:,j-1:j)*v)*v';
    else
        D(j-1:j, j-2:j) = D(j-1:j, j-2:j) - beta*v*(v'*D(j-1:j, j-2:j));
        D(i:j,j-1:j) = D(i:j,j-1:j) - beta*(D(i:j,j-1:j)*v)*v';
    end
    %D(3:n+1:end-n) = 0;
    %D(4:n+1:end-2*n) = 0;
end

end

function [i, j] = FindUnreduced(D, n)
    count = 0;
    for j = n:-1:1
        if j > 1
            if(D(j, j-1)~= 0)
                if count
                    j = j+1;
                    break;
                else
                    count = 1;
                end
            else
                count = 0;
            end
        end
    end
    for i = j-1:-1:1
        if i > 1
            if(D(i, i-1) == 0)
                break;
            end
        end
    end
end

function [x,y,z] = FrancisStep(D, i, j)
    m = j-1;
    s = D(m,m) + D(j, j);
    t = D(m,m)*D(j,j) - D(m,j)*D(j,m);
    x = D(i,i)*D(i,i) + D(i,i+1)*D(i+1,i) - s*D(i,i) + t;
    y = D(i+1,i)*(D(i,i) + D(i+1,i+1) - s);
    z = D(i+1,1)*D(i+2,i+1);
end

function [x, beta] = HouseVec(x)
sigma = Norm(x);
if(sigma == 0)
    beta = 0;
    return;
else
    beta = 1 / (sigma*(sigma + abs(x(1))));
end
    
if x(1) == 0
    mu = sigma;
else
    mu = -x(1)/abs(x(1)) * sigma;
end

x(1) = x(1) - mu;
beta = beta * abs(x(1))^2;
x = x / x(1);
end

