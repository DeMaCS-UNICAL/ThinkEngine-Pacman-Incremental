using System;
using UnityEngine;

// every method of this class without parameters and that returns a bool value can be used to trigger the reasoner.\n
namespace ThinkEngine 
{
	 public class ThinkEngineTrigger:ScriptableObject
	{
		internal static bool smarterReady;
		internal static bool wait;

        public bool ExecuteDumb()
        {
			return !smarterReady;
        }

		public bool ExecuteSmarter()
        {
			if (!smarterReady)
            {
				return true;
            }
            if (!wait)
            {
                wait = true;
                return true;
            }
            return false;
        }
	}
}