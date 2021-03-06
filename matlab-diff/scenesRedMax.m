function scene = scenesRedMax(sceneID)
% Creates test scenes

BDF1 = 1;
BDF2 = 2;

scene = redmax.Scene();

% Default values
density = 1.0;

switch(sceneID)
	case -2
		scene.name = 'Single revolute';
		%scene.grav = [0 0 0]';
		%scene.tEnd = 0.1;
		sides = [2 0.2 0.2];
		scene.waxis = [-1 1 -1 1 -2 0];
		scene.view = [0 0];
		scene.bodies{1} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
		scene.joints{1} = redmax.JointRevolute([],scene.bodies{1},[0 1 0]');
		scene.joints{1}.setJointTransform(eye(4));
		scene.joints{1}.setGeometry(0.1,0.1);
		scene.joints{1}.q(1) = 0;%pi/2;
		scene.joints{1}.qdot(1) = 1;
		scene.bodies{1}.setBodyTransform([eye(3),[1 0 0]'; 0 0 0 1]);
	case -1
		scene.name = 'Simpler serial chain';
		%scene.grav = [0 0 0]';
		%scene.tEnd = 0.1;
		sides = [10 1 1];
		nbodies = 1;
		scene.waxis = nbodies*5*[-1 1 -1 1 -2 0];
		for i = 1 : nbodies
			scene.bodies{i} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
			if i == 1
				scene.joints{i} = redmax.JointRevolute([],scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform(eye(4));
				scene.joints{i}.q(1) = 0;%pi/2;
				scene.joints{i}.qdot(1) = 1;
			else
				scene.joints{i} = redmax.JointRevolute(scene.joints{i-1},scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
				scene.joints{i}.q(1) = pi/4;
				scene.joints{i}.qdot(1) = 1;
			end
			scene.bodies{i}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
			% Joint stiffness and damping
			scene.joints{i}.setStiffness(1e6);
			scene.joints{i}.setDamping(1e4);
		end
	case 0
		scene.name = 'Simple serial chain';
		scene.Hexpected(BDF1) = -1.2705398823489915e+05;
		scene.Hexpected(BDF2) = 2.6058008179021417e+03;
		sides = [10 1 1];
		nbodies = 5;
		scene.waxis = nbodies*5*[-1 1 -0.1 0.1 -2 0];
		for i = 1 : nbodies
			scene.bodies{i} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
			if i == 1
				scene.joints{i} = redmax.JointRevolute([],scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform(eye(4));
			else
				if mod(i,2) == 1
					scene.joints{i} = redmax.JointRevolute(scene.joints{i-1},scene.bodies{i},[0 1 0]');
				else
					scene.joints{i} = redmax.JointFixed(scene.joints{i-1},scene.bodies{i});
				end
				%scene.joints{i} = redmax.JointRevolute(scene.joints{i-1},scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
			end
			scene.bodies{i}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
			if mod(i,2) == 1
				scene.joints{i}.q(1) = pi/4;
			else
				scene.joints{i}.q(1) = 0;
			end
		end
	case 1
		scene.name = 'Different revolute axes';
		scene.Hexpected(BDF1) = -3.8359074258588909e+04;
		scene.Hexpected(BDF2) = -9.7138545812971279e+02;
		sides = [10 1 1];
		scene.waxis = [-20 20 -20 20 -20 5];
		scene.bodies{1} = redmax.BodyCuboid(density,sides);
		scene.bodies{2} = redmax.BodyCuboid(density,sides);
		scene.bodies{3} = redmax.BodyCuboid(density,sides);
		scene.joints{1} = redmax.JointRevolute([],       scene.bodies{1},[0 0 1]');
		scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[0 1 0]');
		scene.joints{3} = redmax.JointRevolute(scene.joints{2},scene.bodies{3},[0 0 1]');
		scene.bodies{1}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
		scene.bodies{2}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
		scene.bodies{3}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
		scene.joints{1}.setJointTransform(eye(4));
		scene.joints{2}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
		scene.joints{3}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
		scene.joints{1}.q(1) = 0;
		scene.joints{2}.q(1) = pi/2;
		scene.joints{3}.q(1) = pi/2;
	case 2
		scene.name = 'Branching';
		%      X        in YZ plane
		%      |        
		%  X---Z---Y    joint axes shown
		%  |       |
		%  |       |
		scene.Hexpected(BDF1) = -2.2826101928480086e+04;
		scene.Hexpected(BDF2) = -2.4159349151742754e+02;
		scene.waxis = [-15 15 -15 15 -10 20];
		scene.bodies{1} = redmax.BodyCuboid(density,[1  1 10]);
		scene.bodies{2} = redmax.BodyCuboid(density,[1 20  1]);
		scene.bodies{3} = redmax.BodyCuboid(density,[1  1 10]);
		scene.bodies{4} = redmax.BodyCuboid(density,[1  1 10]);
		scene.joints{1} = redmax.JointRevolute([],       scene.bodies{1},[1 0 0]');
		scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[0 0 1]');
		scene.joints{3} = redmax.JointRevolute(scene.joints{2},scene.bodies{3},[1 0 0]');
		scene.joints{4} = redmax.JointRevolute(scene.joints{2},scene.bodies{4},[0 1 0]');
		scene.bodies{1}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.bodies{2}.setBodyTransform([eye(3),[0 0  0]'; 0 0 0 1]);
		scene.bodies{3}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.bodies{4}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.joints{1}.setJointTransform([eye(3),[0   0  15]'; 0 0 0 1]);
		scene.joints{2}.setJointTransform([eye(3),[0   0 -10]'; 0 0 0 1]);
		scene.joints{3}.setJointTransform([eye(3),[0 -10   0]'; 0 0 0 1]);
		scene.joints{4}.setJointTransform([eye(3),[0  10   0]'; 0 0 0 1]);
		scene.joints{1}.q(1) = 0;
		scene.joints{2}.q(1) = 0;
		scene.joints{3}.q(1) = pi/4;
		scene.joints{4}.q(1) = pi/4;
	case 3
		scene.name = 'Prismatic joint';
		scene.Hexpected(BDF1) = -3.7579402399569808e+04;
		scene.Hexpected(BDF2) = -6.1132876082600706e+02;
		scene.waxis = 15*[-1.0 1.0 -0.2 0.2 -1 0.1];
		scene.bodies{1} = redmax.BodyCuboid(density,[20 1 1]);
		scene.joints{1} = redmax.JointPrismatic([],scene.bodies{1},[1 0 0]');
		scene.joints{1}.setJointTransform(eye(4));
		scene.bodies{1}.setBodyTransform(eye(4));
		scene.bodies{2} = redmax.BodyCuboid(density,[1 1 10]);
		scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[0 1 0]');
		scene.joints{2}.setJointTransform([eye(3),[-10 0 0]'; 0 0 0 1]);
		scene.bodies{2}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.joints{2}.q = pi/2;
	case 4
		scene.name = 'Planar joint';
		scene.Hexpected(BDF1) = -4.5738939646068720e+04;
		scene.Hexpected(BDF2) = -4.7000178355609387e+02;
		scene.waxis = 15*[-1.0 1.0 -1 1 -1 0.1];
		scene.bodies{1} = redmax.BodyCuboid(density,[10 10 1]);
		scene.joints{1} = redmax.JointPlanar([],scene.bodies{1});
		scene.joints{1}.setJointTransform(eye(4));
		scene.bodies{1}.setBodyTransform(eye(4));
		scene.bodies{2} = redmax.BodyCuboid(density,[1 1 10]);
		scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[0 1 0]');
		scene.joints{2}.setJointTransform([eye(3),[-5 0 0]'; 0 0 0 1]);
		scene.bodies{2}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.bodies{3} = redmax.BodyCuboid(density,[1 1 10]);
		scene.joints{3} = redmax.JointRevolute(scene.joints{1},scene.bodies{3},[1 0 0]');
		scene.joints{3}.setJointTransform([eye(3),[0 -5 0]'; 0 0 0 1]);
		scene.bodies{3}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.joints{2}.q(1) = pi/2;
		scene.joints{3}.q(1) = pi/4;
	case 5
		scene.name = 'Translational joint';
		scene.Hexpected(BDF1) = 3.3661704151378050e+04;
		scene.Hexpected(BDF2) = 3.3377464890219308e+04;
		scene.tEnd = 2.0;
		scene.grav = [0 0 0]';
		scene.waxis = 20*[-1.5 0.5 -1.0 1.0 -0.5 0.5];
		scene.bodies{1} = redmax.BodyCuboid(density,[10 10 1]);
		scene.joints{1} = redmax.JointTranslational([],scene.bodies{1});
		scene.joints{1}.setJointTransform(eye(4));
		scene.bodies{1}.setBodyTransform(eye(4));
		scene.bodies{2} = redmax.BodyCuboid(density,[1 1 10]);
		scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[0 1 0]');
		scene.joints{2}.setJointTransform([eye(3),[-5 0 0]'; 0 0 0 1]);
		scene.bodies{2}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.bodies{3} = redmax.BodyCuboid(density,[1 1 10]);
		scene.joints{3} = redmax.JointRevolute(scene.joints{1},scene.bodies{3},[1 0 0]');
		scene.joints{3}.setJointTransform([eye(3),[0 -5 0]'; 0 0 0 1]);
		scene.bodies{3}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.joints{1}.qdot(1) = 0.0;
		scene.joints{1}.qdot(3) = 0.0;
		scene.joints{2}.qdot(1) = -10.0;
		scene.joints{3}.qdot(1) = 10.0;
	case 6
		scene.name = 'Free2D joint';
		scene.Hexpected(BDF1) = 2.0322933333333378e+04;
		scene.Hexpected(BDF2) = 2.1283333333333332e+04;
		scene.h = 5e-3;
		scene.tEnd = 0.4;
		scene.grav = [0 -980 0]';
		scene.view = 2;
		scene.drawHz = 100;
		scene.plotH = true;
		scene.waxis = 10*[-1 1 -1 1 -0.1 0.1];
		scene.bodies{1} = redmax.BodyCuboid(density,[1 1 1]);
		scene.joints{1} = redmax.JointFree2D([],scene.bodies{1});
		scene.joints{1}.q = [-10 -10 0]';
		scene.joints{1}.qdot = [50 200 20]';
		scene.joints{1}.setJointTransform(eye(4));
		scene.bodies{1}.setBodyTransform(eye(4));
	case 7
		scene.name = 'Spherical joint';
		scene.Hexpected(BDF1) = -8.7859815791305155e+03;
		scene.Hexpected(BDF2) = 8.6544602745403390e+03;
		scene.tEnd = 1.0;
		scene.h = 2e-3; % double pendulum requires small time steps
		scene.drawHz = 15;
		sides = [1 1 10];
		scene.waxis = 10*[-1 1 -1 1 -1.9 0.1];
		scene.bodies{1} = redmax.BodyCuboid(density,sides);
		scene.bodies{1}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.joints{1} = redmax.JointSpherical([],scene.bodies{1}); %#ok<*UNRCH>
		scene.joints{1}.setJointTransform(eye(4));
		scene.joints{1}.q = redmax.JointSpherical.getEulerInv(scene.joints{1}.chart,se3.aaToMat([1 0 0],pi/8));
		scene.joints{1}.qdot = [2 2 2]';
		scene.bodies{2} = redmax.BodyCuboid(density,sides);
		scene.bodies{2}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
		scene.joints{2} = redmax.JointSpherical(scene.joints{1},scene.bodies{2});
		%scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[1 0 0]');
		scene.joints{2}.setJointTransform([eye(3),[0 0 -10]'; 0 0 0 1]);
		scene.joints{2}.q(1) = pi/2;
	case 8
		scene.name = 'Universal joint';
		sides = [1 1 10];
		nbodies = 3;
		scene.waxis = nbodies*10*[-0.7 0.7 -0.7 0.7 -1 0.1];
		scene.Hexpected(BDF1) = -2.5276246935781084e+04;
		scene.Hexpected(BDF2) = -1.3781281283808785e+03;
		for i = 1 : nbodies
			scene.bodies{i} = redmax.BodyCuboid(density,sides);
			if i == 1
				scene.joints{i} = redmax.JointUniversal([],scene.bodies{i});
				scene.joints{i}.setJointTransform(eye(4));
			else
				scene.joints{i} = redmax.JointUniversal(scene.joints{i-1},scene.bodies{i});
				scene.joints{i}.setJointTransform([eye(3),[0 0 -10]'; 0 0 0 1]);
			end
			scene.bodies{i}.setBodyTransform([eye(3),[0 0 -5]'; 0 0 0 1]);
			if mod(i,2) == 1
				scene.joints{i}.q(1) = pi/8;
			else
				scene.joints{i}.q(2) = pi/8;
			end
		end
	case 9
		scene.name = 'Free3D joint';
		scene.Hexpected(BDF1) = 4.3970920953724946e+00;
		scene.Hexpected(BDF2) = 4.5466508559364156e+00;
		scene.h = 5e-2;
		scene.tEnd = 6.0;
		scene.grav = [0 0 -1]';
		scene.waxis = 5*[-0.2 0.2 -0.2 0.2 -1.0 1.0];
		scene.bodies{1} = redmax.BodyCuboid(density,[1 1 1]);
		scene.joints{1} = redmax.JointFree3D([],scene.bodies{1});
		scene.joints{1}.qdot = [ 0 0 3 0.2 0.4 0.6]';
		scene.joints{1}.setJointTransform(eye(4));
		scene.bodies{1}.setBodyTransform(eye(4));
	case 10
		scene.name = 'Loop';
		scene.waxis = [-15 15 -1 1 -20 2];
		scene.Hexpected(BDF1) = 1.2376477982839792e+03;
		scene.Hexpected(BDF2) = 4.1146190850293169e+03;
		scene.bodies{1} = redmax.BodyCuboid(density,[20 1  1]);
		scene.bodies{2} = redmax.BodyCuboid(density,[ 1 1 10]);
		scene.bodies{3} = redmax.BodyCuboid(density,[ 1 1 10]);
		scene.bodies{4} = redmax.BodyCuboid(density,[20 1  1]);
		scene.bodies{5} = redmax.BodyCuboid(density,[ 1 1 10]);
		scene.joints{1} = redmax.JointFixed([],scene.bodies{1});
		scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[0 1 0]');
		scene.joints{3} = redmax.JointRevolute(scene.joints{1},scene.bodies{3},[0 1 0]');
		scene.joints{4} = redmax.JointRevolute(scene.joints{2},scene.bodies{4},[0 1 0]');
		scene.joints{5} = redmax.JointRevolute(scene.joints{4},scene.bodies{5},[0 1 0]');
		scene.bodies{1}.setBodyTransform(eye(4));
		scene.bodies{2}.setBodyTransform([eye(3),[ 0 0 -5]'; 0 0 0 1]);
		scene.bodies{3}.setBodyTransform([eye(3),[ 0 0 -5]'; 0 0 0 1]);
		scene.bodies{4}.setBodyTransform([eye(3),[10 0  0]'; 0 0 0 1]);
		scene.bodies{5}.setBodyTransform([eye(3),[ 0 0 -5]'; 0 0 0 1]);
		scene.joints{1}.setJointTransform(eye(4));
		scene.joints{2}.setJointTransform([eye(3),[-10 0   0]'; 0 0 0 1]);
		scene.joints{3}.setJointTransform([eye(3),[ 10 0   0]'; 0 0 0 1]);
		scene.joints{4}.setJointTransform([eye(3),[  0 0 -10]'; 0 0 0 1]);
		scene.joints{5}.setJointTransform([eye(3),[ 10 0   0]'; 0 0 0 1]);
		scene.forces{1} = redmax.ForcePointPoint(scene.bodies{3},[0 0 -5]',scene.bodies{4},[10 0 0]');
		scene.forces{1}.setStiffness(1e7);
		scene.forces{1}.setDamping(0);
		scene.joints{5}.qdot(1) = 5;
	case 11
		scene.name = 'Free2D with ground';
		scene.Hexpected(BDF1) = -4.4208045000000002e+03;
		scene.Hexpected(BDF2) = -2.7811251900394832e+03;
		scene.h = 5e-4;
		scene.tEnd = 0.6;
		scene.drawHz = 100;
		scene.grav = [0 -980 0]';
		scene.view = 2;
		%scene.plotH = false;
		scene.waxis = 3*[-1 2 0 2 -0.1 0.1];
		scene.bodies{1} = redmax.BodyCuboid(density,[3 1 1]);
		scene.joints{1} = redmax.JointFree2D([],scene.bodies{1});
		scene.joints{1}.q = [-1 2 0]';
		scene.joints{1}.qdot = [5 70 2]';
		scene.joints{1}.setJointTransform(eye(4));
		scene.bodies{1}.setBodyTransform(eye(4));
		scene.forces{1} = redmax.ForceGroundCuboid(scene.bodies{1});
		scene.forces{1}.setTransform([se3.aaToMat([1 0 0],-pi/2),[0 0 0]'; 0 0 0 1]);
		scene.forces{1}.setStiffness(1e5,1e2);
		scene.forces{1}.setDamping(3e1);
		scene.forces{1}.setFriction(0.5);
	case 12
		scene.name = 'Spring-damper';
		scene.Hexpected(BDF1) = -2.2145412057327565e+04;
		scene.Hexpected(BDF2) = -8.9887693524038732e+03;
		%scene.tEnd = 10;
		scene.plotH = false;
		sides = [10 1 1];
		scene.waxis = 10*[-0.5 1.5 -0.1 0.1 -1 1];
		scene.bodies{1} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
		scene.joints{1} = redmax.JointRevolute([],scene.bodies{1},[0 1 0]');
		scene.joints{1}.setJointTransform(eye(4));
		scene.bodies{1}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
		scene.joints{1}.q(1) = 0;
		scene.joints{1}.qdot(1) = 0;
		scene.bodies{2} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
		scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[0 1 0]');
		scene.joints{2}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
		scene.bodies{2}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
		scene.joints{2}.q(1) = 0;
		scene.joints{2}.qdot(1) = 0;
		scene.forces{1} = redmax.ForceSpringDamper([],[-5 0 -5]',scene.bodies{end},[0 0 -2]');
		scene.forces{1}.setStiffness(1e6);
		scene.forces{1}.setDamping(1e3);
		scene.forces{2} = redmax.ForceSpringDamper(scene.bodies{1},[0 0 2]',scene.bodies{2},[0 0 2]');
		scene.forces{2}.setStiffness(1e6);
		scene.forces{2}.setDamping(1e3);
	case 13
		scene.name = 'Cables';
		scene.Hexpected(BDF1) = -3.1874892332895153e+04;
		scene.Hexpected(BDF2) = -2.7872894793863266e+04;
		%scene.tEnd = 10;
		scene.plotH = false;
		sides = [10 1 1];
		scene.waxis = 10*[-0.5 1.5 -0.1 0.1 -2 0];
		scene.view = [32 26];
		scene.bodies{1} = redmax.BodyCuboid(density,[0.1 0.1 0.1]); %#ok<*SAGROW>
		scene.joints{1} = redmax.JointFixed([],scene.bodies{1});
		scene.bodies{2} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
		scene.joints{2} = redmax.JointRevolute(scene.joints{1},scene.bodies{2},[0 1 0]');
		scene.joints{2}.setJointTransform(eye(4));
		scene.bodies{2}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
		scene.joints{2}.q(1) = pi/2;
		scene.bodies{3} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
		scene.joints{3} = redmax.JointRevolute(scene.joints{2},scene.bodies{3},[0 1 0]');
		scene.joints{3}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
		scene.bodies{3}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
		scene.joints{3}.q(1) = -pi/2;
		scene.bodies{4} = redmax.BodyCuboid(density,[1 1 1]); %#ok<*SAGROW>
		scene.joints{4} = redmax.JointPrismatic(scene.joints{1},scene.bodies{4},[1 0 0]');
		scene.joints{4}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
		scene.bodies{4}.setBodyTransform([eye(3),[0 0 0]'; 0 0 0 1]);
		scene.joints{4}.setStiffness(1e4);
		scene.joints{4}.setDamping(1e3);
		scene.forces{1} = redmax.ForceCable();
		scene.forces{1}.setStiffness(1e6);
		scene.forces{1}.setDamping(1e3);
		scene.forces{1}.addBodyPoint(scene.bodies{4},[0 0 0]');
		scene.forces{1}.addBodyPoint(scene.bodies{2},[-4 0 1]');
		scene.forces{1}.addBodyPoint(scene.bodies{3},[-4 0 1]');
	case 14
		scene.name = 'Joint limits';
		scene.Hexpected(BDF1) = -2.5928305306546572e+04;
		scene.Hexpected(BDF2) = -1.8476279319765570e+04;
		%scene.tEnd = 5;
		scene.h = 5e-3;
		%scene.drawHz = 100;
		sides = [10 1 1];
		nbodies = 3;
		scene.waxis = nbodies*5*[-1 1 -1 1 -2 0];
		for i = 1 : nbodies
			scene.bodies{i} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
			if i == 1
				scene.joints{i} = redmax.JointRevolute([],scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform([se3.aaToMat([0 1 0],pi/2),[0 0 0]'; 0 0 0 1]);
				scene.joints{i}.q(1) = 0;
				scene.joints{i}.qdot(1) = 0;
			else
				scene.joints{i} = redmax.JointRevolute(scene.joints{i-1},scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
				scene.joints{i}.q(1) = -pi/6;
				scene.joints{i}.qdot(1) = 0;
			end
			scene.bodies{i}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
			% Joint limits
			scene.joints{i}.setLimitLower(-pi/2);
			scene.joints{i}.setLimitUpper(0);
			scene.joints{i}.setLimitStiffness(1e5);
			scene.joints{i}.setLimitDamping(1e2);
			scene.joints{i}.setDamping(1e2);
		end
	case 100
		scene.name = 'Adjoint BDF1';
		%scene.grav = [0 0 0]';
		%scene.tEnd = 0.1;
		scene.drawHz = 15;
		scene.plotH = false;
		sides = [10 1 1];
		nbodies = 2;
		scene.waxis = nbodies*5*[-1 1 -1 1 -2 0];
		for i = 1 : nbodies
			scene.bodies{i} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
			if i == 1
				scene.joints{i} = redmax.JointRevolute([],scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform(eye(4));
				scene.joints{i}.q(1) = pi/2;
				scene.joints{i}.qdot(1) = 1;
			else
				scene.joints{i} = redmax.JointRevolute(scene.joints{i-1},scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
				scene.joints{i}.q(1) = pi/4;
				scene.joints{i}.qdot(1) = 1;
			end
			scene.bodies{i}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
			% Joint stiffness and damping
			scene.joints{i}.setStiffness(1e4);
			scene.joints{i}.setDamping(1e4);
		end
		scene.task = redmax.TaskBDF1PointPos(scene);
		scene.task.setTime(scene.tEnd);
		scene.task.setBody(scene.bodies{end});
		scene.task.setPoint([5 0 0]');
		%scene.task.setTarget([-5 0 -8.6603]');
		scene.task.setTarget([10 0 -10]');
		scene.task.setScale(1e5);
		scene.task.setWeights(1e-2,1e2);
	case 101
		scene.name = 'Adjoint BDF2';
		%scene.grav = [0 0 0]';
		%scene.tEnd = 0.1;
		scene.drawHz = 15;
		scene.plotH = false;
		sides = [10 1 1];
		nbodies = 2;
		scene.waxis = nbodies*5*[-1 1 -1 1 -2 0];
		for i = 1 : nbodies
			scene.bodies{i} = redmax.BodyCuboid(density,sides); %#ok<*SAGROW>
			if i == 1
				scene.joints{i} = redmax.JointRevolute([],scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform(eye(4));
				scene.joints{i}.q(1) = pi/2;
				scene.joints{i}.qdot(1) = 1;
			else
				scene.joints{i} = redmax.JointRevolute(scene.joints{i-1},scene.bodies{i},[0 1 0]');
				scene.joints{i}.setJointTransform([eye(3),[10 0 0]'; 0 0 0 1]);
				scene.joints{i}.q(1) = pi/4;
				scene.joints{i}.qdot(1) = 1;
			end
			scene.bodies{i}.setBodyTransform([eye(3),[5 0 0]'; 0 0 0 1]);
			% Joint stiffness and damping
			scene.joints{i}.setStiffness(1e4);
			scene.joints{i}.setDamping(1e4);
		end
		scene.task = redmax.TaskBDF2PointPos(scene);
		scene.task.setTime(scene.tEnd);
		scene.task.setBody(scene.bodies{end});
		scene.task.setPoint([5 0 0]');
		%scene.task.setTarget([-5 0 -8.6603]');
		scene.task.setTarget([-10 0 -10]');
		scene.task.setScale(1e5);
		scene.task.setWeights(1e-2,1e2);
end

end
