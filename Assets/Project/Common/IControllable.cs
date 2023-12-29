using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IControllable 
{
    #region Public API

    /// <summary>
    /// Move the actor based on the specified direction
    /// </summary>
    public abstract void Move( Vector3 direction );

    /// <summary>
    /// Jump the actor
    /// </summary>
    public abstract void Jump();

    #endregion

}
