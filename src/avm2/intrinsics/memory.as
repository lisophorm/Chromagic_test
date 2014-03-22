package avm2.intrinsics
{
	public interface memory
	{
		public function li8(addr:int):int; // load 8 bit int
		public function li16(addr:int):int; // load 16 bit int
		public function li32(addr:int):int; // load 32 bit int
		public function lf32(addr:int):Number; // load 32 bit float
		public function lf64(addr:int):Number; // load 64 bit float
		public function si8(value:int, addr:int):void; // store 8 bit integer
		public function si16(value:int, addr:int):void; // store 16 bit integer
		public function si32(value:int, addr:int):void; // store 32 bit integer
		public function sf32(value:Number, addr:int):void; // store 32 bit float
		public function sf64(value:Number, addr:int):void; // store 64 bit float
		public function sxi1(value:int):int;
		// sign extend a 1 bit value to 32 bits
		public function sxi8(value:int):int;
		// sign extend an 8 bit value to 32 bits
		public function sxi16(value:int):int;
		// sign extend a 16 bit value to 32 bits
	}
}