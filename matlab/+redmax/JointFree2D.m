classdef JointFree2D < redmax.Joint
	% 2D free joint
	%
	
	%%
	properties
		jointP % XY planar
		jointR % Z revolute
	end
	
	%%
	methods
		%%
		function this = JointFree2D(parent,body)
			this = this@redmax.Joint(parent,body,3);
			this.jointP = redmax.JointPlanar([],body);
			this.jointR = redmax.JointRevolute([],body,[0 0 1]');
			body.joint = this;
		end
	end
	
	%%
	methods (Access = protected)
		%%
		function update_(this)
			this.jointP.q = this.q(1:2);
			this.jointR.q = this.q(3);
			this.jointP.qdot = this.qdot(1:2);
			this.jointR.qdot = this.qdot(3);
			this.jointP.update_();
			this.jointR.update_();
			
			Qp = this.jointP.Q;
			Qr = this.jointR.Q;
			this.Q = Qp*Qr;
			
			rx = Qr(1,1:3);
			ry = Qr(2,1:3);
			qdotr = this.qdot(3);
			
			this.S = [
				0 0 0 rx
				0 0 0 ry
				0 0 1 0 0 0]';
			this.Sdot = [
				0 0 0 qdotr*rx(2) -qdotr*rx(1) 0
				0 0 0 qdotr*ry(2) -qdotr*ry(1) 0
				0 0 0 0 0 0]';
		end
	end
end
