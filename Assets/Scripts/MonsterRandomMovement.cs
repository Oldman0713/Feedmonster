using UnityEngine;
using UnityEngine.AI;

public class MonsterRandomMovement : MonoBehaviour
{
    public float moveRadius = 10f; // 怪物移動的最大半徑範圍
    public float minWaitTime = 2f; // 最小等待時間
    public float maxWaitTime = 5f; // 最大等待時間
    public Animator animator; // Animator組件

    private NavMeshAgent agent;
    private float waitTime;
    private float timer;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
        SetNewWaitTime(); // 設定新的等待時間
    }

    void Update()
    {
        timer += Time.deltaTime;

        if (timer >= waitTime)
        {
            MoveToNewRandomPosition();
        }

        // 檢查是否正在移動
        if (!agent.pathPending && agent.remainingDistance < 0.5f)
        {
            if (animator != null)
            {
                animator.SetFloat("MonsterMoveSpeed", 0f); // 停止移動動畫
            }
            if (timer >= waitTime)
            {
                SetNewWaitTime(); // 再次設定新的等待時間
            }
        }
        else
        {
            if (animator != null)
            {
                animator.SetFloat("MonsterMoveSpeed", 1f); // 開始移動動畫
            }
        }
    }

    void MoveToNewRandomPosition()
    {
        Vector3 newDestination = RandomNavSphere(transform.position, moveRadius);
        agent.SetDestination(newDestination);

        timer = 0; // 重置計時器
    }

    void SetNewWaitTime()
    {
        waitTime = Random.Range(minWaitTime, maxWaitTime); // 在最小和最大時間間隨機選擇
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
