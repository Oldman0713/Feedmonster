using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AniController : MonoBehaviour
{
    public Animator animator;

    // Start is called before the first frame update
    public void PlayMoveAnim(Vector3 dir)
    {
        if (dir.x != 0 || dir.z != 0)
        {
            animator.SetBool("move", true);
            animator.SetFloat("moveX", -dir.x);
            animator.SetFloat("moveY", -dir.z);
        }
        else
        {
            animator.SetBool("move", false);
        }
    }
    public void PlayAttackAnim(Vector3 dir, string anim)
    {
        if (dir.x == 0 && dir.z == 0)
        {
            animator.Play(anim, 2);
        }
        else
        {
            animator.Play(anim, 1);
        }
    }
}
