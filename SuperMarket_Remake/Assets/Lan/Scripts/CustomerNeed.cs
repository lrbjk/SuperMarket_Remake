using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomerNeed : MonoBehaviour
{
    public static string currentNeed = "";

    public static string lastNeed = "";

    private static float chipPrice = 10f;

    private static float drinkPrice = 15f;

    private static float porridgePrice = 20f;

    public static float Calculate(ArrayList arrayList){
        float value = 0;
        for(int i=0; i<arrayList.Count; i++){
            switch(arrayList[i]){
                case "OHHHHChip": {value += chipPrice;}break;
                case "OHHHHDrink": {value += drinkPrice;}break;
                case "OHHHHPorridge": {value += porridgePrice;}break;
            }
        }
        return value;
    }
}
