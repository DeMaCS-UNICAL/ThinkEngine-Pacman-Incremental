using System;
using UnityEngine;
using static GameManager;

// every method of this class without parameters and that returns a bool value can be used to trigger the reasoner.\n
namespace ThinkEngine 
{
	 public class ThinkEngineTrigger:ScriptableObject
	{
		internal static bool smarterReady;
		internal static bool wait;
        internal static bool emergency;

        public bool ExecuteDumb()
        {
			return !smarterReady;
        }

        public bool ExecuteEmergency()
        {
            return !GameManager.scared;
        }

		public bool ExecuteSmarter()
        {
            if (FindObjectOfType<PlayerController>().deadPlaying)
            {
                wait = false;
                emergency = false;
                return false;
            }
            if (emergency)
            {
                return false;
            }
            if (!wait)
            {
                wait = true;
                //Debug.Log("smarter " + Time.realtimeSinceStartup);
                return true;
            }
            return false;
        }
	}
}