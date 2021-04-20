classdef FANTOM
    
    properties

        IGDT;      % IGDT algorithm
        dimension; % dimension of the problem
        
    end

    methods

        function obj = FANTOM(submodular_objective)
            if nargin == 1
                obj.IGDT = IGDT(submodular_objective);
                obj.dimension = submodular_objective.dimension;
            else
                disp('Not enough input arguments in FANTOM.');
            end
        end
       
        % run IGDT
        function res = run(obj,p)
            res = obj.IGDT.run(p);
        end
    end
end