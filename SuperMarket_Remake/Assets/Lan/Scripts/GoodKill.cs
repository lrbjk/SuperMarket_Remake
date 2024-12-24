using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoodKill : MonoBehaviour
{
    public Collider coll;

    public void BeforeKill(){
        coll.enabled = false;
        coll.transform.GetChild(0).gameObject.SetActive(true);
    }

    public void Kill(){
        Destroy(gameObject);
    }
}
