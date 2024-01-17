using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AIBase : MonoBehaviour
{
    [SerializeField]
    private Transform target;

    [SerializeField]
    Rigidbody rig;

    public AIData aiData;

    private float deltaTime;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        deltaTime += Time.deltaTime;
        float distance = Vector3.Distance(transform.position, target.position);

        rig.position = rig.position + (target.position - transform.position).normalized * aiData.speed * Time.deltaTime;
    }
}
