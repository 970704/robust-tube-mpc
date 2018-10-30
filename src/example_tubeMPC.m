addpath('./utils')
addpath('./src')
A = [1 1; 0 1];
B = [0.5; 1]; 
Q = diag([1, 1]);
R = 0.1;
mysys = LinearSystem(A, B, Q, R);

Xc_vertex = [2, -2; 2 2; -10 2; -10 -2];
Uc_vertex = [1; -1];
Xc = Polyhedron(Xc_vertex);
Uc = Polyhedron(Uc_vertex);
W_vertex = [0.15, 0.15; 0.15, -0.15; -0.15, -0.15; -0.15, 0.15];
W = Polyhedron(W_vertex);
x_init = [-7; -2]; 
N = 10;

w_min = [0; -0.06];
w_max = [0; 0.05];
mpc = TubeModelPredictiveControl(mysys, Xc, Uc, W, N);
x_init = [-7; -2];
mpc.simulate(10, x_init);



%{
Xc = Polyhedron(Xc_vertex);
Uc = Polyhedron(Uc_vertex);


tmpc = TubeModelPredictiveControl(A, B, Q, R, Xc, Uc, W, N, x_init);
tmpc.simulation();
tmpc.show_result();
%print(gcf,'-djpeg','-r300','sample2.jpg')
%}

