locals {
  os_type = trimspace(chomp(shell("uname -s || echo Windows")))
}

data "external" "lnetIpCheck" {
  program = local.os_type == "Linux" ? ["pwsh", "-File", "${abspath(path.module)}/scripts/ip-range-overlap.ps1", var.startingAddress, var.endingAddress, var.lnet-startingAddress, var.lnet-endingAddress] :
            ["powershell.exe", "-File", "${abspath(path.module)}/scripts/ip-range-overlap.ps1", var.startingAddress, var.endingAddress, var.lnet-startingAddress, var.lnet-endingAddress]

  lifecycle {
    postcondition {
      condition     = self.result.result == "ok"
      error_message = "AKS Arc IP range overlaps with HCI IP range."
    }
  }
}
