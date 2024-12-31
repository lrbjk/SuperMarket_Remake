using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class NeedItemUI : MonoBehaviour
{
    public Image[] images;

    public Sprite[] sprites;

    public void updateNIU(int[] ints){
        for(int i=0; i<ints.Length; i++){
            images[i].gameObject.SetActive(true);
            images[i].sprite = sprites[ints[i]];
        }
    }

    public void changeColor(int index){
        images[index].color = new Color(0.0147f, 0.9882f, 0.6431f, 1);
    }
}
