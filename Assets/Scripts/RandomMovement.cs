using UnityEngine;

public class RandomMovement : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float rotationSpeed = 50f; // �s�W����t���ܶq
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

        // ��s���⪺����Ϩ䭱�V�ؼЦ�m
        Vector3 targetDirection = targetPosition - transform.position;
        if (targetDirection != Vector3.zero)
        {
            targetDirection.y = 0;
            Quaternion targetRotation = Quaternion.LookRotation(targetDirection);
            // �ϥ� rotationSpeed �ܶq�@������t�v�Ѽ�
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
        }

        if (Vector3.Distance(transform.position, targetPosition) < 0.1f)
        {
            SetNewTargetPosition();
        }
    }
}
