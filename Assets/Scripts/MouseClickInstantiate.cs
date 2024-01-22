using UnityEngine;

public class MouseClickInstantiate : MonoBehaviour
{
    public GameObject objectToInstantiate; // ���w�n��Ҥƪ�GameObject
    public LayerMask layerMask; // �Ω󭭨�Raycast�i�H�I�����h

    void Update()
    {
        if (Input.GetMouseButtonDown(0)) // �ˬd�O�_���U�F�ƹ�����
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
