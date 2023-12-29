using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Reuseable component allowing for physics based movement
/// </summary>
public class PhysicalBody : MonoBehaviour
{
    #region Inspector Variables
    public LayerMask groundLayers = new LayerMask();
    public LayerMask surfaceLayers = new LayerMask();
    public CollisionShape collisionShape = CollisionShape.AUTO;
    public float surfaceNormalThreshold = 0.5f;
    public float groundedThreshold = 1.0f;
    public float surfaceThreshold = 1.0f;

    public Vector3 desiredDirection = Vector3.zero;
    #endregion

    /// <summary>
    /// The current surface state of this physical object
    /// </summary>
    public SurfaceState State
	{
		get { return surfaceState;}
	}

    /// <summary>
    /// The normal of the ground. Only valid if
    /// surface state equals GROUNDED or MULTIPLE
    /// </summary>
    public Vector3 GroundNormal
	{
		get { return groundNormal; }
	}


    /// <summary>
    /// The average normal of the surfaces we are touching
    /// </summary>
    public Vector3 SurfaceNormal
    {
        get { return surfaceNormal; }
    }

    /// <summary>
    /// The distance to the surface or ground
    /// </summary>
    public float SurfaceDistance
	{
		get { return surfaceDistance; }
	}

    /// <summary>
    /// The last detected surface object
    /// </summary>
    public Collider LastDetectedSurface
	{
		get { return lastDetectedSurface; }
	}

    /// <summary>
    /// Is this object grounded?
    /// </summary>
    public bool IsGrounded
	{
		get { return surfaceState == SurfaceState.GROUNDED || surfaceState == SurfaceState.MULTIPLE; }
	}

    /// <summary>
    /// Is this object on a surface?
    /// </summary>
    public bool IsOnSurface
    {
        get { return surfaceState == SurfaceState.SURFACE || surfaceState == SurfaceState.MULTIPLE; }
    }

    /// <summary>
    /// The current surface state of this physical body
    /// </summary>
    public enum SurfaceState
	{
        AIR,
        GROUNDED,
        SURFACE,
		MULTIPLE
	}

    /// <summary>
    /// The collision shape used for ground and surface detection
    /// </summary>
	public enum CollisionShape
	{ 
        AUTO,
        NONE,
        BOX,
        SPHERE,
        CAPSULE
    }


	#region Unity Functions

	private void Awake()
	{
        rigidbody = GetComponent<Rigidbody>();

        if (collisionShape == CollisionShape.AUTO)
            collisionShape = GetCollisionShape();
	}

	private void Update()
	{
		UpdateGroundAndSurfaceDetection();
	}

	private void LateUpdate()
	{
		collisionThisFrame.Clear();
	}

	private void OnCollisionStay(Collision collision)
    {
        collisionThisFrame.Add(collision);
    }


    private void OnDrawGizmos()
	{
        if (collisionShape == CollisionShape.BOX)
        {
            Vector3 size = (collider as BoxCollider).size;
            size = transform.rotation * new Vector3(size.x * transform.lossyScale.x, size.y * transform.lossyScale.y, size.z * transform.lossyScale.z);
            Gizmos.color = Color.red;
            Vector3 topLeft = new Vector3(transform.position.x - size.x / 2.0f, transform.position.y - size.y / 2.0f, transform.position.z - size.z / 2.0f);
            Vector3 bottomRight = new Vector3(transform.position.x + size.x / 2.0f, transform.position.y + size.y / 2.0f, transform.position.z + size.z / 2.0f);
            Gizmos.DrawLine(topLeft, bottomRight);
        }
    }

    #endregion

    #region Private
    private const float contactExpiry = 0.25f;
    private new Rigidbody rigidbody = null;
    private new Collider collider = null;
	private SurfaceState surfaceState = SurfaceState.AIR;
    private Vector3 groundNormal = Vector3.zero;
    private float lastContactTime = 0;
    private Vector3 surfaceNormal = Vector3.zero;
    private Vector3 lastSurfaceNormal = Vector3.zero;
    private Collider lastDetectedSurface = null;
    private float surfaceDistance = 0.0f;
    private List<Collision> collisionThisFrame = new List<Collision>();
    /// <summary>
    /// Update detection of surfaces and ground
    /// </summary>
    private void UpdateGroundAndSurfaceDetection()
	{
        bool isGrounded = CheckGround();
        bool isOnSurface = CheckSurfaces();

        if(isGrounded && isOnSurface)
            surfaceState = SurfaceState.MULTIPLE;
        else if(isGrounded)
            surfaceState = SurfaceState.GROUNDED;
        else if(isOnSurface)
            surfaceState = SurfaceState.SURFACE;
        else
            surfaceState = SurfaceState.AIR;
    }


    /// <summary>
    /// Check if you are touching the ground
    /// </summary>
    private bool CheckGround()
	{
        Collider[] colliders = null;

        switch (collisionShape)
		{
            case CollisionShape.SPHERE:

                float radius = transform.lossyScale.x * (collider as SphereCollider).radius;
                colliders = Physics.OverlapSphere(rigidbody.position + Vector3.down * groundedThreshold, radius * 0.9f, groundLayers);

                if (colliders.Length == 0)
                    return false;

                if (colliders.Length == 1 && colliders[0].attachedRigidbody == rigidbody)
                    return false;

                groundNormal = GetGroundNormal();
                return true;
            case CollisionShape.BOX:
                Vector3 size = (collider as BoxCollider).size;
                size = new Vector3(size.x * transform.lossyScale.x, size.y * transform.lossyScale.y, size.z * transform.lossyScale.z);
                colliders = Physics.OverlapBox(rigidbody.position + Vector3.down * groundedThreshold, size * 0.5f, transform.rotation, groundLayers);

                if (colliders.Length == 0)
                    return false;

                if (colliders.Length == 1 && colliders[0].attachedRigidbody == rigidbody)
                    return false;

                groundNormal = GetGroundNormal();
                return true;
            case CollisionShape.CAPSULE:
                //only deals with uniform scale
                float capsuleRadius = transform.lossyScale.x * (collider as CapsuleCollider).radius;
                float capsuleHeight = transform.lossyScale.x * (collider as CapsuleCollider).height; //we halve it because we don't want the nubs
                Vector3 direction = GetCapsuleDirectionVector(collider as CapsuleCollider);
                colliders = Physics.OverlapCapsule(rigidbody.position + direction * (capsuleHeight * 0.5f - capsuleRadius) , rigidbody.position - direction * (capsuleHeight * 0.5f - capsuleRadius) + Vector3.down * groundedThreshold, capsuleRadius, groundLayers);

                if (colliders.Length == 0)
                    return false;

                if (colliders.Length == 1 && colliders[0].attachedRigidbody == rigidbody)
                    return false;

                groundNormal = GetGroundNormal();
                return true;

        }

        return false;

    }


    /// <summary>
    /// Returns the most suitable collision shape for this object
    /// </summary>
    /// <returns></returns>
    private CollisionShape GetCollisionShape()
	{
        Collider[] colliders = GetComponentsInChildren<Collider>(false);

        foreach(Collider c in colliders)
		{
            if(c.isTrigger == false)
			{
                // determine c shape
                collider = c;

                if(c as BoxCollider)
                    return CollisionShape.BOX;
                else if(c as SphereCollider)
                    return CollisionShape.SPHERE;
                else if(c as CapsuleCollider)
                    return CollisionShape.CAPSULE;
                else
                    return CollisionShape.NONE;
			}
		}

        return CollisionShape.NONE;
    }




    /// <summary>
    /// Check if you are touching the ground
    /// </summary>
    private bool CheckSurfaces()
    {
        if (Time.time < lastContactTime + contactExpiry)
            surfaceNormal = lastSurfaceNormal;
        else
            surfaceNormal = Vector3.up;

        Collider surface = null;
        Vector3 currSurfaceNormal = Vector3.zero;
        float distance = 0.0f;
        if ( GetSurfaceNormal(out currSurfaceNormal, out distance, out surface) )
		{
            surfaceDistance = distance;
            surfaceNormal = currSurfaceNormal;
            lastSurfaceNormal = surfaceNormal;
            lastContactTime = Time.time;
            lastDetectedSurface = surface;
        }
  
        return Vector3.Dot(surfaceNormal, Vector3.up) < surfaceNormalThreshold;
    }

    /// <summary>
    /// Check for nearby surfaces
    /// </summary>
    private bool GetSurfaceNormal(out Vector3 normal, out float surfaceDistance, out Collider surface)
	{
        if (Raycast(desiredDirection, surfaceThreshold, surfaceLayers, out normal, out surfaceDistance, out surface))
            return true;

        if (Raycast(-rigidbody.transform.up, surfaceThreshold, surfaceLayers, out normal, out surfaceDistance, out surface))
            return true;

        if (lastSurfaceNormal.magnitude > 0.0f && Raycast(-lastSurfaceNormal, surfaceThreshold, surfaceLayers, out normal, out surfaceDistance, out surface))
            return true;

        normal = Vector3.up;
        return false;
    }

    /// <summary>
    /// Cast a ray and return the normal of the surface we hit
    /// </summary>
    private bool Raycast(Vector3 direction, float distance, LayerMask layers, out Vector3 normal, out float surfaceDistance, out Collider surface)
    {
        //calculate normal
        RaycastHit[] hits = Physics.RaycastAll(rigidbody.position, direction, distance, layers);

        foreach (RaycastHit hit in hits)
        {
            if (hit.rigidbody == rigidbody)
                continue;

            normal = hit.normal;
            surface = hit.collider;
            surfaceDistance = hit.distance;
            return true;
        }

        surfaceDistance = 0.0f;
        normal = Vector3.up;
        surface = null;
        return false;
    }

    /// <summary>
    /// Calculate the normal of the surface this object is sitting on
    /// </summary>
    private Vector3 GetGroundNormal()
    {
        //calculate normal
        RaycastHit[] hits = Physics.RaycastAll(rigidbody.position, Vector3.down, 1.1f, groundLayers);

        foreach (RaycastHit hit in hits)
        {
            if (hit.rigidbody == rigidbody)
                continue;

            return hit.normal;
        }

        return Vector3.up;
    }

    private Vector3 GetCapsuleDirectionVector(CapsuleCollider capsuleCollider)
	{
        switch(capsuleCollider.direction)
		{
            case 0:
                return capsuleCollider.transform.right;
            case 1:
                return capsuleCollider.transform.up;
            case 2:
                return capsuleCollider.transform.forward;
        }

        return transform.up;
	}

    private bool CheckSurface()
    {
        if (collisionThisFrame.Count == 0)
        {
            if (Time.time > lastContactTime + contactExpiry)
            {
                surfaceNormal = Vector3.zero;
                surfaceState = SurfaceState.AIR;
                return false;
            }
            else
            {
                surfaceState = SurfaceState.SURFACE;
                surfaceNormal = lastSurfaceNormal;
                return true;
            }
        }
        else
        {
            surfaceState = SurfaceState.SURFACE;

            Vector3 totalNormals = Vector3.zero;
            int normalCount = 0;
            foreach (var collision in collisionThisFrame)
            {
                foreach (var contact in collision.contacts)
                {
                    // ignore contacts that are just the ground
                    if (Vector3.Dot(contact.normal, groundNormal) < 0.75f)
                    {
                        totalNormals += contact.normal;
                        normalCount++;
                    }
                }
            }

            // this is just ground
            if ( normalCount == 0 )
			{
                surfaceNormal = groundNormal;
                lastSurfaceNormal = surfaceNormal;
                lastContactTime = Time.time;
                return false;
            }
            else
			{
                Vector3 averageNormal = totalNormals / (float)normalCount;
                surfaceNormal = averageNormal;
                lastSurfaceNormal = surfaceNormal;
                lastContactTime = Time.time;
                return true;
            }



           
        }
    }


    #endregion
}
