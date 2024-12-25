using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class NeedItemUI : MonoBehaviour
{
    public Image[] images;

    public Sprite[] sprites;

    void Start()
    {
        if(sprites.Length < 3){
            if(sprites.Length == 1){
                images[1].gameObject.SetActive(false);
            }
            images[2].gameObject.SetActive(false);
        }
        for(int i=0; i<sprites.Length; i++){
            images[i].sprite = sprites[i];
        }
    }

    public void changeColor(int index){
        images[index].color = new Color(0.0147f, 0.9882f, 0.6431f, 1);
    }
}
