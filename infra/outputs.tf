output "azure_vm_public_ip" {
  value       = azurerm_linux_virtual_machine.devops_vm.public_ip_address
  description = "The live public IP address of your Azure deployment server. Use this for your deployment target."
}