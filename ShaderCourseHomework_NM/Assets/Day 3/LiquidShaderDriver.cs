using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[ExecuteInEditMode]
public class LiquidShaderDriver : MonoBehaviour
{
    public Material upperMat;
    public Material downMat;
    [Range(-2.5f, 0.0f)]
    public float upperLiquidAmount = 0.0f;
    [Range(0.0f, 2.5f)]
    public float downLiquidAmount = -0.1f;

    // Update is called once per frame
    void Update()
    {
        // Simple and fast code for starting "pour" the sand
        if(Input.GetKeyUp("space"))
        {
            upperLiquidAmount-= 0.1f;
            // Make amount of liquid in down part bigger, if it is smaller in upper part
            if (upperLiquidAmount < downLiquidAmount)
            {
                downLiquidAmount += 0.1f;
            }
            else if (upperLiquidAmount == -2.5f)
            {
                downLiquidAmount -= 0.1f;
            }
        }
        // Limitations of liquid amount
        if(upperLiquidAmount < -2.5f)
        {
            upperLiquidAmount = -2.6f;
        }
        if(downLiquidAmount > 2.5f)
        {
            downLiquidAmount = 2.6f;
        }
        // Transfer information to shader
        upperMat.SetFloat("_LiquidAmount", upperLiquidAmount);
        downMat.SetFloat("_LiquidAmount", downLiquidAmount);
    }
}
