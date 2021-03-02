using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System;

public class ObjOutline : MonoBehaviour
{
    public Renderer OutlinedObj;
    public Material WriteObj;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Settings (texture)
        var commands = new CommandBuffer();
        int objBuffer = Shader.PropertyToID("_SelectionBuffer");
        commands.GetTemporaryRT(objBuffer, source.descriptor);

        // render buffer for selection
        commands.SetRenderTarget(objBuffer);
        commands.ClearRenderTarget(true, true, Color.clear);
        if (OutlinedObj != null)
        {
            commands.DrawRenderer(OutlinedObj, WriteObj);
        }
        // apply it and clean buffer
        commands.Blit(objBuffer, destination);
        commands.ReleaseTemporaryRT(objBuffer);
        // execute
        Graphics.ExecuteCommandBuffer(commands);
        // clean
        commands.Dispose();
    }
}
