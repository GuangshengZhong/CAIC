import mill._
import mill.scalalib._
import mill.scalalib.scalafmt.ScalafmtModule
import mill.scalalib.TestModule.ScalaTest
import mill.bsp._

object PEArray extends common

trait common extends ScalaModule with ScalafmtModule{ m =>
    override def scalaVersion = "2.13.7"
    override def scalacOptions = Seq(
    "-language:reflectiveCalls",
    "-deprecation",
    "-feature",
    "-Xcheckinit",
  )

  override def ivyDeps = Agg(ivy"edu.berkeley.cs::chisel3:3.5.0") ++
      Agg(ivy"org.scalactic::scalactic::3.2.11") ++
      Agg(ivy"org.scalatest::scalatest::3.2.11") ++
      Agg(ivy"edu.berkeley.cs::chiseltest:0.5.0")
  override def scalacPluginIvyDeps = Agg(ivy"edu.berkeley.cs:::chisel3-plugin:3.5.0")


  object test extends Tests with ScalaTest {
  }
}

