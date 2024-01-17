using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Game : MonoBehaviour
{
    private static Game instance;
    public static Game GetInstance()
    {
        return instance;
    }
    [SerializeField]
    private Transform targetTransform;
    [SerializeField]
    private GameObject[] monsters;

    [SerializeField]
    private int deltaTime = 10;

    [SerializeField]
    private int count = 5;

    private int currentCount = 0;

    [SerializeField]
    private int max = 100;

    private float dt = 0;

    [SerializeField]
    private Transform parentTransform;

    private List<GameObject> enemyList = new List<GameObject>();

    public GameObject[] GetEnemyList()
    {
        return enemyList.ToArray();
    }
    // Start is called before the first frame update
    void Start()
    {
        Game.instance = this;
    }

    // Update is called once per frame
    void Update()
    {
        dt += Time.deltaTime;
        if (dt > 1f)
        {
            InstanceMonster();
            dt = -1f;
        }
        CleanDieEnemy();
    }

    void InstanceMonster()
    {
        if (currentCount > max)
        {
            return;
        }
        for (int i = 0; i < count; i++)
        {
            if (currentCount < max)
            {
                GameObject enemy = Instantiate(monsters[0], GetNextPos(), Quaternion.identity, parentTransform);
                enemyList.Add(enemy);
                currentCount += 1;
            }
        }
    }

    void CleanDieEnemy()
    {
        var dieEnemyList = enemyList.FindAll((a) =>
        {
            return a.GetComponent<AIBase>().aiData.hp <= 0;
        });
        enemyList = enemyList.FindAll((a) =>
        {
            return a.GetComponent<AIBase>().aiData.hp > 0;
        });
        foreach(var a in dieEnemyList){
            Destroy(a.gameObject);
        }
        currentCount = enemyList.Count;
    }


    Vector3 GetNextPos()
    {
        int posX = Random.Range(10, 20);
        bool positiveX = Random.Range(0, 2) == 1;
        if (!positiveX)
        {
            posX = -posX;
        }

        int posY = Random.Range(10, 20);
        bool positiveY = Random.Range(0, 2) == 1;
        if (!positiveY)
        {
            posY = -posY;
        }

        Vector3 pos = new Vector3(targetTransform.position.x + posX, targetTransform.position.y, targetTransform.position.z + posY);
        return pos;
    }
}
