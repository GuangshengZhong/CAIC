package PEArray1

import chisel3._
import chisel3.util._
import chisel3.experimental.ChiselEnum

// TODO: sub-modules if you need

class PEArray[T<:Bits with Num[T]](dtype:T) extends Module{
  val a_in = IO(Input(Vec(4, dtype)))
  val b_in = IO(Input(Vec(4, dtype)))
  val c_in = IO(Input(Vec(4, dtype)))
  val c_out = IO(Output(Vec(4, dtype)))
  val stationaryCtrl = IO(Input(Bool()))

  // TODO: finish this module
}
