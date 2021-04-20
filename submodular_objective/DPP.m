classdef DPP
    
    properties
        
        % DPP matrix and its dimension
        matrix;
        dimension;
        movie_id;        
        
        % partition and uniform constraint
        uniformConstraint;
        partitionConstraint;
        
        faceRecognitionData;
        faceRecognitionThreshold;
        
        p;
        
    end

    methods
        
        % constructor
        function obj = DPP(movie, faceRecognitionThreshold, uniformConstraint, partitionConstraint)
            if nargin > 0   
                
                % add data
                obj.matrix = movie.matrix;
                obj.movie_id = movie.movie_id;
                [obj.dimension, ~] = size(obj.matrix);
                
                % add constraints
                obj.uniformConstraint = uniformConstraint;
                obj.partitionConstraint = partitionConstraint;
                obj.faceRecognitionThreshold = faceRecognitionThreshold;
                obj.faceRecognitionData = movie.face_constraint;
                
                % update p
                obj.p = length(obj.uniformConstraint) + length(obj.partitionConstraint); 
                if ~isempty(obj.faceRecognitionThreshold)
                    for i = 1:size(obj.faceRecognitionData, 2)
                        if sum(obj.faceRecognitionData(:, i)) > obj.faceRecognitionThreshold
                            obj.p = obj.p + 1;
                        end
                    end
                end
            end
        end
        
        % evaluate feasibility for knapsacks and matroids
        function res = isFeasible_flat(obj, S)
            
            % clean-up the value
            S = unique(S(S ~= 0));
            res = true;
            
            % check the uniform constraint
            if length(S) > obj.uniformConstraint
            	res = false;
            end
            
            % partition matroid constraint
            if ~isempty(obj.partitionConstraint)
            	t = obj.dimension/(obj.partitionConstraint - 1);
                i = 1;
                while i <= obj.partitionConstraint - 1
                    if length(find(S <= t * i & S > t * (i - 1))) > obj.uniformConstraint / obj.partitionConstraint
                        res = false;
                    end
                    i = i + 1;
                end
            end

        end
        
        % check feasibility with face recognition tool
        function res = isFeasible_face_recognition(obj, S)
           
            % check upper-bound on actors
            res = true;
            if ~isempty(obj.faceRecognitionThreshold)
            	S = unique(S(S ~= 0));
                if ~isempty(S)
                    for i =1:size(obj.faceRecognitionData,2)
                        if sum(obj.faceRecognitionData(S, i)) > obj.faceRecognitionThreshold
                            res = false;
                            break;
                        end
                    end
                end
            end
            
            % check lower-bound on faces
            if res
                for i = S 
                    if sum(obj.faceRecognitionData(i, :)) == 0
                        res = false;
                        break;
                    end
                end
            end
                
        end
        
        % evaulate feasibility
        function res = isFeasible(obj, S)
            
            % check feasibility with flat matroids
            res = obj.isFeasible_flat(S);
            
            % check feasibility with face recognition
            if res
                res = obj.isFeasible_face_recognition(S);
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
