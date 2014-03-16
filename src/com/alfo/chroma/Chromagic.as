package com.alfo.chroma
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class Chromagic
	{
		public var  Hue:Number;
		public var  Tolerance:Number;
		public var  Saturation:Number;
		public var  MinValue:Number;
		public var  MaxValue:Number;
		

		private var dataBytes:Vector.<uint>;
		private var destDataBytes:ByteArray;
		
		private var picPos:uint = 0;
		
		public function Chromagic()
		{
			this.Hue = 120;
			this.Tolerance = 45;
			this.Saturation = 0.2;
			this.MinValue = 0.35;
			this.MaxValue = 0.95;
		}
		
		public function chroma(width:Number,height:Number,rgba:BitmapData):void {
			//process(width, height, rgba);	
		}
		public function HSV_to_RGB(hsv : Vector.<Number> ):Vector.<Number>
		{
			var color : Vector.<Number> = new <Number>[0, 0, 0, 0];
			var rgb : Vector.<Number> = new <Number>[0, 0, 0, 0];
			//float color[4] = {0.0f, 0.0f, 0.0f, 0.0f};
			var f:Number,p:Number,q:Number,t:Number;
			var h:Number,s:Number,v:Number;
			var r:Number=0,g:Number=0,b:Number=0;
			var i:Number;
			
			if(hsv[1] == 0)
			{
				if(hsv[2] != 0)
				{
					color[0] = color[1] = color[2] = color[3] = hsv[2];
				}
			}
			else
			{
				h =	hsv[0] * 360.0;
				s =	hsv[1];
				v =	hsv[2];
				
				if (h == 360.0)
				{
					h=0;
				}
				
				h /= 60.0;
				
				// original
				
				i=Math.floor(h); //(float)((int)h);
				
				f =	h - i;
				
				p =	v *	(1.0 - s); 
				q =	v *	(1.0 - (s *	f));
				t =	v *	(1.0 - (s *	(1.0 -f)));
				if(i < 0.01)
				{
					r =	v;
					g =	t;
					b =	p;
				}
				else if(i < 1.01)
				{
					r =	q;
					g =	v;
					b =	p;
				}
				else if(i < 2.01)
				{
					r =	p;
					g =	v;
					b =	t;
				}
				else if(i < 3.01)
				{
					r =	p;
					g =	q;
					b =	v;
				}
				else if(i < 4.01)
				{
					r =	t;
					g =	p;
					b =	v;
				}
				else if(i < 5.01)
				{
					r =	v;
					g =	p;
					b =	q;
				}
				
				color[0]	= r;
				color[1]	= g;
				color[2]	= b;
			} 
			color[3] = hsv[3];
			
			rgb[0] = color[0];
			rgb[1] = color[1];
			rgb[2] = color[2];
			rgb[3] = color[3];
			
			return rgb;
		} 
		
		public function RGB_to_HSV(color:Vector.<Number>):Vector.<Number>
		{
			var hsv : Vector.<Number> = new <Number>[0, 0, 0, 0];
			var r:Number, g:Number, b:Number, delta:Number;
			var colorMax:Number, colorMin:Number;
			var h:Number = 0;
			var s:Number = 0;
			var v:Number = 0;
			r = color[0];
			g = color[1];
			b = color[2];
			
			//trace("r:"+r.toString()+"g:"+g.toString()+"b:"+b.toString());
			
			colorMax = Math.max(r,g);
			colorMax = Math.max(colorMax,b);
			colorMin = Math.min(r,g);
			colorMin = Math.min(colorMin,b);
			v = colorMax;
			
			if(colorMax != 0)
			{
				s = (colorMax - colorMin) / colorMax;
			}
			if(s != 0) // if not achromatic
			{
				//trace("not achromatic");
				delta = colorMax - colorMin;
				if (r == colorMax)
				{
					h = (g-b)/delta;
				}
				else if (g == colorMax)
				{
					h = 2.0 + (b-r) / delta;
				}
				else // b is max
				{
					h = 4.0 + (r-g)/delta;
				}
				h *= 60;
				
				if( h < 0)
				{
					h +=360;
				}
				
			} 
			
			hsv[0] = h / 360.0; // moving h to be between 0 and 1.
			hsv[1] = s;
			hsv[2] = v;
			hsv[3] = color[3];
			//trace("h:"+hsv[0].toString()+"s:"+hsv[1].toString()+"v:"+hsv[2].toString()+"a:"+hsv[3].toString());
			//var color:uint = a << 24 | r << 16 | g << 8 | b;
			return hsv;
		}
		
		
		
		
		public function key(m_video_input:BitmapData,useSpill:Boolean=false):BitmapData
		{
			var bits:String;
			var currentPixel:uint;
			var imgHeight:uint=m_video_input.height;
			var imgWidth:uint=m_video_input.width;
			var keyedBmp:BitmapData=new BitmapData(m_video_input.width,m_video_input.height,true,0xAABBCCDD);
			destDataBytes=new ByteArray();
			//dataBytes=m_video_input.getPixels(new Rectangle(0,0,m_video_input.width,m_video_input.height));
			dataBytes=m_video_input.getVector(new Rectangle(0,0,m_video_input.width,m_video_input.height));
			//dataBytes.position=0;
			//destDataBytes.position=0;
			
			var rgb : Vector.<Number> = new <Number>[0, 0, 0, 0];
			var hsv : Vector.<Number> = new <Number>[0, 0, 0, 0];
			
			var numArray : Vector.<Number> = new <Number>[0, 0, 0, 0];
			
			var num1:Number = this.Hue - this.Tolerance;
			var num2:Number = this.Hue + this.Tolerance;
			var num3:Number = this.Tolerance / 360;
			var num4:Number = num1 / 360;
			var num5:Number = num2 / 360;
			var sat:Number = this.Saturation;
			

			trace("key start");
			var startTime:uint = getTimer();
			for(picPos = 0; picPos <dataBytes.length; picPos++)
			{
				
				rgb[2] = (dataBytes[picPos] & 0xFF) / 255.0;
				rgb[1] = (dataBytes[picPos] >> 8 & 0xFF) / 255.0;
				rgb[0] = (dataBytes[picPos] >> 16 & 0xFF) / 255.0;
				rgb[3] = (dataBytes[picPos] >> 24 & 0xFF) / 255.0;
				
				hsv=RGB_to_HSV(rgb);
				
				if(hsv[0] > num4 && hsv[0] < num5)
				{
					if ( hsv[1] >=  sat)
					{
						if ( hsv[2] >=  this.MinValue &&  hsv[2] <=  this.MaxValue)
						{
							hsv[3] = 0.0;
							hsv[1] = 0.0;
							rgb=HSV_to_RGB(hsv);
						}
						else if ( hsv[2] < this.MinValue)
						{
							hsv[3] = Math.min(1, ( this.MinValue + 1.0 -  hsv[2] /  this.MinValue));
							hsv[1] = 0.0;
							hsv[2] = 0.0;
							rgb=HSV_to_RGB(hsv);
						}
						else if ( hsv[2] > this.MaxValue)
						{
							hsv[3] = Math.min(1,((hsv[2] -  this.MaxValue) / (1.0 - this.MaxValue)));
							hsv[1] = 0.0;
							hsv[2] = 1;
							rgb=HSV_to_RGB(hsv);
						}
					} else
					{
						hsv[3] = 1;
						hsv[1] = 0.0;
						rgb=HSV_to_RGB(hsv);
					}
					dataBytes[picPos] = (rgb[3] * 255.0) << 24 | (rgb[0] * 255.0) << 16 | (rgb[1] * 255.0) << 8 | (rgb[2] * 255.0);
				}
				

				
			}
			//try {
			//destDataBytes.position=0;
			//keyedBmp.setPixels(new Rectangle(0,0,m_video_input.width,m_video_input.height),destDataBytes);
			//} catch (e:Error) {
			//	trace("error in setpixels");
			//}
			
			var endTime:uint = getTimer();
			trace("key done in : " + (endTime-startTime)/1000);

			keyedBmp.setVector(new Rectangle(0,0,m_video_input.width,m_video_input.height),dataBytes);
			return keyedBmp;
		}
		
		public function argb2vec(theNumber:uint):Vector.<Number> 
		{
			var theValue : Vector.<Number> = new <Number>[0, 0, 0, 0];
			// alpha
			theValue[3]=theNumber >> 24 & 0xFF;
			//red
			theValue[0]=theNumber >> 16 & 0xFF;
			//green
			theValue[1]=theNumber >> 8 & 0xFF;
			//blue
			theValue[2]=theNumber & 0xFF;
			
			
			return theValue;
		}
		
		
		
		function extractRed(c:uint):uint {
			return (( c >> 16 ) & 0xFF);
		}
		
		function extractGreen(c:uint):uint {
			return ( (c >> 8) & 0xFF );
		}
		
		function extractBlue(c:uint):uint {
			return ( c & 0xFF );
		}
	}
}