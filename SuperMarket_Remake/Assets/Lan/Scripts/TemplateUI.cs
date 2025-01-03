using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

// This script is written for the UI designer to make his part,
// normally, it will not be used in the final project.
public class TemplateUI : MonoBehaviour
{
    public Text current;
    public Text last;

    void Start()
    {
        current.text = "Current Customer: ";
        last.text = "Last Customer: ";
    }

    void Update(){
        current.text = "Current Customer: " + CustomerNeed.currentNeed;
        last.text = "Last Customer: " + CustomerNeed.lastNeed;
    }
}
