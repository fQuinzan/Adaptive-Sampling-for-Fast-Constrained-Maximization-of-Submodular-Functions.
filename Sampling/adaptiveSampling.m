classdef adaptiveSampling
    
    properties

        submodular_objective; % submodular_objective matrix
        
    end

    methods

        function obj = adaptiveSampling(submodular_objective)
            if nargin == 1
                obj.submodular_objective = submodular_objective;
            else
                disp('Not enough input arguments in RandomGreedy.');
            end
        end
        
        % run binary search to find eta
        function res = binarySearch(obj, randomSequence, S, X, epsilon, delta)

            % define initial solution
            res.X = [];
            res.eta = 0;
            res.t = 0;
            res.a = 0;
            
            if length(randomSequence) == 1
                res.eta = 1;
            end
            
            if length(randomSequence) > 1
                L = 1;
                R = length(randomSequence);
                while L < R
                    m = floor((L + R)/2); 
                    F = obj.submodular_objective.F([S randomSequence(1:m)], X, delta);
                    if length(F.X) > (1 - epsilon) * length(X)
                        L = m + 1; 
                    end
                    if length(F.X) <= (1 - epsilon) * length(X)
                        R = m; 
                    end
                    res.t = res.t + F.t;
                    res.a = res.a + 1;
                end
                res.X = F.X;
                res.eta = L;
            end
            
        end
               
        % random sequence
        function res = randomSequence(obj, S, X)
            
            % remove points from X that are in S
            res = [];
            for e = S
            	X(X == e) = []; 
            end
            
            while ~isempty(X)
                
                % update the random sequence
                X = X(randperm(length(X)));
                eta = find(arrayfun(@(i) obj.submodular_objective.isFeasible([S res X(1:i)]), 1:length(X)) == true, 1, 'last' );
                res = [res X(1:eta)];
                
                % update X
                for e = res
                   X(X == e) = []; 
                end
                X = find(arrayfun(@(e) obj.submodular_objective.isFeasible([S res e]), X) == true);
                
            end
            
        end
        
        
        % run algorithm
        function res = sampling(obj, V, epsilon)
            
            res.S = [];
            res.f = 0;
            res.t = 0;
            res.a = 0;
            
            res.cont.a = [];
            res.cont.t = [];
            res.cont.f = [];
            
            % find maximum among the singletons and define search space
            Y = obj.submodular_objective.F([], V, []);
            [delta, idx] = max(Y.f);
            X = Y.X(idx);
            
            % update time and adaptivity
            res.t = Y.t;
            res.a = 1;
            
            % second part of while condition to be fair with FANTOM
            %while delta > epsilon * (obj.submodular_objective.p + 1) * delta / obj.submodular_objective.dimension
            while ~isempty(X)

                while ~isempty(X)
                    
                    % create and evaluat random sequence
                    randomSequence = obj.randomSequence(res.S, X);
                    Y = obj.binarySearch(randomSequence, res.S, X, epsilon, delta);
                    
                    % update current S and X
                    X = Y.X;
                    res.S = [res.S randomSequence(1:Y.eta)];
                    
                    % update time and adaptivity
                    res.t = res.t + Y.t;
                    res.a = res.a + Y.a;
                    res.f = obj.submodular_objective.f(res.S);
                    
                    % update continuous monitoring
                    res.cont.a = [res.cont.a res.a];
                    res.cont.t = [res.cont.t res.t];
                    res.cont.f = [res.cont.f res.f];
                    
                end 
                
                Z = obj.submodular_objective.F(res.S, V, []);
                
                % update time and adaptivity
                res.t = res.t + Z.t;
                res.a = res.a + 1;
                
                % update delta and X
                if max(Z.f) > 0
                    delta = (1 - epsilon) * delta;
                    while delta > max(Z.f)
                       delta = (1 - epsilon) * delta;
                    end
                    X = Z.X(Z.f >= delta);
                else
                    X = [];
                end
                
            end
            
        end
        
        
        % iterated sampling
        function res = run(obj, epsilon, m, p, q)
            
            % define solution
            res.S = [];
            res.f = 0;
            res.t = 0;
            res.a = 0;
            
            res.cont.a = 0;
            res.cont.t = 0;
            res.cont.f = 0;
            
            % define search space
            V = 1:obj.submodular_objective.dimension;
            for i = 1:length(V)
                if rand > p
                   V(i) = 0; 
                end
                
            end
            V = V(V ~= 0);
            
            for i = 1:m
               
                % find new solution and remove it from grou d set
                Omega = obj.sampling(V, epsilon);
                for e = Omega.S
                   V(V == e) = []; 
                end
                
                % define random set
                Tau.S = Omega.S;
                for j = 1:length(Omega.S)
                    if rand > q
                        Tau.S(j) = 0; 
                    end
                end
                Tau.S = Tau.S(Tau.S ~= 0);
                Tau.f = obj.submodular_objective.f(Tau.S);
                
                % update continuous monitoring
                Omega.cont.t = Omega.cont.t + res.t;
                Omega.cont.a = Omega.cont.a + res.a;
                
                res.cont.a = [res.cont.a Omega.cont.a];
                res.cont.t = [res.cont.t Omega.cont.t];
                res.cont.f = [res.cont.f Omega.cont.f];
                
                % update time complexity
                res.t = res.t + Omega.t;
                res.a = res.a + Omega.a;
                
                % update current solution
                if res.f < Omega.f
                    res.S = Omega.S;
                    res.f = Omega.f;
                end
                if res.f < Tau.f
                    res.S = Tau.S;
                    res.f = Tau.f;
                end
                
                % break in case you get the empty set
                if isempty(V)
                    break;
                end
                
            end
            
            % update time complexity
            res.t = res.t + ceil(sqrt(p + 1)/2);
            res.a = res.a + 1;
            
            % update continuous monitoring
            res.cont.a = [res.cont.a res.a];
            res.cont.t = [res.cont.t res.t];
            res.cont.f = [res.cont.f res.f];
            
        end

    end
end