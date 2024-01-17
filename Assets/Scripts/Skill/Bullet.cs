using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public int attack = 5;
    public float speed = 5;
    public float distance = 5;

    private Vector3 startPos;
    // Start is called before the first frame update
    void Start()
    {
        Quaternion zero = Quaternion.identity;
        transform.GetPositionAndRotation(out startPos, out zero);
    }

    // Update is called once per frame
    void Update()
    {
        bool isOverDistance = IsOverDistance();
        if (isOverDistance)
        {
            Destroy(gameObject);
            return;
        }
        transform.position = transform.position + transform.forward.normalized * speed * Time.deltaTime;
        Attack();
    }

    void Attack()
    {
        var enemies = GetEnemy();
        for (int i = 0; i < enemies.Length; i++)
        {
            var distance = Vector3.Distance(enemies[i].transform.position, transform.position);
            if (distance < 1)
            {
                AIBase ai = enemies[i].GetComponent<AIBase>();
                ai.aiData.hp -= attack;
            }
        }
    }

    bool IsOverDistance()
    {
        float tempDistance = Vector3.Distance(startPos, transform.position);
        if (tempDistance >= distance)
        {
            return true;
        }
        return false;
    }

    GameObject[] GetEnemy()
    {
        return Game.GetInstance().GetEnemyList();
    }
}
