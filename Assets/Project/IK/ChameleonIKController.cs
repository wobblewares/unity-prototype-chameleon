namespace Chomolon
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    /// <summary>
    /// Controls the wobbly inverse kinematics based movement for the Chameleon.
    /// </summary>
    public class ChameleonIKController : MonoBehaviour
    {

		#region Inspector Variables
		// A reference to the gecko mesh
		[SerializeField] private Transform headBone = null;
		// The speed the head moves to look at the target
		[SerializeField] private float headSpeed = 5.0f;
		// The speed the head moves to look at the target
		[SerializeField] private float headMaxTurnAngle = 45.0f;

		[SerializeField] IKLegStepper frontLeftLegStepper;
		[SerializeField] IKLegStepper frontRightLegStepper;
		[SerializeField] IKLegStepper backLeftLegStepper;
		[SerializeField] IKLegStepper backRightLegStepper;


		// Idle bobbing!
		[SerializeField] private float turnSpeed = 100f;
		[SerializeField] private float moveSpeed = 2f;
		[SerializeField] private new Rigidbody rigidbody = null;
		[SerializeField] private Transform rootBone = null;
		[SerializeField] Vector3 idleRotationAmplitude;
		[SerializeField] Vector3 idleRotationSpeed;
		[SerializeField] Vector3 idleRotationCycleOffset;
		[SerializeField] Vector3 idleMotionAmplitude;
		[SerializeField] Vector3 idleMotionSpeed;
		[SerializeField] float idleSpeedMultiplier = 1;
		[SerializeField] float bodyIdleWeightChangeVelocity = 1;

		private bool enableTailSway = true;
		SmoothDamp.Float bodyIdleAnimWeight;
		private Transform target = null;
		private Vector3 rootHomePos = Vector3.zero;
		private Quaternion rootHomeRot = Quaternion.identity;
		#endregion

		#region Unity Functions

		private void Awake()
		{
			// we'll create the target manually in the scene
			target = new GameObject("_ChameleonIKTarget").transform;

			StartCoroutine(LegUpdateCoroutine());
			rootHomePos = rootBone.localPosition;
			rootHomeRot = rootBone.localRotation;
			InitializeTail();
		}

		private void LateUpdate()
		{
			UpdateIdleBobbing();

			UpdateHeadTracking();

			UpdateTail();
		}

		#endregion

		#region Private


		private void UpdateIdleBobbing()
		{
			// How much we want the idle bobbing to influence the skeleton
			float turnSpeedFrac = rigidbody.angularVelocity.magnitude / turnSpeed;
			float moveSpeedFrac = rigidbody.velocity.magnitude / moveSpeed;

			float targetIdleAnimWeight = Mathf.Max(1 - turnSpeedFrac * 4, 1 - moveSpeedFrac * 4);
			targetIdleAnimWeight = Mathf.Clamp01(targetIdleAnimWeight);

			bodyIdleAnimWeight.Step(targetIdleAnimWeight, bodyIdleWeightChangeVelocity);

			//// Rotate the root in local space over time
			rootBone.localRotation =  Quaternion.Euler( 
				Mathf.Sin(Time.time * idleRotationSpeed.x * idleSpeedMultiplier + idleRotationCycleOffset.x * Mathf.PI * 2) * idleRotationAmplitude.x * bodyIdleAnimWeight,
				Mathf.Sin(Time.time * idleRotationSpeed.y * idleSpeedMultiplier + idleRotationCycleOffset.y * Mathf.PI * 2) * idleRotationAmplitude.y * bodyIdleAnimWeight,
				Mathf.Sin(Time.time * idleRotationSpeed.z * idleSpeedMultiplier + idleRotationCycleOffset.z * Mathf.PI * 2) * idleRotationAmplitude.z
			 * bodyIdleAnimWeight ) * rootHomeRot;

			// Move the root in local space
			rootBone.localPosition = rootHomePos + new Vector3(
				Mathf.Sin(Time.time * idleMotionSpeed.x * idleSpeedMultiplier) * idleMotionAmplitude.x,
				Mathf.Sin(Time.time * idleMotionSpeed.y * idleSpeedMultiplier) * idleMotionAmplitude.y,
				Mathf.Sin(Time.time * idleMotionSpeed.z * idleSpeedMultiplier) * idleMotionAmplitude.z
			) * bodyIdleAnimWeight;
		}

		/// <summary>
		/// Update the Chameleon's head tracking
		/// </summary>
		private void UpdateHeadTracking()
		{
			// store the current location rotation as we're about to reset it
			Quaternion currentLocalRotation = headBone.localRotation;

			// reset the head rotation so our world to local space transformation will use the head's zero rotation
			// alternatively we can just use the headbone's parent instead
			headBone.localRotation = Quaternion.identity;

			// get the vector from the look target to the head bone in world space and then convert into local space
			Vector3 targetWorldLookDir = target.position - headBone.position;
			Vector3 targetLocalLookDir = headBone.InverseTransformDirection(targetWorldLookDir);

			// Apply angle limit
			targetLocalLookDir = Vector3.RotateTowards(
			  Vector3.forward,
			  targetLocalLookDir,
			  Mathf.Deg2Rad * headMaxTurnAngle, // Note we multiply by Mathf.Deg2Rad here to convert degrees to radians
			  0 // We don't care about the length here, so we leave it at zero
			);

			// calculate the headbone rotation
			Quaternion targetLocalRotation = Quaternion.LookRotation(targetLocalLookDir, Vector3.up);

			// slerp the head bones rotation to the target rotation
			headBone.localRotation = Quaternion.Slerp(currentLocalRotation, targetLocalRotation, 1 - Mathf.Exp(-headSpeed * Time.deltaTime));

		}


		// Only allow diagonal leg pairs to step together
		private IEnumerator LegUpdateCoroutine()
		{
			

			// Run continuously
			while (true)
			{

				frontLeftLegStepper.TryMove();
				backRightLegStepper.TryMove();
				frontRightLegStepper.TryMove();
				backLeftLegStepper.TryMove();

				yield return new WaitForEndOfFrame();

				//// Try moving one diagonal pair of legs
				//do
				//{
				//	frontLeftLegStepper.TryMove();
				//	backRightLegStepper.TryMove();
				//	// Wait a frame
				//	yield return null;

				//	// Stay in this loop while either leg is moving.
				//	// If only one leg in the pair is moving, the calls to TryMove() will let
				//	// the other leg move if it wants to.
				//} while (backRightLegStepper.Moving || frontLeftLegStepper.Moving);

				//// Do the same thing for the other diagonal pair
				//do
				//{
				//	frontRightLegStepper.TryMove();
				//	backLeftLegStepper.TryMove();
				//	yield return null;
				//} while (backLeftLegStepper.Moving || frontRightLegStepper.Moving);
			}
		}



		#endregion

		#region Tail

		[Header("Tail")]
		[SerializeField] Transform[] tailBones;
		[SerializeField] float tailTurnMultiplier;
		[SerializeField] float tailTurnSpeed;

		Quaternion[] tailHomeLocalRotation;

		SmoothDamp.Float tailRotation;

		void InitializeTail()
		{
			// Store the default rotation of the tail bones
			tailHomeLocalRotation = new Quaternion[tailBones.Length];
			for (int i = 0; i < tailHomeLocalRotation.Length; i++)
			{
				tailHomeLocalRotation[i] = tailBones[i].localRotation;
			}
		}

		void UpdateTail()
		{
			if (enableTailSway)
			{
				// Rotate the tail opposite to the current angular velocity to give us a counteracting tail curl
				tailRotation.Step(-rigidbody.angularVelocity.magnitude / turnSpeed * tailTurnMultiplier, tailTurnSpeed);

				for (int i = 0; i < tailBones.Length; i++)
				{
					Quaternion rotation = Quaternion.Euler(0, 0, tailRotation);
					tailBones[i].localRotation = rotation * tailHomeLocalRotation[i];
				}
			}
			else
			{
				for (int i = 0; i < tailBones.Length; i++)
				{
					tailBones[i].localRotation = tailHomeLocalRotation[i];
				}
			}
		}

		#endregion


	}
}