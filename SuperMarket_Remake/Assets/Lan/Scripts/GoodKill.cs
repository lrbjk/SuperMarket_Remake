using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoodKill : MonoBehaviour
{
    public Collider coll;
    public GameObject vfx;

    public void BeforeKill(){
        // coll.enabled = false;
        Instantiate(vfx, coll.transform.position, Quaternion.identity);
        coll.transform.GetChild(0).gameObject.SetActive(true);
    }

    public void Kill(){
        Destroy(gameObject);
    }
}
