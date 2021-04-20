classdef d_optimality
    
    properties
        
        % DPP matrix and its dimension
        matrix;
        dimension;
                
        % partition and uniform constraint
        uniformConstraint;
        partitionConstraint;
        
        % number of constraints
        p;
        
    end

    methods
        
        % constructor
        function obj = d_optimality(matrix, uniformConstraint, partitionConstraint)
            if nargin > 1  
                
                % add data
                obj.matrix = matrix;
                [obj.dimension, ~] = size(matrix);
                
                % add constraints
                obj.uniformConstraint = uniformConstraint;
                obj.partitionConstraint = partitionConstraint;
                
                % define number of constraints
                obj.p = 2;
  
            else
                disp('Not enough input arguments in DPP.');
            end
        end
        
        % evaluate feasibility for knapsacks and matroids
        function res = isFeasible(obj, S)
            
            % clean-up the value
            S = unique(S(S ~= 0));
            res = true;
            
            % check the uniform constraint
            if length(S) > obj.uniformConstraint
            	res = false;
            end
                        
            % partitionMatroid
            if ~isempty(obj.partitionConstraint)
                for constraint = obj.partitionConstraint
                    for e = unique(constraint.labels)
                        if length(find(constraint.labels(S) == e)) > constraint.quantity(e)
                            res = false;
                        end  
                    end
                end
            end

        end
        
        % evaulate fitness on an array of points and evaluate fesability
        function res = f(obj, S) 
            S = unique(S(S ~= 0));
            res = 0;
            if (size(S, 1) <= obj.dimension && size(S, 2) == 1) || (size(S, 2) <= obj.dimension && size(S, 1) == 1)
                res = real(3 * log(det((obj.matrix(S, S))^(1/3))));
            elseif ~isempty(S)
                disp('Solution exceeds matrix dimensions in DPP.');
            end
        end
        
        % new function for easy marginal contribution
        function res = F(obj, S, I, delta)
            
            % remove from I points that are in S
            for e = S
            	I(I == e) = [];
            end
            
            % compute feasibility (C) and fitness (F)
            C = arrayfun(@(i) obj.isFeasible([S I(i)]), 1:length(I));
            F = zeros(1, length(I));
            F(C) = arrayfun(@(i) obj.f([S I(i)]), find(C == true)) - obj.f(S);
            F(~C) = -1;
            
            % return points that are feasible
            if ~isempty(delta)
                res.X = I(F >= delta);
                res.f = F(F >= delta);
                res.t = length(find(C == true)) + 1;
            else
                res.X = I(C);
                res.f = F(C);
                res.t = length(find(C == true)) + 1;
            end

        end
        
    end
end
