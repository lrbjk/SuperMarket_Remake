using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelfKill : MonoBehaviour
{
    void Start()
    {
        Invoke("Kill", 2f);
    }

    public void Kill(){
        Destroy(gameObject);
    }
}
