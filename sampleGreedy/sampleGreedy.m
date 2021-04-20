classdef sampleGreedy
    
    properties
        
        submodular_objective; % submodular objective
        
    end

    methods

        function obj = sampleGreedy(submodular_objective)
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
        
        % main function
        function res = run(obj, p)
            
            % define parameter
            V = 1:obj.submodular_objective.dimension;
            for i = 1:length(V)
                if rand > 1/(p + 1)
                   V(i) = 0; 
                end
                
            end
            V = V(V ~= 0);
            
            % run simple greedy
            res = obj.simpleGreedy(V);
            
        end
    end
end