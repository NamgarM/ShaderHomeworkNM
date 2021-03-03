using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[ExecuteInEditMode]
public class LiquidShaderDriver : MonoBehaviour
{
    public Material upperMat;
    public Material downMat;
    public float upperLiquidAmount = 0;
    public float downLiquidAmount = 0;

    // Update is called once per frame
    void Update()
    { 
        upperMat.SetFloat("_LiquidAmount", upperLiquidAmount);
        downMat.SetFloat("_LiquidAmount", downLiquidAmount);
    }
}
