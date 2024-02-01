output "kubeConfig"{
    value = module.base.kubeConfig
    sensitive = true
}

output "aksArcPrivateKey"{
    value = module.base.aksArcPrivateKey
    sensitive = true  
}