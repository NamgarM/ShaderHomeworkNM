using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessing_NM : MonoBehaviour
{
    [SerializeField]
    private Material postprocessingMat;
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, postprocessingMat);
    }
}
