classdef UnconstrainedMaximization
    
    properties
        
         submodular_objective % submodular objective
        
    end

    methods
        
        % constructor
        function obj = UnconstrainedMaximization(submodular_objective)
            if nargin == 1
                obj.submodular_objective = submodular_objective;
            else
                disp('Not enough input arguments in UnconstrainedMaximization.');
            end
        end

        % run GDT
        function res = run(obj, V)

            res.S = [];
            res.f = 0;
            res.t = 0;
            res.a = 0;  
            
            res.cont.a = [];
            res.cont.t = [];
            res.cont.f = [];
            
            while ~isempty(V)
                
                % find maximum value and remove it from N
                f = arrayfun(@(e) obj.submodular_objective.f([res.S e]), V);

                % update values
                [marginalValue, i] = max(f - res.f);
                if marginalValue >= 0
                    res.S = [res.S V(i)];
                    res.f = res.f + marginalValue;
                else
                    break;
                end
                V(i) = [];  
                
                % update time step
                res.t = res.t + length(V);
                res.a = res.a + 1;
                
                % update continuous monitoring
                res.cont.a = [res.cont.a res.a];
                res.cont.t = [res.cont.t res.t];
                res.cont.f = [res.cont.f res.f];
                
            end
            
            % clean up array
            res.S = sort(unique(res.S(res.S ~= 0)));

        end
       
    end
end