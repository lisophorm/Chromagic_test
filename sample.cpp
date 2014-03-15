// Type: Chromagic.ChromaKey
// Assembly: Chromagic, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: D1327A25-84F6-4C9B-9C83-DB89CBE28B11
// Assembly location: C:\Users\Alfonso\Downloads\sdk\sdk\sdk\DotNet\Chromagic.dll

using System;
using System.Drawing;
using System.Drawing.Imaging;

namespace Chromagic
{
  public class ChromaKey
  {
    public float Hue;
    public float Tolerance;
    public float Saturation;
    public float MinValue;
    public float MaxValue;

    public ChromaKey()
    {
      this.Hue = 120f;
      this.Tolerance = 45f;
      this.Saturation = 0.2f;
      this.MinValue = 0.35f;
      this.MaxValue = 0.95f;
    }

    private void RGB_to_HSV(float[] color, float[] hsv)
    {
      float num1 = 0.0f;
      float num2 = 0.0f;
      float val1 = color[0];
      float val2_1 = color[1];
      float val2_2 = color[2];
      float num3 = Math.Max(Math.Max(val1, val2_1), val2_2);
      float num4 = Math.Min(Math.Min(val1, val2_1), val2_2);
      float num5 = num3;
      if ((double) num3 != 0.0)
        num2 = (num3 - num4) / num3;
      if ((double) num2 != 0.0)
      {
        float num6 = num3 - num4;
        num1 = ((double) val1 != (double) num3 ? ((double) val2_1 != (double) num3 ? (float) (4.0 + ((double) val1 - (double) val2_1) / (double) num6) : (float) (2.0 + ((double) val2_2 - (double) val1) / (double) num6)) : (val2_1 - val2_2) / num6) * 60f;
        if ((double) num1 < 0.0)
          num1 += 360f;
      }
      hsv[0] = num1 / 360f;
      hsv[1] = num2;
      hsv[2] = num5;
      hsv[3] = color[3];
    }

    private void HSV_to_RGB(float[] hsv, float[] rgb)
    {
      float[] numArray = new float[4];
      numArray[0] = numArray[1] = numArray[2] = numArray[3] = 0.0f;
      float num1 = 0.0f;
      float num2 = 0.0f;
      float num3 = 0.0f;
      if ((double) hsv[1] == 0.0)
      {
        if ((double) hsv[2] != 0.0)
          numArray[0] = numArray[1] = numArray[2] = numArray[3] = hsv[2];
      }
      else
      {
        float num4 = hsv[0] * 360f;
        float num5 = hsv[1];
        float num6 = hsv[2];
        if ((double) num4 == 360.0)
          num4 = 0.0f;
        float num7 = num4 / 60f;
        float num8 = (float) (int) num7;
        float num9 = num7 - num8;
        float num10 = num6 * (1f - num5);
        float num11 = num6 * (float) (1.0 - (double) num5 * (double) num9);
        float num12 = num6 * (float) (1.0 - (double) num5 * (1.0 - (double) num9));
        if ((double) num8 < 0.00999999977648258)
        {
          num1 = num6;
          num2 = num12;
          num3 = num10;
        }
        else if ((double) num8 < 1.00999999046326)
        {
          num1 = num11;
          num2 = num6;
          num3 = num10;
        }
        else if ((double) num8 < 2.00999999046326)
        {
          num1 = num10;
          num2 = num6;
          num3 = num12;
        }
        else if ((double) num8 < 3.00999999046326)
        {
          num1 = num10;
          num2 = num11;
          num3 = num6;
        }
        else if ((double) num8 < 4.01000022888184)
        {
          num1 = num12;
          num2 = num10;
          num3 = num6;
        }
        else if ((double) num8 < 5.01000022888184)
        {
          num1 = num6;
          num2 = num10;
          num3 = num11;
        }
        numArray[0] = num1;
        numArray[1] = num2;
        numArray[2] = num3;
      }
      numArray[3] = hsv[3];
      rgb[0] = numArray[0];
      rgb[1] = numArray[1];
      rgb[2] = numArray[2];
      rgb[3] = numArray[3];
    }

    private unsafe bool Process(byte* data, int width, int height, int stride)
    {
      float[] numArray = new float[4];
      float[] hsv = new float[4];
      float num1 = this.Hue - this.Tolerance;
      float num2 = this.Hue + this.Tolerance;
      float num3 = this.Tolerance / 360f;
      float num4 = num1 / 360f;
      float num5 = num2 / 360f;
      float num6 = this.Saturation;
      for (int index1 = 0; index1 < height; ++index1)
      {
        byte* numPtr = data + ((IntPtr) index1 * stride).ToInt64();
        for (int index2 = 0; index2 < width; ++index2)
        {
          numArray[2] = (float) numPtr[((IntPtr) index2 * 4).ToInt64()] / (float) byte.MaxValue;
          numArray[1] = (float) (numPtr + ((IntPtr) index2 * 4).ToInt64())[1] / (float) byte.MaxValue;
          numArray[0] = (float) (numPtr + ((IntPtr) index2 * 4).ToInt64())[2] / (float) byte.MaxValue;
          numArray[3] = (float) (numPtr + ((IntPtr) index2 * 4).ToInt64())[3] / (float) byte.MaxValue;
          this.RGB_to_HSV(numArray, hsv);
          if ((double) hsv[0] >= (double) num4 && (double) hsv[0] <= (double) num5)
          {
            if ((double) hsv[1] >= (double) num6)
            {
              if ((double) hsv[2] >= (double) this.MinValue && (double) hsv[2] <= (double) this.MaxValue)
              {
                hsv[3] = 0.0f;
                hsv[1] = 0.0f;
                this.HSV_to_RGB(hsv, numArray);
              }
              else if ((double) hsv[2] < (double) this.MinValue)
              {
                hsv[3] = Math.Min(1f, (float) ((double) this.MinValue + 1.0 - (double) hsv[2] / (double) this.MinValue));
                hsv[1] = 0.0f;
                hsv[2] = 0.0f;
                this.HSV_to_RGB(hsv, numArray);
              }
              else if ((double) hsv[2] > (double) this.MaxValue)
              {
                hsv[3] = Math.Min(1f, (float) (((double) hsv[2] - (double) this.MaxValue) / (1.0 - (double) this.MaxValue)));
                hsv[1] = 0.0f;
                hsv[2] = 1f;
                this.HSV_to_RGB(hsv, numArray);
              }
            }
            else
            {
              hsv[3] = 1f;
              hsv[1] = 0.0f;
              this.HSV_to_RGB(hsv, numArray);
            }
            numPtr[((IntPtr) index2 * 4).ToInt64()] = (byte) ((double) numArray[2] * (double) byte.MaxValue);
            (numPtr + ((IntPtr) index2 * 4).ToInt64())[1] = (byte) ((double) numArray[1] * (double) byte.MaxValue);
            (numPtr + ((IntPtr) index2 * 4).ToInt64())[2] = (byte) ((double) numArray[0] * (double) byte.MaxValue);
            (numPtr + ((IntPtr) index2 * 4).ToInt64())[3] = (byte) ((double) numArray[3] * (double) byte.MaxValue);
          }
        }
      }
      return true;
    }

    public unsafe bool Chroma(Bitmap bitmap)
    {
      if (bitmap.PixelFormat != PixelFormat.Format32bppArgb)
        return false;
      BitmapData bitmapdata = bitmap.LockBits(new Rectangle(0, 0, bitmap.Width, bitmap.Height), ImageLockMode.ReadWrite, bitmap.PixelFormat);
      this.Process((byte*) (void*) bitmapdata.Scan0, bitmapdata.Width, bitmapdata.Height, bitmapdata.Stride);
      bitmap.UnlockBits(bitmapdata);
      return true;
    }
  }
}
