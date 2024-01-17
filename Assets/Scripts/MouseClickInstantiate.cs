using UnityEngine;

public class MouseClickInstantiate : MonoBehaviour
{
    public GameObject objectToInstantiate; // 指定要實例化的GameObject
    public LayerMask layerMask; // 用於限制Raycast可以碰撞的層

    void Update()
    {
        if (Input.GetMouseButtonDown(0)) // 檢查是否按下了滑鼠左鍵
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit, Mathf.Infinity, layerMask))
            {
                Instantiate(objectToInstantiate, hit.point, Quaternion.identity);
            }
        }
    }
}
