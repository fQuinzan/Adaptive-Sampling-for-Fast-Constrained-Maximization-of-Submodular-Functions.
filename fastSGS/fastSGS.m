classdef fastSGS
    
    properties
        
        submodular_objective; % submodular objective
        
    end

    methods

        function obj = fastSGS(submodular_objective)
            if nargin == 1
                obj.submodular_objective = submodular_objective;
            else
                disp('Not enough input arguments in GDT.');
            end
        end
        
        % run fastSGS
        function res = run(obj, epsilon, m)

            res.S = [];
            res.f = 0;
            res.t = 0;
            res.a = 0;
            
            res.cont.a = [];
            res.cont.t = [];
            res.cont.f = [];
            
            % initialze m solutions
            V = 1:obj.submodular_objective.dimension;
            L = zeros(m, length(V));
                
            delta_0 = max(arrayfun(@(e) obj.submodular_objective.f(e), V));
            delta = delta_0;    
            
            % update solution
            res.t = length(V);
            res.a = 1;
            res.cont.a = res.a;
            res.cont.t = res.t;
            res.cont.f = 0;
             
            X = V;
            while delta > epsilon / length(V) * delta_0
                for e = X
                    for i = 1:m
                        if obj.submodular_objective.isFeasible([L(i,:) e])
                        
                            % find marginal contribution
                            fitness = obj.submodular_objective.f([L(i,:) e]) - obj.submodular_objective.f(L(i,:));
                            
                            % update time
                            res.t = res.t + 1;
                            
                            if fitness >= delta 
                                L(i,e) = e;
                                X = X(X ~= e);
                                break;
                            end
                        end
                    end
                    
                   	% update point and fitness
                    res.f = max(arrayfun(@(i) obj.submodular_objective.f(L(i,:)), 1:m));
                    res.a = res.a + 1;
            
                    res.cont.a = [res.cont.a res.a];
                    res.cont.t = [res.cont.t res.t];
                    res.cont.f = [res.cont.f res.f];
                    
                end
                
                % update delta
                delta = (1 - epsilon) * delta;
                    
            end


            %update time and adaptivity
            
            fitness = arrayfun(@(i) obj.submodular_objective.f(L(i,:)), 1:m);
            [~, best_solution] = max(fitness);

            res.S = L(best_solution,:);
            res.S = res.S(res.S ~= 0);

        end
       
    end
end