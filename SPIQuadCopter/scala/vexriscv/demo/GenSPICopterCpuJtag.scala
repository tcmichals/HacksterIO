package vexriscv.demo

import spinal.core._
import spinal.lib._
import spinal.lib.com.jtag.Jtag
import vexriscv._
import vexriscv.plugin._

/**
 * Generate VexRiscv for SPI Copter project - WITH JTAG TAP
 * 
 * Same as GenSPICopterCpu but with hardware JTAG pins for debugging.
 * Use this for Arty S7-50 with external JTAG debugger.
 * 
 * Configuration: RV32IMC with Wishbone interface, no caches
 * Features:
 *   - IBusSimplePlugin with Wishbone output
 *   - DBusSimplePlugin with Wishbone output
 *   - Mul/Div plugins for M extension
 *   - Compressed instruction support (C extension)
 *   - Hardware JTAG TAP (TMS, TCK, TDI, TDO pins)
 *   - Full interrupt support (external, timer, software)
 */
object GenSPICopterCpuJtag {
  def main(args: Array[String]) {
    SpinalVerilog {
      // CPU configuration - must be inside SpinalVerilog block for ClockDomain.current
      val cpuConfig = VexRiscvConfig(
        plugins = List(
          new IBusSimplePlugin(
            resetVector = 0x00000000l,
            cmdForkOnSecondStage = false,
            cmdForkPersistence = false,
            prediction = STATIC,
            catchAccessFault = false,
            compressedGen = true
          ),
          new DBusSimplePlugin(
            catchAddressMisaligned = false,
            catchAccessFault = false
          ),
          new CsrPlugin(
            CsrPluginConfig(
              catchIllegalAccess = false,
              mvendorid      = null,
              marchid        = null,
              mimpid         = null,
              mhartid        = null,
              misaExtensionsInit = 0,
              misaAccess     = CsrAccess.NONE,
              mtvecAccess    = CsrAccess.READ_WRITE,
              mtvecInit      = 0x00000020l,
              mepcAccess     = CsrAccess.READ_WRITE,
              mscratchGen    = false,
              mcauseAccess   = CsrAccess.READ_ONLY,
              mbadaddrAccess = CsrAccess.READ_ONLY,
              mcycleAccess   = CsrAccess.READ_ONLY,
              minstretAccess = CsrAccess.READ_ONLY,
              ecallGen       = true,
              wfiGenAsWait   = false,
              ucycleAccess   = CsrAccess.NONE
            )
          ),
          new DecoderSimplePlugin(
            catchIllegalInstruction = false
          ),
          new RegFilePlugin(
            regFileReadyKind = plugin.SYNC,
            zeroBoot = false
          ),
          new IntAluPlugin,
          new SrcPlugin(
            separatedAddSub = false,
            executeInsertion = true
          ),
          new FullBarrelShifterPlugin,
          new MulPlugin,
          new DivPlugin,
          new HazardSimplePlugin(
            bypassExecute = true,
            bypassMemory = true,
            bypassWriteBack = true,
            bypassWriteBackBuffer = true,
            pessimisticUseSrc = false,
            pessimisticWriteRegFile = false,
            pessimisticAddressMatch = false
          ),
          new BranchPlugin(
            earlyBranch = false,
            catchAddressMisaligned = false
          ),
          new DebugPlugin(ClockDomain.current.clone(reset = Bool().setName("debugReset"))),
          new YamlPlugin("cpu0.yaml")
        )
      )
      
      val cpu = new VexRiscv(cpuConfig)
      cpu.setDefinitionName("VexRiscvJtag")
      
      // Convert buses to Wishbone interface and add JTAG
      cpu.rework {
        for (plugin <- cpuConfig.plugins) plugin match {
          case plugin: IBusSimplePlugin => {
            plugin.iBus.setAsDirectionLess()
            master(plugin.iBus.toWishbone()).setName("iBusWishbone")
          }
          case plugin: IBusCachedPlugin => {
            plugin.iBus.setAsDirectionLess()
            master(plugin.iBus.toWishbone()).setName("iBusWishbone")
          }
          case plugin: DBusSimplePlugin => {
            plugin.dBus.setAsDirectionLess()
            master(plugin.dBus.toWishbone()).setName("dBusWishbone")
          }
          case plugin: DBusCachedPlugin => {
            plugin.dBus.setAsDirectionLess()
            master(plugin.dBus.toWishbone()).setName("dBusWishbone")
          }
          // Add JTAG TAP - creates TMS, TCK, TDI, TDO pins
          case plugin: DebugPlugin => plugin.debugClockDomain {
            plugin.io.bus.setAsDirectionLess()
            val jtag = slave(new Jtag()).setName("jtag")
            jtag <> plugin.io.bus.fromJtag()
          }
          case _ =>
        }
      }
      
      cpu
    }
  }
}
