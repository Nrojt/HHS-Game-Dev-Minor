# Shader Design Document
_Effects and Shaders Platinum 1_

## 1. Short Description

This Godot `canvas_item` shader applies a retro visual filter on top of the rendered content. 
It tries to simulate an older horror look, by combining pixelation, color reduction to a limited palette, and dithering. 
The shader also includes options for scaling, which we most likely wont end up using.

## 2. Use Case

- Within Fowl Play, this shader is applied to visual layer 1, and thus applies to most game objects. This means UI is excempt from the shader, which keeps it crisp and clear.
	- Items which should not be affected, in our case 3DLabels, can be put on another layer and thus also be excempt
- Since the shader is customizable, multiple `levels` of it have been implemented in Fowl Play. I designed the shader for `level 2`, which is different than what is showed here.
	- The `showcase_video` folder contains video's and screenshots of the shader in action with various settings.

### 2a Reasoning

Although the execution of our game is quite lighthearthed, the concept is quite grim. This is by design, since we wanted to create a juxteposition between the cartoonish characters in a grim and dark world.
Horror games like `MouthWashing` have visually been an inspiration for our game since day one. These games often employ lowpoly, imperfect aesthetics, including pixelation and limited color palettes, not just as a stylistic choice, but to evoke a sense of unease, distortion, and sometimes, to mask or obscure disturbing details. This shader serves a similar purpose in Fowl Play.

## 3. Why it Works the Way it Works

The shader's effect is achieved through a combination of steps in the fragment shader:

*   **Pixelation:** Samples from the `SCREEN_TEXTURE` are snapped to a grid defined by the `pixel_size` uniform. Instead of sampling at every individual fragment coordinate (`FRAGCOORD`), it effectively samples the *center* of larger blocks of pixels, creating a pixelation effect.  	
*   **Color Reduction:** The `reduce_color` reduces color on each color channel independently. It divides the full range of each color channel (0.0 to 1.0) into a limited number of steps, based on the `colors` uniform. Each raw color value is then mapped to the nearest available color step. This reduces the number of unique colors present in the image.  
*   **Dithering:** Creating banding using a 4x4 Bayer matrix.
	*   The `dithering_pattern` function generates a deterministic pattern of threshold values based on the fragment coordinates.
	*   In the `reduce_color` function, this pattern value is used as a threshold. For each pixel, the raw color value is compared against the reduces color steps plus the dither threshold. This comparison influences whether the color snaps down to the lower step or up to the next higher step.
	*   The threshold varies across the screen, due to the Bayer matrix. This variation causes neighboring pixels with similar raw color values to be quantized to different colors in the palette, creating a visual pattern of dots that give the *impression* of intermediate colors that are not actually present in the palette.
	*   The `dither_size` uniform allows controlling the scale of this dithering pattern.
	*   `dither_shift` and `dither_hue_shift` add further control by shifting the dithering pattern across color channels and rotating the hue of the dither effect, respectively.
*   **Scaling and Border Mask:** The `scale` uniform modifies the UV coordinates used to sample the `SCREEN_TEXTURE`, effectively zooming in or out. The `border_mask` uniform, in combination with the original `UV` coordinates, creates a mask that is stronger near the edges of the screen, creating a vignette-like effect.

### 3a YIQ
YIQ is a way of representing colors that separates how bright a color is (luminance) from the actual color information (chrominance). The “Y” stands for brightness, while “I” and “Q” describe the color’s tint and shade. This makes it easier to adjust things like hue or brightness separately. Due to float inprecission, slight color changes will happen even if the hue shift is set to 0. Since the shader already 'destroys' the image, that is not an issue for our use case, but still something to note.
