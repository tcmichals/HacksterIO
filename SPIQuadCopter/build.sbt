// =============================================================================
// SPI Copter CPU Generator - SBT Build Configuration
// =============================================================================
// This project extends VexRiscv with custom CPU configurations for the
// SPI Copter project (Tang Nano 20K, Arty S7-50).
//
// Usage:
//   sbt "runMain vexriscv.demo.GenSPICopterCpu"        # Standard (debug bus)
//   sbt "runMain vexriscv.demo.GenSPICopterCpuJtag"    # With JTAG TAP
// =============================================================================

lazy val vexriscv = ProjectRef(file("vexriscv"), "root")

lazy val cpugen = (project in file("."))
  .dependsOn(vexriscv)
  .settings(
    name := "SPICopterCpuGen",
    version := "1.0.0",
    scalaVersion := "2.12.18",
    
    // Add our custom scala sources
    Compile / unmanagedSourceDirectories += baseDirectory.value / "scala",
    
    // Fork for memory
    fork := true
  )
