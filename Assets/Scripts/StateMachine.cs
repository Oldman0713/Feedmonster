using UnityEngine;

public class StateMachine : MonoBehaviour
{
    public enum State
    {
        Idle,
        Moving,
        Eating,
        Sleeping
    }

    public State currentState;

    void Update()
    {
        switch (currentState)
        {
            case State.Idle:
                // 執行待機狀態的行為
                IdleBehavior();
                break;
            case State.Moving:
                // 執行移動狀態的行為
                MoveBehavior();
                break;
            case State.Eating:
                // 執行飲食狀態的行為
                EatBehavior();
                break;
            case State.Sleeping:
                // 執行睡覺狀態的行為
                SleepBehavior();
                break;
        }
    }

    void IdleBehavior()
    {
        // 待機行為的實現
    }

    void MoveBehavior()
    {
        // 移動行為的實現
    }

    void EatBehavior()
    {
        // 飲食行為的實現
    }

    void SleepBehavior()
    {
        // 睡覺行為的實現
    }

    // 這裡可以添加方法來改變狀態
}
