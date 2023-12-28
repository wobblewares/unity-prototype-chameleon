using System;

namespace Wobblewares.Kit
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class WobbleShadow : MonoBehaviour
    {
        #region Inspector Variables

        public Transform target;
        public float offset = 0.1f;
        public Vector3 direction = Vector3.down;
        public bool useLocalBounds = false;
        #endregion

        #region Public API

        
        #endregion

        #region Private

        private void Awake()
        {
            if (target == null)
                target = transform.parent;
    
            UpdateShadowPosition();
        }



        private void Update()
        {
         
            UpdateShadowPosition();
          
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.red;
          
            Gizmos.DrawWireCube(bounds.center, bounds.size);

            if (target == null)
                target = transform.parent;
            
            UpdateShadowPosition();
        }


        private void UpdateShadowPosition()
        {
            if (target == null)
                return;

            if (useLocalBounds)
            {
                bounds = target.GetComponent<MeshRenderer>().localBounds;
                bounds.center += target.transform.position;
                bounds.size = new Vector3(bounds.size.x * target.transform.lossyScale.x,
                    bounds.size.y * target.transform.lossyScale.y,
                    bounds.size.z * target.transform.lossyScale.z);
            }
            else
            {
                bounds = target.GetComponent<MeshRenderer>().bounds;
            }
   
            transform.position = new Vector3(bounds.center.x, (bounds.center.y - bounds.size.y / 2.0f) - offset, bounds.center.z);
            transform.rotation = Quaternion.LookRotation(Vector3.down, target.transform.forward);
        }
        

        private Bounds bounds;

        #endregion
    }
}