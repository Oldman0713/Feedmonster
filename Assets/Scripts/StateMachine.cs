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
                // ����ݾ����A���欰
                IdleBehavior();
                break;
            case State.Moving:
                // ���沾�ʪ��A���欰
                MoveBehavior();
                break;
            case State.Eating:
                // ���涼�����A���欰
                EatBehavior();
                break;
            case State.Sleeping:
                // �����ı���A���欰
                SleepBehavior();
                break;
        }
    }

    void IdleBehavior()
    {
        // �ݾ��欰����{
    }

    void MoveBehavior()
    {
        // ���ʦ欰����{
    }

    void EatBehavior()
    {
        // �����欰����{
    }

    void SleepBehavior()
    {
        // ��ı�欰����{
    }

    // �o�̥i�H�K�[��k�ӧ��ܪ��A
}
