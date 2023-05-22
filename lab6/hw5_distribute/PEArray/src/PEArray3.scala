package PEArray3

import chisel3._
import chisel3.util._
import chisel3.experimental.ChiselEnum

class PData[T<:Data](dtype:T) extends Bundle{
  val data = dtype.cloneType
  val pos = UInt(2.W)
}
object PData{
  def apply[T<:Data](dtype:T) = new PData(dtype)
}

// TODO: sub-modules if you need

class PEArray[T<:Bits with Num[T]](dtype:T) extends Module{
  val a_in = IO(Vec(4, DeqIO(dtype)))
  val b_in = IO(Vec(4, DeqIO(dtype)))
  val c_in = IO(Vec(4, DeqIO(PData(dtype))))
  val c_out = IO(Vec(4, EnqIO(PData(dtype))))

  // TODO: finish this module

}

