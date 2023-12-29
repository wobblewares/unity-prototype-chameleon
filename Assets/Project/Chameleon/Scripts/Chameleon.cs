using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Chameleon : MonoBehaviour, IControllable
{

    // Physics based on Very Very Valet implementation.
    // https://www.youtube.com/watch?v=qdskE8PJy6Q

    #region Inspector Variables

    [Header("Movement")]
    [SerializeField] private float maxSpeed = 80.0f;
    [SerializeField] private float acceleration = 200.0f;
    [SerializeField] private float maxAccelerationForce = 150.0f;
    [SerializeField] private AnimationCurve inverseVelocityCurve = new AnimationCurve();
    [SerializeField] private float maxTranslationPerSecond = 10.0f;
    [SerializeField] private float maxDegreesPerSecond = 10.0f;

    [Header("Floating")]
    [SerializeField] private float rideHeight = 1.0f;
    [SerializeField] private float rideRayLength = 1.0f;
    [SerializeField] private float rideSpringStrength;
    [SerializeField] private float rideSpringDamper;

    [Header("Rotational Forces")]
    [SerializeField] private float uprightJointSpringStrength;
    [SerializeField] private float uprightJointSpringDamper;
    [SerializeField] private float minimumFacingVelocity = 0.1f;

    [Header("Jumping")]
    [SerializeField] private float jumpForce = 10.0f;
    [SerializeField] private float jumpGroundSnapDelay = 0.5f;

    #endregion
    
    #region Components
    private new Rigidbody rigidbody;
    private new Collider collider;
    private PhysicalBody physicalBody;
    private SkinnedMeshRenderer meshRenderer;
    #endregion
    
    #region Private
    private Vector3 _relativeDirection = Vector3.zero;
    private Vector3 _desiredFacingDirection = Vector3.zero;
    private Vector3 _targetVelocity = Vector3.zero;
    private Vector3 _desiredAcceleration = Vector3.zero;
    private float _lastJumpTime = 0.0f;
    #endregion


    #region Public API

    public void Move(Vector3 direction)
    {
	    // project movement direction onto surface to get movement relative to the surface
	    Vector3 surfaceForward = Vector3.Cross(Camera.main.transform.right, physicalBody.SurfaceNormal);
	    Quaternion surfaceAxes = Quaternion.LookRotation(surfaceForward, physicalBody.SurfaceNormal);

	    _relativeDirection = surfaceAxes * new Vector3(direction.x, 0.0f, direction.y);

	    physicalBody.desiredDirection = _relativeDirection;
    }

    public void Jump()
    {
	    _lastJumpTime = Time.time;
		 rigidbody.AddForce((physicalBody.SurfaceNormal + Vector3.up).normalized * jumpForce, ForceMode.Impulse);
    }

    #endregion
    
    #region Unity

    private void Awake()
	{
		rigidbody = GetComponent<Rigidbody>();
		collider = GetComponent<Collider>();
		physicalBody = GetComponent<PhysicalBody>();
		meshRenderer = GetComponentInChildren<SkinnedMeshRenderer>();
	}

	private void FixedUpdate()
	{
		//if you're not grounded but are touching a surface, apply gravity towards the surface
		if (physicalBody.IsOnSurface)
			rigidbody.AddForce(physicalBody.SurfaceNormal * Physics.gravity.y * rigidbody.mass, ForceMode.Acceleration);
		else
			rigidbody.AddForce(Physics.gravity * rigidbody.mass, ForceMode.Acceleration);

		
		Float();

		StandUpright();

		UpdateMovement();

	}

	private void OnDrawGizmos()
	{
		Gizmos.color = Color.red;
		Gizmos.DrawLine(transform.position, transform.position + _desiredAcceleration * 4.0f);
		
		Gizmos.color = Color.blue;
		Gizmos.DrawLine(transform.position, transform.position + _desiredAcceleration * 4.0f);
	}


    #endregion

    #region Private

	private void UpdateMovement()
	{
		// calculate the goal direction and speed right now
		Vector3 goalVelocity = _relativeDirection * maxSpeed;

		float velocityDot = Vector3.Dot(_relativeDirection.normalized, _targetVelocity.normalized);
		float scaledAcceleration = acceleration * inverseVelocityCurve.Evaluate(velocityDot);

		// move the players target velocity towards the goal velocity
		_targetVelocity = Vector3.MoveTowards(_targetVelocity, goalVelocity, scaledAcceleration * Time.fixedDeltaTime);
		
		// calculate the needed acceleration to reach that goal velocity and then clamp it to max acceleration
		Vector3 neededAcceleration = (_targetVelocity - rigidbody.velocity) / Time.fixedDeltaTime;

		// clamp to a max
		float maxAcceleration = maxAccelerationForce * inverseVelocityCurve.Evaluate(velocityDot);
		neededAcceleration = Vector3.ClampMagnitude(neededAcceleration, maxAcceleration);

		// apply the force scaled by the rigidbody's mass
		neededAcceleration = neededAcceleration - Vector3.Project(neededAcceleration, physicalBody.SurfaceNormal);
		rigidbody.AddForce(neededAcceleration * rigidbody.mass);

		// set desired direction for our player alignment system to utilise
		if (_relativeDirection.magnitude > minimumFacingVelocity)
			_desiredFacingDirection = _relativeDirection;

		_desiredAcceleration = neededAcceleration.normalized;

		// zero out our movement direction
		_relativeDirection = Vector3.zero;
	}

	private void Float()
	{
		if (Time.time < _lastJumpTime + jumpGroundSnapDelay)
			return;

		RaycastHit hit = new RaycastHit();
		Ray ray = new Ray(rigidbody.position, -physicalBody.SurfaceNormal);

		if (Physics.Raycast(ray, out hit, rideRayLength))
		{
			Vector3 otherVel = Vector3.zero;
			Rigidbody hitBody = hit.rigidbody;
			if (hitBody != null)
				otherVel = hitBody.velocity;

			float rayDirVel = Vector3.Dot(ray.direction, rigidbody.velocity);
			float otherDirVel = Vector3.Dot(ray.direction, otherVel);
			float relVel = rayDirVel - otherDirVel;
			float x = hit.distance - rideHeight;
			float springForce = (x * rideSpringStrength) - (relVel * rideSpringDamper);

			rigidbody.AddForce(ray.direction * springForce);
		}
	}

	private void StandUpright()
	{
		Vector3 up = (physicalBody.SurfaceNormal.magnitude > 0.0f) ? physicalBody.SurfaceNormal : transform.up;
		Vector3 forward = (_desiredFacingDirection.magnitude > 0.0f) ? _desiredFacingDirection : transform.forward;

		Quaternion uprightJointTargetRot = Quaternion.LookRotation(forward, up);
		Quaternion rotationTowardsGoal = ShortestRotation(uprightJointTargetRot, transform.rotation);

		rotationTowardsGoal.ToAngleAxis(out float rotationDegrees, out Vector3 rotationAxis);
		rotationAxis.Normalize();

		float rotRadians = rotationDegrees * Mathf.Deg2Rad;

		rigidbody.AddTorque((rotationAxis * (rotRadians * uprightJointSpringStrength)) - (rigidbody.angularVelocity * uprightJointSpringDamper));
	}
	
	
	private Quaternion ShortestRotation(Quaternion a, Quaternion b)
	{
		if (Quaternion.Dot(a, b) < 0)
			return a * Quaternion.Inverse(Multiply(b, -1));

		return a * Quaternion.Inverse(b);
	}

	private Quaternion Multiply(Quaternion input, float scalar)
	{
		return new Quaternion(input.x * scalar, input.y * scalar, input.z * scalar, input.w * scalar);
	}

    #endregion
}
