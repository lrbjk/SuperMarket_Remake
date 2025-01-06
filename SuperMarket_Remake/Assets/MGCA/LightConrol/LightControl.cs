using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LightControl : MonoBehaviour
{
    public Light directionalLight;
    public float dayAngle = 70f;
    public float nightAngle = 150f;
    public float dayChangeSpeed = 10f;
    public float nightChangeSpeed = 50f;
    private float rotationAngle;
    public int currentDate;
    private bool isNextDateTriggered;
    
    public Text dateText;
    public GameObject changeDateButton;

    void Start()
    {
        currentDate = 0;
        rotationAngle = dayAngle + 0.01f;
        changeDateButton.SetActive(false);
        dateText.CrossFadeAlpha(0f, 0f, false);
        dateText.gameObject.SetActive(false);
    }
    
    void Update()
    {
        changeDate();
    }

    public void changeDate()
    {
        
        if (rotationAngle < nightAngle && rotationAngle > dayAngle)
        {
            isNextDateTriggered = false;
            changeDay(dayChangeSpeed);
            Debug.Log("Day: "+rotationAngle);
        }
        else if(isNextDateTriggered)
        {
            Debug.Log("Night: "+rotationAngle);
            rotationAngle = Mathf.Repeat(rotationAngle, 360f);
            changeDay(nightChangeSpeed);
            if (!dateText.gameObject.activeInHierarchy)
            {
                dateText.gameObject.SetActive(true);
            } 
            StartCoroutine(ProcessUI());
        }
        else
        {
            changeDateButton.SetActive(true);
        }
    }

    public void changeDay(float speed)
    {
        rotationAngle += speed * Time.deltaTime;
        Vector3 lightDirection = Quaternion.AngleAxis(rotationAngle, Vector3.forward) * new Vector3(-1,0,0);
        directionalLight.transform.forward = lightDirection;
    }

    IEnumerator ProcessUI()
    {
        // 执行FadeIn协程
        yield return StartCoroutine(FadeIn(1.5f));
 
        // 等待2秒
        yield return new WaitForSeconds(2f);
 
        // 执行FadeOut协程
        yield return StartCoroutine(FadeOut(1.5f));
        
        dateText.gameObject.SetActive(false);
    }
    
    private System.Collections.IEnumerator FadeIn(float duration)
    {
        yield return new WaitForSeconds(1.0f); // 延迟1秒后开始淡入
        dateText.CrossFadeAlpha(1f, duration, true);
    }
 
    private System.Collections.IEnumerator FadeOut(float duration)
    {
        dateText.CrossFadeAlpha(0f, duration, true);
        yield return new WaitForSeconds(duration);
    }

    public  void OnClick()
    {
        isNextDateTriggered = true;
        currentDate += 1;
        dateText.text = "Day: " + currentDate;
        changeDateButton.SetActive(false);
    }

}