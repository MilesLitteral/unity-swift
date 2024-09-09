#if !UNITY_EDITOR && UNITY_IOS
using System;
using System.Runtime.InteropServices;
#endif
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using System.Linq;
using System.Text;
using PimDeWitte.UnityMainThreadDispatcher;
using System.Collections.Generic;

//TODO: Xamarian support might make this conversion(NSArray<NSString> -> List<String>) trivial
//using Foundation;

/// <summary>
/// Script to handle canvas UI elements and communication with iOS plugin.
/// </summary>
public class CanvasScript : MonoBehaviour
{
    public Text MessageText = null;
    public Text HelloWorldText = null;
    public Text AddText = null;
    public Text ConcatText = null;
    public Image img = null;

    public RawImage raw;
    private float _update;
    private bool _called = false;
    public Texture2D texture2D;
    public string imagePath;

    void OnGUI()
    {
        GUI.Button(new Rect(20, 20, 100, 100), texture2D);
    }


#if UNITY_IOS && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern void cSendHelloWorldMessage();

    [DllImport("__Internal")]
    private static extern string cHelloWorld();

    [DllImport("__Internal")]
    private static extern int cAdd(int x, int y);

    [DllImport("__Internal")]
    private static extern string cConcatenate(string x, string y);
    
    [DllImport("__Internal")]
    private static extern string _GetImage();

    [DllImport("__Internal")]
    private static extern IntPtr _FetchGalleryImages();

    [DllImport("__Internal")]
    private static extern string[] _GetImagesRandom();

    [DllImport("__Internal")]
    private static extern string[] _GetImages(int numberOfImages);

    [DllImport("__Internal")]
    public static extern IntPtr ConvertNSArrayToCStringArray(IntPtr nsArray, out int count);

    [DllImport("__Internal")]
    public static extern void FreeCStringArray(IntPtr cArray, int count);

    
    public static string GetImage()
    {
        if (Application.platform != RuntimePlatform.OSXEditor)
        {
            return _GetImage();
        }
        else
        {
            return @"Hello";
        }
    }

         
    public static void GetImages()
    {
        if (Application.platform != RuntimePlatform.OSXEditor)
        {
            _FetchGalleryImages();
        }
    }

    private List<string> ConvertNSArrayToListString(object nsArray)
    {
        // Convert NSArray to List<string> assuming nsArray is a valid NSArray
        // Replace with appropriate conversion logic
        return nsArray as List<string> ?? new List<string>();
    }
#endif

    public static async void createIOSThread(){
            // Ensure this method is called on the main thread
            UnityMainThreadDispatcher.Instance().Enqueue(() => {
                var ns = await _FetchGalleryImages();
                List<string> images = ConvertNSArrayToListString(ns);
                Debug.Log($"Images: {images.Count}");

                if (images.Count > 0)
                {
                    // Decode base64 string to byte array
                    byte[] imageBytes = Convert.FromBase64String(images[0]);

                    texture2D = new Texture2D(2, 2); // Initialize with a placeholder size
                    texture2D.LoadImage(imageBytes); // Load image data into the texture
                    texture2D.Apply();

                     if (raw != null)
                        {
                            raw.texture = texture2D;
                            raw.SetNativeSize(); // Optionally set the size to match the image
                        }
                    // Use the texture (e.g., apply it to a material)
                    // GetComponent<Renderer>().material.mainTexture = texture2D;
                }
                else
                {
                    Debug.Log("No images found.");
                }
            });
    }

    /// <summary>
    /// Initializes the text values on Start.
    /// </summary>
    private async void Start()
    {
        InitializeTextValues();
        raw = GetComponent<RawImage>();
#if UNITY_IOS && !UNITY_EDITOR
        cSendHelloWorldMessage();
        await createIOSThread();
#endif
    }

    /// <summary>
    /// Updates the timer and calls the iOS plugin function "cSendHelloWorldMessage" after a 5s.
    /// </summary>
    private void Update()
    {
        _update += Time.deltaTime;
        if (_update > 5.0f && !_called)
        {
            _update = 0.0f;
            _called = true;

#if UNITY_IOS && !UNITY_EDITOR
            cSendHelloWorldMessage();
#endif
        }
    }

    /// <summary>
    /// Called when a message is received from the iOS plugin by calling the "swiftSendHelloWorldMessage" method.
    /// </summary>
    /// <param name="message">The received message.</param>
    private void OnMessageReceived(string message)
    {
        MessageText.text = message;
    }

    /// <summary>
    /// Initializes the text values form the Canvas.
    /// </summary>
    private void InitializeTextValues()
    {
        if (MessageText == null || HelloWorldText == null || AddText == null || ConcatText == null)
        {
            Debug.LogError("One or more Text elements are not assigned in the inspector.");
            return;
        }

#if UNITY_IOS && !UNITY_EDITOR
        MessageText.text = "Waiting for message from iOS...";
        HelloWorldText.text = cHelloWorld();
        AddText.text = cAdd(1, 2).ToString();
        ConcatText.text = cConcatenate("Hello, ", "World!");
#else
        MessageText.text = "Only works on iOS.";
        HelloWorldText.text = "Only works on iOS.";
        AddText.text = "Only works on iOS.";
        ConcatText.text = "Only works on iOS.";
#endif
    }
}
