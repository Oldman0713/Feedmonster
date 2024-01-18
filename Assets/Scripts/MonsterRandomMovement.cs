using UnityEngine;
using UnityEngine.AI;

public class MonsterRandomMovement : MonoBehaviour
{
    public float moveRadius = 10f; // 怪物移動的最大半徑範圍
    public float minWaitTime = 2f; // 最小等待時間
    public float maxWaitTime = 5f; // 最大等待時間
    public float transitionSpeed = 1f; // 漸變速度
    public Animator animator; // Animator組件

    private NavMeshAgent agent;
    private float waitTime;
    private float timer;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        SetNewDestinationAndWaitTime();
        timer = 1.0f; // 初始等待1秒
    }

    void Update()
    {
        timer += Time.deltaTime;

        if (timer >= waitTime)
        {
            SetNewDestinationAndWaitTime();
        }

        // 更新Animator參數
        UpdateMovementSpeed();
    }

    void SetNewDestinationAndWaitTime()
    {
        agent.SetDestination(RandomNavSphere(transform.position, moveRadius));

        waitTime = Random.Range(minWaitTime, maxWaitTime);
        timer = 0; // 重置計時器
    }

    void UpdateMovementSpeed()
    {
        float targetSpeed = (agent.remainingDistance > agent.stoppingDistance) ? 1.0f : 0.0f;
        float currentSpeed = animator.GetFloat("MonsterMoveSpeed");
        float newSpeed = Mathf.Lerp(currentSpeed, targetSpeed, transitionSpeed * Time.deltaTime);
        animator.SetFloat("MonsterMoveSpeed", newSpeed);
    }

    Vector3 RandomNavSphere(Vector3 origin, float distance)
    {
        Vector3 randomDirection = Random.insideUnitSphere * distance;
        randomDirection += origin;

        NavMeshHit navHit;
        NavMesh.SamplePosition(randomDirection, out navHit, distance, NavMesh.AllAreas);

        return navHit.position;
    }
}
