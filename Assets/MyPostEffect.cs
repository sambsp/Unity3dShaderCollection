using UnityEngine;

[ExecuteInEditMode]

public class MyPostEffect : MonoBehaviour
{
    public Material myMaterial;

    [Header("Ä£ºý°ë¾¶")]
    [Range(0.2f, 10.0f)]
    public float BlurRadius = 1.0f;

    public int downSample = 2;

    public int iteration = 1;

    void Start()
    {
        
    }

    // Update is called once per frame
    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (myMaterial)
        {
            RenderTexture rt = RenderTexture.GetTemporary(sourceTexture.width >> downSample, sourceTexture.height >> downSample);

            Graphics.Blit(sourceTexture, rt);

            for (int i = 0; i < iteration; ++i)
            {
                myMaterial.SetFloat("_NeighbourDistance", BlurRadius);
                Graphics.Blit(rt, sourceTexture, myMaterial);
                Graphics.Blit(sourceTexture, rt, myMaterial);
            }

            Graphics.Blit(rt, destTexture);

            RenderTexture.ReleaseTemporary(rt);
        }
    }
}
