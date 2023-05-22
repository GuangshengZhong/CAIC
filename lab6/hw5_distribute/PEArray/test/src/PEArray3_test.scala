package PEArray3

import chisel3._
import chisel3.util._
import chiseltest._
import chisel3.experimental.VecLiterals._
import chisel3.experimental.BundleLiterals._
import org.scalatest.flatspec.AnyFlatSpec

import scala.util.Random
import java.lang.System
import chiseltest.internal.TesterThreadList


class PEArrayTest3 extends AnyFlatSpec with ChiselScalatestTester{
  behavior of "PEArray3"

  val rand = new Random(System.currentTimeMillis())

  // Both continue
  it should "handle continue stream of data, 4x4x4" in {
    makeSingleTest(4, true, true)
  }
  it should "handle continue stream of data, 4x4x8" in {
    makeSingleTest(8, true, true)
  }

  // Input disContinue, Output continue
  it should "handle discontinue input stream of data, 4x4x4" in {
    makeSingleTest(4, false, true)
  }
  it should "handle discontinue input stream of data, 4x4x8" in {
    makeSingleTest(8, false, true)
  }

  // Input disContinue, Output continue
  it should "handle discontinue output stream of data, 4x4x4" in {
    makeSingleTest(4, true, false)
  }
  it should "handle discontinue output stream of data, 4x4x8" in {
    makeSingleTest(8, true, false)
  }

  // Both disContinue
  it should "handle discontinue I/O stream of data, 4x4x4" in {
    makeSingleTest(4, false, false)
  }
  it should "handle discontinue I/O stream of data, 4x4x8" in {
    makeSingleTest(8, false, false)
  }

  def makeSingleTest(K:Int,inContinue:Boolean, outContinue:Boolean) = {
    val dtype = UInt(8.W)
    val (a,b,c) = makeData(8,4,4,K)
    test(new PEArray(dtype)){ dut => {
      for (i<-0 until 4){
        dut.a_in(i).initSource().setSourceClock(dut.clock)
        dut.b_in(i).initSource().setSourceClock(dut.clock)
        dut.c_in(i).initSource().setSourceClock(dut.clock)
        dut.c_out(i).initSink().setSinkClock(dut.clock)
      }
      seqFork(
        dut.c_in.map{
          case (p) => () => {
            if (inContinue)
              p.enqueueSeq((3 to 0 by -1).map{case (i) => PData(dtype).Lit(_.data->0.U, _.pos->i.U)})
            else
              randomEnqueueSeq(p, (3 to 0 by -1).map{case (i) => PData(dtype).Lit(_.data->0.U, _.pos->i.U) }, dut.clock)
          }
        } 
      )
      dut.clock.step(8)
      seqFork(
        dut.a_in.zipWithIndex.map{
          case (p, i) => ()=> {
            if (inContinue)
              p.enqueueSeq(a(i).map(_.U))
            else
              randomEnqueueSeq(p, a(i).map(_.U), dut.clock)
          }
        } ++ 
        dut.b_in.zipWithIndex.map{
          case (p, j) => ()=>{
            if (inContinue)
              p.enqueueSeq((0 until K).map{case(k) => b(k)(j).U})
            else
              randomEnqueueSeq(p, (0 until K).map{case(k) => b(k)(j).U}, dut.clock)
          }
        }
      )
      dut.clock.step(8)
      seqFork(
        dut.c_in.map{
          case (p) => () => {
            if (inContinue)
              p.enqueueSeq((3 to 0 by -1).map{case (i) => PData(dtype).Lit(_.data->0.U, _.pos->i.U) })
            else
              randomEnqueueSeq(p, (3 to 0 by -1).map{case (i) => PData(dtype).Lit(_.data->0.U, _.pos->i.U) }, dut.clock)
          }
        } 
      )
      dut.clock.step(8)
      seqFork(
        dut.c_out.zipWithIndex.map{
          case (p, j) => () => {
            if (outContinue)
              assert(outOfOrderDequeue(p, (0 until 4).map{case (i) => c(i)(j)}, dut.clock, 8), "Result is not correct!")
            else
              assert(outOfOrderRandomDequeue(p, (0 until 4).map{case (i) => c(i)(j)}, dut.clock, 8), "Result is not correct!")
          }
        }
      )
    } } 
  }

  def makeData(w:Int, n:Int, m:Int, k:Int) = {
    val a = Seq.fill(n,k)(rand.nextInt(1<<(w/2)))
    val b = Seq.fill(k,m)(rand.nextInt(1<<(w/2)))
    val c = Seq.tabulate(n,m){case (i,j) => ((for (t <- 0 until k) yield a(i)(t) * b(t)(j)).sum) & ((1<<w)-1)}
    (a, b, c)
  }
  def parallelPoke[T<:Data](port: Vec[DecoupledIO[T]], data: IndexedSeq[T]) = {
    seqFork(port.zip(data).map{case (p, d)=> ()=>p.enqueue(d)})
  }
  def seqFork(acts: Seq[()=>Unit]):Unit = {
    if (acts.size == 1) acts.head()
    else {
      val f = fork {acts.head()}
      acts.tail.foldLeft(f){case (lastFork, a)=> lastFork.fork{a()}}.join()
    }
  }
  def randomEnqueue[T<:Data](x:DecoupledIO[T], y:T, c:Clock) = {
    val t = rand.nextInt(4)
    if (t>0) {
      x.valid.poke(0.B)
      c.step(t)
    }
    x.valid.poke(1.B)
    x.bits.poke(y)
    while (!x.ready.peek().litToBoolean) 
      c.step()
    c.step()
    x.valid.poke(0.B)
  }
  def randomEnqueueSeq[T<:Data](x:DecoupledIO[T], y:Seq[T], c:Clock) = {
    for (i<-y) randomEnqueue(x, i, c)
  }
  def outOfOrderDequeue[T<:Data](x:DecoupledIO[PData[T]], y:IndexedSeq[Int], c:Clock, timeOut:Int) = {
    val s = Array.fill(4)(false)
    x.ready.poke(1.B)
    def helper(t:Int): Boolean = 
      if (t == timeOut) {
        println("Time out!")
        false
      }
      else
        if (x.valid.peek().litToBoolean)
        {
          val data = x.bits.data.peek().litValue  
          val pos = x.bits.pos.peek().litValue.toInt
          if (data!= y(pos)) {
            // println(pos, data, y(pos))
            false
          }
          else{
            s(x.bits.pos.peek().litValue.toInt) = true
            if (!s.exists(!_)) {
              c.step()
              x.ready.poke(0.B)
              true
            }
            else {
              c.step()
              helper(t+1)
            }
          }
        }
      else {
        c.step()
        helper(t+1)
      }
    helper(0)
  }
  def outOfOrderRandomDequeue[T<:Data](x:DecoupledIO[PData[T]], y:IndexedSeq[Int], c:Clock, timeOut:Int) = {
    val s = Array.fill(4)(false)
    def helper(t:Int): Boolean = 
      if (t == timeOut) {
        println("Time out!")
        false
      }
      else {
        val cycles = rand.nextInt(4)
        if (cycles>0) {
          x.ready.poke(0.B)
          c.step(cycles)
        }
        x.ready.poke(1.B)
        if (x.valid.peek().litToBoolean)
        {
          val data = x.bits.data.peek().litValue  
          val pos = x.bits.pos.peek().litValue.toInt
          if (data!= y(pos)) {
            // println(pos, data, y(pos))
            false
          }
          else{
            s(x.bits.pos.peek().litValue.toInt) = true
            if (!s.exists(!_)) {
              c.step()
              x.ready.poke(0.B)
              true
            }
            else {
              c.step()
              helper(t+1)
            }
          }
        }
      else {
        c.step()
        helper(t+1)
      }
    }
    helper(0)
  }
}
