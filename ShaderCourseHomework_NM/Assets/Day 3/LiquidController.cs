using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LiquidController : MonoBehaviour
{
    public Material mat;
    public float liquidAmount = 0;

    // Update is called once per frame
    void Update()
    {
        mat.SetFloat("_LiquidAmount", liquidAmount);
        //mat.SetVector("_LiquidLevelNormal")
    }
}
