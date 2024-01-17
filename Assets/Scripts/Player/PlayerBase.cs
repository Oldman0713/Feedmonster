using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerBase : MonoBehaviour
{

    public AniController aniController;
    public MoveBase moveBase;
    public GameObject bullet;

    private float dt = 0;

    private Vector3 nDir;

    [SerializeField]
    private Transform attackParent;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        UpdateMove();
        UpdateAttack();
    }

    private void UpdateMove()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit))
        {
            nDir = (hit.point - transform.position);
            nDir.y = 0;
        }
        Quaternion lookAtRot = Quaternion.LookRotation(nDir);
        this.transform.rotation = lookAtRot;

        if (moveBase.moveData.moveDirection.magnitude == 0)
        {
            aniController.PlayMoveAnim(Vector3.zero);
        }
        else
        {
            var angle = Vector3.SignedAngle(nDir.normalized, moveBase.moveData.moveDirection, new Vector3(0, 1, 0));

            Vector3 fixDir = Quaternion.Euler(new Vector3(0, angle, 0)) * new Vector3(0, 0, -1);

            aniController.PlayMoveAnim(fixDir);
        }
    }
    private void UpdateAttack()
    {
        dt += Time.deltaTime;
        if (dt > 2f)
        {
            aniController.PlayAttackAnim(moveBase.moveData.moveDirection, "Attack_1");
            InstanceBullet();
            dt = -2f;
        }
    }
    void InstanceBullet()
    {
        var tempBullet = Instantiate(bullet, transform.position, Quaternion.LookRotation(transform.forward), attackParent);
    }
}
