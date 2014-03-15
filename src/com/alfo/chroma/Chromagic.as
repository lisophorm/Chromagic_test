package com.alfo.chroma
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	public class Chromagic
	{
		public var  m_hue:Number;
		public var  m_delta_hue:Number;
		public var  m_min_saturation:Number;
		public var  m_left_spill:Number;
		public var  m_right_spill:Number;
		
		public var  m_min_value:Number;
		public var  m_max_value:Number;
		
		public var  m_smoothing:Number;
		
		private var dataBytes:ByteArray;
		private var destDataBytes:ByteArray;
		
		public function Chromagic()
		{
			m_hue = 120.0;
			m_delta_hue = 30.0;
			m_min_saturation = 0.2;
			m_left_spill = m_right_spill = 2.0;
			m_smoothing = 0;
			
			m_min_value = 0.35;
			m_max_value = 0.95;
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
		
		
		public function key(m_video_input:BitmapData):BitmapData
		{
			var bits:String;
			var currentPixel:uint;
			var keyedBmp:BitmapData=new BitmapData(m_video_input.width,m_video_input.height,true,0xAABBCCDD);
			destDataBytes=new ByteArray();
			dataBytes=m_video_input.getPixels(new Rectangle(0,0,m_video_input.width,m_video_input.height));
			dataBytes.position=0;
			destDataBytes.position=0;
			
			var rgb : Vector.<Number> = new <Number>[0, 0, 0, 0];
			var hsv : Vector.<Number> = new <Number>[0, 0, 0, 0];
			
			var h1:Number = m_hue - m_delta_hue / 2.0;
			var h2:Number = m_hue + m_delta_hue / 2.0;
			
			var smoothing:Number = 1.0 - m_smoothing;
			
			var hue_tolerance:Number = m_delta_hue / 2.0;
			hue_tolerance /= 360.0;
			
			h1 /= 360.0;
			h2 /= 360.0;
			
			var s:Number = m_min_saturation;
			
			h1 -= 0.1 * smoothing;
			h2 += 0.1 * smoothing;
			trace("key start");
			var startTime:uint = getTimer();
			for(var y:int = 0; y < m_video_input.height; y++)
			{
				//bits = m_video_input.scanLine(y);
				
				for(var x:int = 0; x < m_video_input.width; x++)
				{
					//currentPixel=
					//currentPixel=m_video_input.getPixel32(x,y);
					rgb[3]=dataBytes.readUnsignedByte() /255.0;
					rgb[0]=dataBytes.readUnsignedByte() /255.0;
					rgb[1]=dataBytes.readUnsignedByte() /255.0;
					rgb[2]=dataBytes.readUnsignedByte() /255.0;
					//rgb[2] = (currentPixel & 0xFF) / 255.0;
					//rgb[1] = (currentPixel  >> 8 & 0xFF) / 255.0;
					//rgb[0] = (currentPixel >> 16 & 0xFF) / 255.0;
					//rgb[3] = (currentPixel >> 24 & 0xFF) / 255.0;
					
					hsv=RGB_to_HSV(rgb);
					
					if(hsv[0] > h1 && hsv[0] < h2)
					{
						if(hsv[1] > s && hsv[2] > 0.4 && hsv[2] < 0.95) 
						{
							hsv[3] = 0.0;
							hsv[1] = 0.0;
							
							rgb=HSV_to_RGB(hsv);
						} else if(hsv[1] > s && hsv[2] > 0.2) {
							hsv[3] = (1 - hsv[1]) / 0.9;
							
							hsv[1] = 0.0;
							rgb=HSV_to_RGB(hsv);
						}
						else
						{
							hsv[3] = 1.0;
							hsv[1] = 0.0;
							rgb=HSV_to_RGB(hsv);
						}
					}
					currentPixel = (rgb[3] * 255.0) << 24 | (rgb[0] * 255.0) << 16 | (rgb[1] * 255.0) << 8 | (rgb[2] * 255.0);
					keyedBmp.setPixel32(x,y,currentPixel);
					//destDataBytes.writeByte(int(rgb[3] * 255.0) << 24);
					//destDataBytes.writeByte(int(rgb[0] * 255.0) << 16);
					//destDataBytes.writeByte(int(rgb[1] * 255.0) << 8);
					//destDataBytes.writeByte(int(rgb[2] * 255.0));
				}
				
				//trace("new line"+y);
			}
			//try {
				//destDataBytes.position=0;
				//keyedBmp.setPixels(new Rectangle(0,0,m_video_input.width,m_video_input.height),destDataBytes);
			//} catch (e:Error) {
			//	trace("error in setpixels");
			//}
			var endTime:uint = getTimer();
			
			trace("key done in : " + (endTime-startTime)/1000);

			/*var left_spill:Number = m_left_spill;
			int right_spill = m_right_spill;
			
			for(int y = 1; y < m_video_input.height() - 1; y++)
			{
				bits = m_video_input.scanLine(y);
				
				for(int x = 0; x < m_video_input.width() - right_spill; x++)
				{
					*(bits + x * 4 + 3) = min(*(bits + x * 4 + 3), *(bits + (x + right_spill) * 4 + 3));
				}
				
				for(int x = m_video_input.width() - left_spill - 1; x >= 0; x--)
				{
					*(bits + x * 4 + 3) = min(*(bits + x * 4 + 3), *(bits + (x - left_spill) * 4 + 3));
				}
			}*/
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