namespace Chomolon
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    /// <summary>
    /// Setup the IK leg at runtime allowing you to maintain a clean hierarchy during editing
    /// </summary>
	[RequireComponent(typeof(InverseKinematics))]
    public class IKLegHelper : MonoBehaviour
    {
		#region Inspector Variables
		[SerializeField] private Transform home = null;
		[SerializeField] private IKLegStepper stepper = null;
		#endregion

		#region Unity Functions
		private void Awake()
		{
			stepper.transform.parent = null;
			stepper.homeTransform = home;
		}
		#endregion



	}
}