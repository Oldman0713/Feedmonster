using UnityEngine;
using System.Collections.Generic;
using MyGameNamespace;

public class FieldOfView : MonoBehaviour
{
    public float viewRadius;
    [Range(0, 360)]
    public float viewAngle;

    public LayerMask targetMask;
    public LayerMask obstacleMask;

    // 在Unity编辑器中将Food ScriptableObject分配给这个字段
    public Food foodScriptableObject;

    private HashSet<Transform> detectedTargets = new HashSet<Transform>();

    // 委托和事件，用于通知发现食物
    public delegate void OnFoodDetected(Food food);
    public event OnFoodDetected onFoodDetected;

    void FindVisibleTargets()
    {
        detectedTargets.Clear();  // 清除上一次检测的目标
        Collider[] targetsInViewRadius = Physics.OverlapSphere(transform.position, viewRadius, targetMask);

        for (int i = 0; i < targetsInViewRadius.Length; i++)
        {
            Transform target = targetsInViewRadius[i].transform;
            Vector3 dirToTarget = (target.position - transform.position).normalized;

            if (Vector3.Angle(transform.forward, dirToTarget) < viewAngle / 2)
            {
                float dstToTarget = Vector3.Distance(transform.position, target.position);

                if (!Physics.Raycast(transform.position, dirToTarget, dstToTarget, obstacleMask))
                {
                    if (detectedTargets.Add(target)) // 如果目标尚未被检测过，则添加到集合并显示一次
                    {
                        // 使用分配给字段的ScriptableObject
                        onFoodDetected?.Invoke(foodScriptableObject);
                    }
                }
            }
        }
    }

    void Update()
    {
        FindVisibleTargets();
    }
}
