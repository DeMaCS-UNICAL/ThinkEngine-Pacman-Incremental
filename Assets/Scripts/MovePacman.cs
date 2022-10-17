using System;
using System.Collections;
using System.Collections.Generic;
using ThinkEngine;
using ThinkEngine.Planning;
using UnityEngine;
using Action = ThinkEngine.Planning.Action;

public class MovePacman : Action
{
    public string Direction { get; set; }
    public int Order { get; set; }
    public int PlanLength { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int ai { get; set; } 
    public PlayerController pacman;
    public PositionToInt pacmanPos;

    public override void Do()
    {
        if(ai == 1)
        {
            ThinkEngineTrigger.emergency = true;
        }
        //Debug.Log(ai+" "+Direction + X+ " "+Y+" at "+Time.realtimeSinceStartup+"       "+Order);
        pacman.aiDirection = Direction;
    }

    public override bool Done()
    {
        bool done = pacman.AppliedOrNotApplicabile();
        if(done && Order == PlanLength)
        {
            RestoreTriggers();
        }
        return done;

    }

    private void RestoreTriggers()
    {
        if (ai == 2)
        {
            ThinkEngineTrigger.wait = false;
        }
        else if (ai == 1)
        {
            ThinkEngineTrigger.emergency = true;
        }
    }

    public override State Prerequisite()
    {
        if (!ThinkEngineTrigger.smarterReady && ai == 2)
        {
            ThinkEngineTrigger.smarterReady = true;
            return ReturnState(State.ABORT);
        }
        if (ai == 3 && ThinkEngineTrigger.smarterReady)
        {
            return ReturnState(State.ABORT);

        }
        if (pacman == null) {
            pacman = FindObjectOfType<PlayerController>();
            pacmanPos=pacman.GetComponent<PositionToInt>();
        }

        if (!pacman.MatchingDirections() && pacman.AppliedOrNotApplicabile())
        {
            return ReturnState(State.WAIT);
        }
        if (pacman.aiDirection == null)
        {
            return ReturnState(State.READY);
        }
        //Debug.Log(ai + " " + X + " " + Y + " pacman: " + pacmanPos.x + " " + pacmanPos.y);
        if(pacmanPos.x!=X && pacmanPos.y != Y)
        {
            return ReturnState(State.ABORT);
        }
        if(pacmanPos.x == X && pacmanPos.y == Y)
        {
            return ReturnState(State.READY);
        }
        if (pacmanPos.x==X)
        {
            if (pacmanPos.y > Y)
            {
                float nextDelta = pacman.NextY(pacmanPos.y) - Y;
                if (nextDelta > pacmanPos.y - Y)
                {
                    return ReturnState(State.SKIP);
                }
            }
            else
            {
                float nextDelta = Y - pacman.NextY(pacmanPos.y);
                if (nextDelta > Y - pacmanPos.y)
                {
                    return ReturnState(State.SKIP);
                }
            }
        }
        if (pacmanPos.y == Y)
        {
            if (pacmanPos.x > X)
            {
                float nextDelta = pacman.NextX(pacmanPos.x) - X;
                if (nextDelta > pacmanPos.x - X)
                {
                    return ReturnState(State.SKIP);
                }
            }
            else
            {
                float nextDelta = X - pacman.NextX(pacmanPos.x);
                if (nextDelta > X - pacmanPos.x)
                {
                    return ReturnState(State.SKIP);
                }
            }
        }
            //Debug.Log("WAIT      " + Order+ " "+Time.realtimeSinceStartup);
        return State.WAIT;
    }

    private State ReturnState(State state)
    {
        if(state == State.ABORT)
        {
            //Debug.Log("ABORT      " + Order+ " ("+X+" "+Y+") " + " (" + pacmanPos.x + " " + pacmanPos.y + ") " + Time.realtimeSinceStartup);
            RestoreTriggers();
        }
        if (state==State.SKIP && Order == PlanLength)
        {
            //Debug.Log("SKIP      " + Order+" " + " (" + X + " " + Y + ") " + Time.realtimeSinceStartup);
            RestoreTriggers();
        }
        return state;
    }
}
