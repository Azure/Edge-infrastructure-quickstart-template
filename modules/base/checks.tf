data "external" "aksIpCheck" {
  program = ["pwsh", "-File", "${abspath(path.module)}/scripts/ip-range-overlap.ps1", var.startingAddress, var.endingAddress, var.aksArc-lnet-startingAddress, var.aksArc-lnet-endingAddress]

  lifecycle {
    postcondition {
      condition     = self.result.result == "ok"
      error_message = "AKS Arc IP range overlaps with HCI IP range."
    }
  }
}
