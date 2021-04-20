classdef IGDT
    
    properties

        GDT; % GDT algorithm
        UCA; % UnconstrainedMaximization algorithm
        
    end

    methods

        function obj = IGDT(submodular_objective)
            if nargin == 1
                obj.GDT = GDT(submodular_objective);
                obj.UCA = UnconstrainedMaximization(submodular_objective);
            else
                disp('Not enough input arguments in IGDT.');
            end
        end
       
        % run GDT
        function res = run(obj, p)
                       
            res.S = [];
            res.f = 0;
            res.t = 0;
            res.a = 0;
            
            res.cont.a = 0;
            res.cont.t = 0;
            res.cont.f = 0;
            
            groundSet = 1:obj.GDT.submodular_objective.dimension;
            
            for i = 1:(p + 1)
                
                % run the GDT on complement solutions
                currentSolution = obj.GDT.run(0, groundSet);
                
                % update continuous monitoring
                currentSolution.cont.t = res.t + currentSolution.cont.t;
                currentSolution.cont.a = res.a + currentSolution.cont.a;

                res.cont.a = [res.cont.a currentSolution.cont.a];
                res.cont.t = [res.cont.t currentSolution.cont.t];
                res.cont.f = [res.cont.f currentSolution.cont.f];
                
                res.t = res.t + currentSolution.t;
                res.a = res.a + currentSolution.a;
                
                
                for j = currentSolution.S 
                    groundSet(groundSet == j) = [];
                end
                if currentSolution.f >= res.f
                    res.S = currentSolution.S;
                    res.f = currentSolution.f;
                end
                
                % run unconstrained greedy on current solution
                currentSolution = obj.UCA.run(currentSolution.S); 
                
                % update continuous monitoring
                currentSolution.cont.t = res.t + currentSolution.cont.t;
                currentSolution.cont.a = res.a + currentSolution.cont.a;

                res.cont.a = [res.cont.a currentSolution.cont.a];
                res.cont.t = [res.cont.t currentSolution.cont.t];
                res.cont.f = [res.cont.f currentSolution.cont.f];

                res.t = res.t + currentSolution.t;
                res.a = res.a + currentSolution.a;
                
                if currentSolution.f >= res.f
                    res.S = currentSolution.S;
                    res.f = currentSolution.f;
                end
                
                % break the process if new ground set it empty
                if isempty(groundSet)
                    break;
                end

            end
        end
    end
end