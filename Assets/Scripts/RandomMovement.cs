using UnityEngine;

public class RandomMovement : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float rotationSpeed = 50f; // 新增旋轉速度變量
    public GameObject boundaryModel;
    public float minWaitTime = 0f;
    public float maxWaitTime = 5f;

    private Vector3 targetPosition;
    private float waitTime;
    private float timer;

    private void Start()
    {
        SetNewTargetPosition();
        waitTime = Random.Range(minWaitTime, maxWaitTime);
    }

    private void Update()
    {
        timer += Time.deltaTime;

        if (timer >= waitTime)
        {
            MoveTowardsTarget();
        }
    }

    void SetNewTargetPosition()
    {
        Bounds bounds = boundaryModel.GetComponent<Renderer>().bounds;
        targetPosition = new Vector3(
            Random.Range(bounds.min.x, bounds.max.x),
            0,
            Random.Range(bounds.min.z, bounds.max.z)
        );

        timer = 0;
        waitTime = Random.Range(minWaitTime, maxWaitTime);
    }

    void MoveTowardsTarget()
    {
        transform.position = Vector3.MoveTowards(transform.position, targetPosition, moveSpeed * Time.deltaTime);

        // 更新角色的旋轉使其面向目標位置
        Vector3 targetDirection = targetPosition - transform.position;
        if (targetDirection != Vector3.zero)
        {
            targetDirection.y = 0;
            Quaternion targetRotation = Quaternion.LookRotation(targetDirection);
            // 使用 rotationSpeed 變量作為旋轉速率參數
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }

        if (Vector3.Distance(transform.position, targetPosition) < 0.1f)
        {
            SetNewTargetPosition();
        }
    }
}
