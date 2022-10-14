using System.Collections;
using System.Collections.Generic;
using ThinkEngine;
using ThinkEngine.Planning;
using UnityEngine;

public class MovePacman : Action
{
    public string Direction { get; set; }
    public int Order { get; set; }
    public int PlanLength { get; set; }
    public int ai { get; set; } 
    public int X { get; set; } 
    public int Y { get; set; }
    public PlayerController pacman;
    public int previousX=-100;
    public int previousY=-100;
    public int cont = 0;

    public override void Do()
    {
        Debug.Log(ai+" "+Direction + " at "+Time.realtimeSinceStartup+"       "+Order);
        if(ai==1 && PlanLength -1 == Order)
        {
            ThinkEngineTrigger.wait = false;
        }
        pacman.aiDirection = Direction;
    }

    public override bool Done()
    {
        return FindObjectOfType<PlayerController>().MatchDirection();
    }

    public override State Prerequisite()
    {
        if (!ThinkEngineTrigger.smarterReady && ai == 1)
        {
            ThinkEngineTrigger.smarterReady = true;
            return State.ABORT;
        }
        if (pacman == null) {
            pacman = FindObjectOfType<PlayerController>();
        }
        if (ai == 2 && ThinkEngineTrigger.smarterReady)
        {
            return State.ABORT;
        }
        return State.READY; 
    }
}
