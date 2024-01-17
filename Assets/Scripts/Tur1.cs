using UnityEngine;

public class Tur1 : MonoBehaviour
{
    public Animator Anim;

    public void Attack()
    {
        Debug.Log("Attack");
        Anim.SetTrigger("Base Layer_Attack");
    }

    public void Jump() 
    {
        Debug.Log("Jump");
    }

    public void Walk()
    {
        Debug.Log("Walk");
        
    }
}
