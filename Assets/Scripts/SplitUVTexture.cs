using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SplitUVTexture : MonoBehaviour
{
    public Texture2D SingleTexture;

    [Range(1,100)]
    public int SplitScreen;

    public Texture2D[] texes;
    
    private int _SingleTextureWidth;

    private int _SingleTextureHeight;
    
    // Start is called before the first frame update
    void Start()
    {
        _SingleTextureWidth = SingleTexture.width;
        _SingleTextureHeight = SingleTexture.height;
        texes = new Texture2D[SplitScreen];
        for (int i = 0; i < SplitScreen; i++)
        {
            texes[i] = new Texture2D(_SingleTextureWidth / SplitScreen, _SingleTextureHeight, TextureFormat.ARGB32,
                false);
            for (int w = 0; w < _SingleTextureWidth / SplitScreen; w++)
            {
                for (int h = 0; h < _SingleTextureHeight; h++)
                {
                    Color tmp = SingleTexture.GetPixel(_SingleTextureWidth / SplitScreen * i + w, h);
                    texes[i].SetPixel(w, h, tmp);
                }
            }
        }

        for (int i = 0; i < SplitScreen; i++)
        {
            byte[] bytes;
            bytes = texes[i].EncodeToPNG();
            string screenshotFileName =  "/splitImages/S_" + System.DateTime.Now.ToString("_yyyy-MM-dd-hh-mm-ss") + "_split"
                                        + i.ToString() + ".png";

            System.IO.File.WriteAllBytes(Application.dataPath + screenshotFileName, bytes);
            Debug.Log("PNG saved to " + Application.dataPath + screenshotFileName);
        }
    }

}
