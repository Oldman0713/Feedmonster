using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public Transform target;
    public float minDistance = 2.0f; // �̤p�Z��
    public float maxDistance = 10.0f; // �̤j�Z��
    public float heightRatio = 0.5f; // ���פ��
    public float horizontalSpeed = 2.0f; // ��������t��
    public float zoomSpeed = 2.0f; // �Y��t��

    private float currentAngle = 0.0f;
    private float currentDistance;

    private void Start()
    {
        currentDistance = (minDistance + maxDistance) / 2;

        SetInitialCameraPosition();// 初始位置和朝向設置

    }

private void SetInitialCameraPosition()
{
    float heightAdjustment = heightRatio * currentDistance;
    Vector3 direction = new Vector3(0, heightAdjustment, -currentDistance);
    Quaternion rotation = Quaternion.Euler(0, currentAngle, 0);
    transform.position = target.position + rotation * direction;

    Vector3 lookDirection = target.position - transform.position;
    transform.rotation = Quaternion.LookRotation(lookDirection);
}

    private void Update()
    {
        currentDistance -= Input.GetAxis("Mouse ScrollWheel") * zoomSpeed;
        currentDistance = Mathf.Clamp(currentDistance, minDistance, maxDistance);

        if (Input.GetMouseButton(1))
        {
            currentAngle += Input.GetAxis("Mouse X") * horizontalSpeed;
        }

        float heightAdjustment = heightRatio * currentDistance;
        Vector3 direction = new Vector3(0, heightAdjustment, -currentDistance);
        Quaternion rotation = Quaternion.Euler(0, currentAngle, 0);
        transform.position = target.position + rotation * direction;

        Vector3 lookDirection = target.position - transform.position;
        transform.rotation = Quaternion.LookRotation(lookDirection);
    }
}
