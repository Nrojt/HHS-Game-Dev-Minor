# Shader Design Document: Pixelation and Dithering Effect

## 1. Short Description

This Godot `canvas_item` shader is designed to apply a retro visual filter on top of the rendered content. 
It tries to simulate an older horror look, by combining pixelation, color reduction to a limited palette, and dithering. 
The shader also includes options for scaling and a subtle border mask effect, which I played around with but most likely won't end up using.
In order to keep the dithering effect properly, keep the pixel size smaller.

## 2. Use Case

- Within Fowl Play, this shader is applied to visual layer 1, and thus applies to most game objects. This means UI is excempt from the shader, which keeps it crisp and clear.
	- Items which should not be affected, in our case 3DLabels, can be put on another layer and thus be excempt

### 2.a Why

Although the execution of our game is quite lighthearthed, the concept is quite grim. This is by design, since we wanted to create a juxteposition between the cartoonish characters in a grim and dark world.
Horror games like `MouthWashing` have visually been an inspiration for our game since day one. These games often employ lowpoly, imperfect aesthetics, including pixelation and limited color palettes, not just as a stylistic choice, but to evoke a sense of unease, distortion, and sometimes, to mask or obscure disturbing details. This shader serves a similar purpose in Fowl Play.

## 3. Why it Works the Way it Works

The shader achieves its effect through a combination of techniques applied in the fragment shader:

*   **Pixelation:** The shader achieves pixelation by sampling the `SCREEN_TEXTURE` at calculated coordinates that are snapped to a grid defined by the `pixel_size` uniform. Instead of sampling at every individual fragment coordinate (`FRAGCOORD`), it effectively samples the *center* of larger blocks of pixels, creating a pixelation effect.
*   **Color Reduction:** The `reduce_color` function performs color quantization on each color channel (red, green, and blue) independently. It divides the full range of each color channel (0.0 to 1.0) into a limited number of discrete steps based on the `colors` uniform. Each raw color value is then mapped to the nearest available color step in this limited palette. This dramatically reduces the number of unique colors present in the image.
*   **Ordered Dithering:** To mitigate the harsh banding that can result from simple color reduction, the shader employs ordered dithering using a 4x4 Bayer matrix.
    *   The `dithering_pattern` function generates a deterministic pattern of threshold values based on the fragment coordinates.
    *   In the `reduce_color` function, this pattern value is used as a threshold. For each pixel, the raw color value is compared against the quantized color steps plus the dither threshold. This comparison influences whether the color snaps down to the lower step or up to the next higher step.
    *   The key is that the threshold varies across the screen according to the Bayer matrix. This variation causes neighboring pixels with similar raw color values to be quantized to different colors in the limited palette, creating a visual pattern of dots that, when viewed from a distance, gives the *impression* of intermediate colors that are not actually present in the palette. This is a form of spatial averaging that tricks the eye.
    *   The `dither_size` uniform allows controlling the scale of this dithering pattern.
    *   `dither_shift` and `dither_hue_shift` add further artistic control by shifting the dithering pattern across color channels and rotating the hue of the dither effect, respectively.
*   **Scaling and Border Mask:** The `scale` uniform modifies the UV coordinates used to sample the `SCREEN_TEXTURE`, effectively zooming in or out. The `border_mask` uniform, in conjunction with the original `UV` coordinates, creates a mask that is stronger near the edges of the screen. This mask is added to the sampling UVs, subtly pulling the sampling towards the edges, which can contribute to a vignette-like effect or enhance the appearance of the border.
In summary, the shader works by manipulating the sampling of the screen content, reducing the available color information, and then using a patterned method (dithering) to simulate a wider range of colors within the limited palette.
