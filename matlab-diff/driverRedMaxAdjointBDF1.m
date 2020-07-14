function driverRedMaxAdjointBDF1()
% driverRedMaxAdjointBDF1 Reference implementation of the RedMax algorithm

sceneID = 100;
scene = scenesRedMax(sceneID);
scene.drawHz = 0;
scene.init();
scene.draw();

fprintf('(%d) ''%s'': tEnd=%.1f, nsteps=%d, nr=%d, nm=%d\n',...
	sceneID,scene.name,scene.tEnd,scene.nsteps,...
	redmax.Scene.countR(),redmax.Scene.countM());


% Optimize
pInit = scene.task.p;
opts = optimoptions(@fminunc,...
	'Display','iter-detailed',...
	'SpecifyObjectiveGradient',true,...
	'CheckGradients',false...
	);
tic
p = fminunc(@(p)taskObjective(p,scene),pInit,opts);
toc
fprintf('p = [\n');
disp(p);
fprintf('\b];\n');

% Show the result
scene.drawHz = 15;
scene.reset();
scene.task.p = p;
scene.task.init();
simLoop(scene);

end

%%
function [P,dPdp] = taskObjective(p,scene)
scene.reset();
scene.task.p = p;
scene.task.init();
simLoop(scene);
[P,dPdp] = scene.task.calcFinal();

% Finite difference test
testGrad = false;
if testGrad
	dPdp_ = zeros(1,length(p)); %#ok<UNRCH>
	for i = 1 : length(p)
		p_ = p;
		p_(i) = p_(i) + sqrt(eps);
		scene.reset();
		scene.task.p = p_;
		scene.task.init();
		simLoop(scene);
		P_ = scene.task.calcFinal();
		dPdp_(:,i) = (P_ - P)/sqrt(eps);
	end
	redmax.Scene.printError('dPdp',dPdp_,dPdp);
end
end

%%
function simLoop(scene)

jroot = scene.joints{1};
h = scene.h;
nsteps = scene.nsteps;

% Integrate
for k = 0 : nsteps-1
	% Apply parameters
	scene.task.applyStep();
	
	% Save old state
	[q0,qdot0] = jroot.getQ();
	jroot.setQ0(q0,qdot0);
	
	% Compute new state
	q1 = q0 + h*qdot0; % initial guess
	[q1,GL,GU,Gp,M,f,K,D,J] = newton(@(q1)evalBDF1(q1,scene),q1);
	qdot1 = (q1 - q0)/h;
	
	% Save new state
	jroot.setQ(q1,qdot1);
	
	% Reparameterize if necessary
	jroot.reparam();
	
	% Update time and step
	jroot.update();
	scene.t = scene.t + h;
	scene.k = k + 1;
	
	% End of step
	scene.saveHistory(GL,GU,Gp,M,f,K,D,J);
	scene.draw();
end
%fprintf('%d steps\n',nsteps);

end

%%
function [q,GL,GU,Gp,M,f,K,D,J] = newton(evalFcn,qInit)
tol = 1e-9;
dqMax = 1e3;
iterMax = 5*length(qInit);
testGrad = false;
q = qInit;
iter = 1;
while true
	[g,G,M,f,K,D,J] = evalFcn(q);
	if testGrad
		% Finite difference test
		sqrteps = sqrt(eps); %#ok<UNRCH>
		G_ = zeros(size(G));
		for i = 1 : length(q)
			q_ = q;
			q_(i) = q_(i) + sqrteps;
			g_ = evalFcn(q_);
			G_(:,i) = (g_ - g)/sqrteps;
		end
		redmax.Scene.printError('G',G_,G);
	end
	% dq = -G\g;
	[GL,GU,Gp] = lu(G,'vector');
	dq = -(GU\(GL\g(Gp)));	
	if norm(dq) > dqMax
		fprintf('Newton diverged\n');
		break;
	end
	q = q + dq;
	if norm(g) < tol
		% Converged
		break;
	end
	if iter >= iterMax
		fprintf('Newton did not converge after %d iterations\n',iterMax);
	end
	iter = iter + 1;
end
%fprintf('%d\n',iter);
end

%%
function [g,G,M,f,K,D,J] = evalBDF1(q1,scene)
h = scene.h;
nr = redmax.Scene.countR();
jroot = scene.joints{1};

% Value from last time step
[q0,qdot0] = jroot.getQ0();

% New values
qdot1 = (q1 - q0)/h;
jroot.setQ(q1,qdot1);
jroot.update();
[M,dMdq,f,K,D,J] = computeValues(scene);

% BDF1: Newton solve for g(q)=0 with Jacobian G = dg/dq
h2 = h*h;
dqtmp = q1 - q0 - h*qdot0;
g = M*dqtmp - h2*f;
G = M - h*D - h2*K;
for i = 1 : nr
	G(:,i) = G(:,i) + dMdq(:,:,i)*dqtmp;
end

end

%%
function [M,dMdq,f,K,D,J] = computeValues(scene)
nr = redmax.Scene.countR();
broot = scene.bodies{1};
jroot = scene.joints{1};
froot = scene.forces{1};

qdot = jroot.getQdot();
[J,dJdq,Jdot,dJdotdq] = jroot.computeJacobian();
[Mm,fm,Km,Dm] = broot.computeMassGrav(scene.grav);
[fm,Km,Dm] = broot.computeForce(fm,Km,Dm);
[fr,Kr,Dr] = jroot.computeForce();
[fr,Kr,Dr,fm,Km,Dm] = froot.computeValues(fr,Kr,Dr,fm,Km,Dm);

% Inertia
M = J'*Mm*J;
dMdq = zeros(nr,nr,nr);
for i = 1 : nr
	tmp = J'*Mm*dJdq(:,:,i);
	dMdq(:,:,i) = tmp' + tmp;
end

% Quadratic velocity vector
fqvv = -J'*Mm*Jdot*qdot;
Kqvv = zeros(nr,nr);
Dqvv = -J'*Mm*Jdot;
MmJdotqdot = Mm*Jdot*qdot;
for i = 1 : nr
	dJdqi = dJdq(:,:,i);
	dJdotdqi = dJdotdq(:,:,i);
	Kqvv(:,i) = -dJdqi'*MmJdotqdot - J'*Mm*dJdotdqi*qdot;
	Dqvv(:,i) = Dqvv(:,i) - J'*Mm*dJdqi*qdot;
end

% Forces
f = fr + J'*fm + fqvv;
K = Kr + J'*Km*J + Kqvv;
D = Dr + J'*Dm*J + Dqvv;
for i = 1 : nr
	dJdqi = dJdq(:,:,i);
	K(:,i) = K(:,i) + dJdqi'*fm + J'*Dm*dJdqi*qdot;
end
end