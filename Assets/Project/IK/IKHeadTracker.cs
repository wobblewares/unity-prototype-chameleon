namespace Chomolon
{

    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class IKHeadTracker : MonoBehaviour
    {

		[SerializeField] private PhysicalBody physicalBody;
		[SerializeField] private new Rigidbody rigidbody;
		[SerializeField] private float trackSpeed = 1.0f;
		[SerializeField] private float forwardDistance = 5.0f;

		private Vector3 targetPosition = Vector3.zero;

		private void Update()
		{
			UpdateHead();
		}


		private void UpdateHead()
		{
			// calculate target position
			Vector3 idealPosition = rigidbody.position + physicalBody.desiredDirection * forwardDistance;
			targetPosition = Vector3.Lerp(targetPosition, idealPosition, 1 - Mathf.Exp(-trackSpeed * Time.deltaTime));
			transform.position = targetPosition;
		}

    }
}