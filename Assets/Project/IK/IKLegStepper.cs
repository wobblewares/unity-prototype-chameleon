using System.Collections;
using UnityEngine;

public class IKLegStepper : MonoBehaviour
{
    // The position and rotation we want to stay in range of
    [SerializeField] public Transform homeTransform;
    // How far above the ground should we be when at rest
    //   Necessary when foot joints aren't exactly at the base of the foot geometry
    [SerializeField] float heightOffset;
    // If we exceed this distance from home, next move try will succeed
    [SerializeField] float wantStepAtDistance = 2f;
    // How far should our new position be past home
    [SerializeField, Range(0, 1)] float stepOvershootFraction = 0.8f;
    // If we exceed this angle from home, next move try will succeed
    [SerializeField] float wantStepAtAngle = 135f;
    // How long a step takes to complete
    [SerializeField] float moveDuration = 1.5f;
    // What layers are considered ground
    [SerializeField] LayerMask groundRaycastMask = ~0;

    public bool Moving { get { return currentState == IKState.MOVING;} }

    Coroutine moveCoroutine;

    private IKState currentState = IKState.INACTIVE;
   
    private Vector3 startPosition = Vector3.zero;
    private Quaternion startRotation = Quaternion.identity;
    private Vector3 centerPoint = Vector3.zero;
    private Vector3 endPosition = Vector3.zero;
    private Quaternion endRotation = Quaternion.identity;
    private float timeElapsed = 0.0f;

    private enum IKState
	{
        INACTIVE,
        READY,
        MOVING
	}


    public void TryMove()
	{
        if(currentState == IKState.MOVING || currentState == IKState.READY)
            return;

        currentState = IKState.READY;
	}

    void Awake()
    {
        // Exit hierarchy to avoid influence from root
        transform.SetParent(null);
    }

    // Move leg if move conditions are met
    public void FixedUpdate()
    {
        switch(currentState)
		{
            case IKState.READY:
                UpdateReadyState();
                break;
            case IKState.MOVING:
                UpdateMoveState();
                break;
		}

    }


    private void UpdateReadyState()
	{
        float distFromHome = Vector3.Distance(transform.position, homeTransform.position);
        float angleFromHome = Quaternion.Angle(transform.rotation, homeTransform.rotation);

        // If we are too far off in position or rotation
        if (distFromHome > wantStepAtDistance ||
             angleFromHome > wantStepAtAngle)
        {
            // If we can't find a good target position, don't step
            if (GetGroundedEndPosition(out Vector3 endPos, out Vector3 endNormal))
            {
                // Get rotation facing in the home forward direction but aligned with the normal plane
                endRotation = Quaternion.LookRotation(
                    Vector3.ProjectOnPlane(homeTransform.forward, endNormal),
                    endNormal
                );

                endPosition = endPos;


                // begin moving
                currentState = IKState.MOVING;

                // Store the initial conditions for interpolation
                startPosition = transform.position;
                startRotation = transform.rotation;

                // Apply the height offset
                endPosition += homeTransform.up * heightOffset;

                // We want to pass through the center point
                centerPoint = (startPosition + endPosition) / 2;
                // But also lift off, so we move it up arbitrarily by half the step distance
                centerPoint += homeTransform.up * Vector3.Distance(startPosition, endPosition) / 2f;

                // Time since step started
                timeElapsed = 0;

            }
        }
    }

    private void UpdateMoveState()
	{

        // Here we use a do-while loop so normalized time goes past 1.0 on the last iteration,
        // placing us at the end position before exiting.
        timeElapsed += Time.deltaTime;

        // Get the normalized time
        float normalizedTime = timeElapsed / moveDuration;

        // Apply easing
        normalizedTime = Easing.EaseInOutCubic(normalizedTime);

        // Note: Unity's Lerp and Slerp functions are clamped at 0.0 and 1.0, 
        // so even if our normalizedTime goes past 1.0, we won't overshoot the end

        // Quadratic bezier curve
        // See https://en.wikipedia.org/wiki/B%C3%A9zier_curve#Constructing_B.C3.A9zier_curves
        transform.position =
            Vector3.Lerp(
                Vector3.Lerp(startPosition, centerPoint, normalizedTime),
                Vector3.Lerp(centerPoint, endPosition, normalizedTime),
                normalizedTime
            );

        transform.rotation = Quaternion.Slerp(startRotation, endRotation, normalizedTime);

        if(timeElapsed > moveDuration)
            currentState = IKState.INACTIVE;

    }

    // Find a grounded point using home position and overshoot fraction
    // Returns true if a point was found
    bool GetGroundedEndPosition(out Vector3 position, out Vector3 normal)
    {
        Vector3 towardHome = (homeTransform.position - transform.position).normalized;

        // Limit overshoot to a fraction of the step distance.
        // This prevents infinite step cycles when a foot end point ends up outside its home position radius bounds.
        float overshootDistance = wantStepAtDistance * stepOvershootFraction;
        Vector3 overshootVector = towardHome * overshootDistance;

        Vector3 raycastOrigin = homeTransform.position + overshootVector + homeTransform.up * 2f;

        if (Physics.Raycast(
            raycastOrigin,
            -homeTransform.up,
            out RaycastHit hit,
            Mathf.Infinity,
            groundRaycastMask, QueryTriggerInteraction.Ignore
        ))
        {
            position = hit.point;
            normal = hit.normal;
            return true;
        }
        position = Vector3.zero;
        normal = Vector3.zero;
        return false;
    }

    void OnDrawGizmosSelected()
    {
        if(homeTransform == null)
            return;

        if (Moving)
            Gizmos.color = Color.green;
        else
            Gizmos.color = Color.red;

        Gizmos.DrawWireSphere(transform.position, 0.25f);
        Gizmos.DrawLine(transform.position, homeTransform.position);
        Gizmos.DrawWireCube(homeTransform.position, Vector3.one * 0.1f);
    }
}