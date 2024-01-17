using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class MoveData
{
    public float speed = 5;
    public float upSpeed = 0;
    public float downSpeed = 0;
    public float leftSpeed = 0;
    public float rightSpeed = 0;
    public Vector3 moveDirection = new Vector3();
}

public class MoveBase : MonoBehaviour
{
    private KeyCode upKeyCode = KeyCode.W;
    private KeyCode downKeyCode = KeyCode.S;
    private KeyCode leftKeyCode = KeyCode.A;
    private KeyCode rightKeyCode = KeyCode.D;
    public MoveData moveData;
    // Start is called before the first frame update
    void Start()
    {
        moveData = new MoveData();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(upKeyCode))
        {
            moveData.upSpeed = 1;
        } else {
            moveData.upSpeed = 0;
        }
        if (Input.GetKey(downKeyCode))
        {
            moveData.downSpeed = 1;
        } else {
            moveData.downSpeed = 0;
        }
        if (Input.GetKey(rightKeyCode))
        {
            moveData.rightSpeed = 1;
        } else {
            moveData.rightSpeed = 0;
        }
        
        if (Input.GetKey(leftKeyCode))
        {
            moveData.leftSpeed = 1;
        } else {
            moveData.leftSpeed = 0;
        }
        moveData.moveDirection.x = moveData.rightSpeed - moveData.leftSpeed;
        moveData.moveDirection.z = moveData.upSpeed - moveData.downSpeed;
        transform.position = transform.position + (moveData.moveDirection.normalized * Time.deltaTime * moveData.speed);
    }
}
