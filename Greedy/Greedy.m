classdef Greedy
    
    properties
        
        submodular_objective; % submodular objective
        
    end

    methods

        function obj = Greedy(submodular_objective)
            if nargin == 1
                obj.submodular_objective = submodular_objective;
            else
                disp('Not enough input arguments in GDT.');
            end
        end
        
        % run Greedy
        function res = simpleGreedy(obj, V)

            res.S = [];
            res.f = 0;
            res.t = 0;
            res.a = 0;
            
            res.cont.a = [];
            res.cont.t = [];
            res.cont.f = [];
            
            Y = obj.submodular_objective.F(res.S, V, 0);
            res.t = res.t + Y.t;
            res.a = res.a + 1;
            
            while ~isempty(Y.X)
                
                % update values
                [marginalValue, i] = max(Y.f);
                res.S = [res.S Y.X(i)];
                res.f = res.f + marginalValue;
                
                % update search space
                V(V == Y.X(i)) = [];
                Y = obj.submodular_objective.F(res.S, V, 0);
                
                % update time step and adaptivity
                res.t = res.t + Y.t;
                res.a = res.a + 1;
                
                 % update continuous monitoring           
                res.cont.a = [res.cont.a res.a];
                res.cont.t = [res.cont.t res.t];
                res.cont.f = [res.cont.f res.f];
                
            end
        end
        
        % run unconstrained Greedy
        function res = deterministicUSM(obj, V)

            res.S = [];
            res.f = 0;
            res.t = 0;
            res.a = 0;
            
            res.cont.a = [];
            res.cont.t = [];
            res.cont.f = [];
            
            X = [];
            Y = V;
            
            fX = obj.submodular_objective.f([]);
            fY = obj.submodular_objective.f(V);
            
            % update adaptivity and time complexity
            res.t = res.t + 2;
            res.a = res.a + 1;
            
            for e = V
                
                % update solution
                a = obj.submodular_objective.f([X e]) - fX;
                b = obj.submodular_objective.f(Y(Y ~= e)) - fY;
                if a >= b
                    X = [X e];
                    fX = a + fX;
                else
                    Y = Y(Y ~= e);
                    fY = b + fY;
                end
                
                % update adaptivity and time complexity
                res.t = res.t + 2;
                res.a = res.a + 1;
                
                % update current solution
                res.S = X;
                if a >= b
                    res.f = res.f + a;
                end
                
                % update continuous monitoring           
                res.cont.a = [res.cont.a res.a];
                res.cont.t = [res.cont.t res.t];
                res.cont.f = [res.cont.f res.f];
               
                
            end
            
        end
        
        % iterated sampling
        function res = run(obj, p)
            
            % define solution
            res.S = [];
            res.f = 0;
            res.t = 0;
            res.a = 0;
            
            res.cont.a = 0;
            res.cont.t = 0;
            res.cont.f = 0;
            
            % define parameters
            V = 1:obj.submodular_objective.dimension;
            for i = 1:ceil(sqrt(p + 1)/2)
               
                % find new solution and remove it from ground set
                Omega = obj.simpleGreedy(V);
                for e = Omega.S
                   V(V == e) = []; 
                end
                
                % update continuous monitoring
                Omega.cont.t = res.t + Omega.cont.t;
                Omega.cont.a = res.a + Omega.cont.a;

                res.cont.a = [res.cont.a Omega.cont.a];
                res.cont.t = [res.cont.t Omega.cont.t];
                res.cont.f = [res.cont.f Omega.cont.f];

                res.t = res.t + Omega.t;
                res.a = res.a + Omega.a;
                
                % define random set
                Tau = deterministicUSM(obj, Omega.S);
                
                % update continuous monitoring
                Tau.cont.t = res.t + Tau.cont.t;
                Tau.cont.a = res.a + Tau.cont.a;

                res.cont.a = [res.cont.a Tau.cont.a];
                res.cont.t = [res.cont.t Tau.cont.t];
                res.cont.f = [res.cont.f Tau.cont.f];

                res.t = res.t + Tau.t;
                res.a = res.a + Tau.a;
                
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
            
        end
       
    end
end