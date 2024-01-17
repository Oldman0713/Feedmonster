using UnityEngine;

public class CameraFollow : MonoBehaviour
{
    public Transform target;
    public float minDistance = 2.0f; // 最小距離
    public float maxDistance = 10.0f; // 最大距離
    public float heightRatio = 0.5f; // 高度比例
    public float horizontalSpeed = 2.0f; // 水平旋轉速度
    public float zoomSpeed = 2.0f; // 縮放速度

    private float currentAngle = 0.0f;
    private float currentDistance;

    private void Start()
    {
        currentDistance = (minDistance + maxDistance) / 2;
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
