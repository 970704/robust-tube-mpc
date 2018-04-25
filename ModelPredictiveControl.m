classdef ModelPredictiveControl < OptimalControlBasis & GraphicsBasis
    
    properties (SetAccess = protected)
        W; % disturbance convex set; 
        w_min; w_max; % lower and upper bound of W 
        
        x_init; % initial state vector
        x_seq_nominal_init; % nominal optimal trajectory computed from x_init
        u_seq_nominal_init;; % nominal optimal input-sequence computed from x_init
        
        Tsimu; % simulation time span
        x_seq_real; % accumulation of the real x's sequence
        u_seq_real; % accumulation of the real u's sequence
        
        time; % current time step
    end
    
    properties (Access = protected)
        flag_disturbance = 0;
        flag_init = 0;
    end
    
    methods (Access = public)
        
        function obj = ModelPredictiveControl(A, B, Q, R, Xc, Uc, W, N)
            obj@GraphicsBasis();
            obj@OptimalControlBasis(A, B, Q, R, Xc, Uc, N);
            if isempty(W) ~= 1
                obj.flag_disturbance = 1;
                obj.W = W;
                obj.w_min = min(W.V, [], 1)';
                obj.w_max = max(W.V, [], 1)';
            end  
        end
        
        function [] = init(obj, x_init)
            obj.flag_init = 1;
            obj.x_init = x_init;
            [x_seq, u_seq] = obj.solve_OptimalControl(x_init);
            obj.x_seq_nominal_init = x_seq;
            obj.u_seq_nominal_init = u_seq;
        end
        
        function [] = simulation(obj, Tsimu, varargin)
            if numel(varargin) == 1
                obj.init(varargin{1})
            elseif obj.flag_init ==0
                error('Error: Please specify the initial state, otherwise initialize object by init()')
            end
            
            x = obj.x_init;
            obj.x_seq_real = x;
            obj.u_seq_real = [];
            obj.time = 1;
            
            for i=1:Tsimu
                u = obj.compute_OptimalInput(x);
                x = obj.propagate(x, u);
                obj.x_seq_real = [obj.x_seq_real, x];
                obj.u_seq_real = [obj.u_seq_real, u];
                obj.time = obj.time + 1;
            end
            clf;
            obj.show_convex(obj.Xc, 'r');
            obj.show_trajectory(obj.x_seq_nominal_init, 'gs-');
            obj.show_trajectory(obj.x_seq_real, 'b*-');
        end
        
    end
    
    methods (Access = protected)
        
        function input = compute_OptimalInput(obj, x)
            [~, u_seq] = obj.solve_OptimalControl(x);
            input = u_seq(:, 1);
        end
        
        function x_new = propagate(obj, x, u)
            if obj.flag_disturbance == 1
                w = obj.w_min + (obj.w_max - obj.w_min).*rand(obj.nx, 1);
            else
                w = zeros(obj.nx, 1);
            end
            x_new = obj.A*x+obj.B*u+w;
        end

    end
    
end