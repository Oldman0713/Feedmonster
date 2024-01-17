using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[RequireComponent(typeof(CharacterController))]
public class PlayerController : MonoBehaviour
{
    Camera mainCamera;
    [SerializeField] Vector2 moveDirection = Vector2.zero;
    public Vector2 MoveDirection { get { return moveDirection;  }set { moveDirection = value; } }
    
    CharacterController controller;

    [SerializeField] Animator animator;
    [Space(10)]
    [Header("Set Dir to Animator Parameter")]
    [Space(5)]
    public string dirXName = "DirX";
    public string dirYName = "DirY";

    private void OnEnable()
    {
        mainCamera = Camera.main;
        controller = GetComponent<CharacterController>();
    }
    void Start()
    {
        
    }

    void Update()
    {
        if (!mainCamera) return;
        //moveDirection = moveDirection.normalized;
        Vector3 cameraForward = mainCamera.transform.forward;
        cameraForward.y = 0;
        Matrix4x4 moveMatrix = Matrix4x4.identity;
        moveMatrix.SetColumn(2, cameraForward);
        moveMatrix.SetColumn(0, Vector3.Cross(Vector3.up, cameraForward));
        moveMatrix.SetColumn(1, Vector3.Cross(cameraForward, moveMatrix.GetColumn(0)));

        Vector3 trueMove = moveMatrix * new Vector3(moveDirection.x, 0.0f, moveDirection.y);
        transform.forward = Vector3.Slerp(transform.forward, trueMove, Time.deltaTime * 3.0f);
        if (animator)
        {
            animator.SetFloat(dirXName, trueMove.x);
            animator.SetFloat(dirYName, trueMove.z);
        }
        controller.Move(trueMove * Time.deltaTime * 5.0f);
    }
}
