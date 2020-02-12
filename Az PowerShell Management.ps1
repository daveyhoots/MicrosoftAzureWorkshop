#################################################
### Prerequisites for PowerShell Management
#################################################

# Check your PowerShell version
# Note: Azure PowerShell works with PowerShell 5.1 or higher on Windows
$PSVersionTable.PSVersion

# Install the Az module from the PowerShell Gallery for the active user
# WARNING: The Az and AzureRm modules cannot run side-by-side.
# Note: The LOD lab machine has AzureRm pre-installed
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Get Azure PowerShell modules and versions
Get-Module -ListAvailable Az*

# Connect to your Azure subscription 
Login-AzAccount

# Get all the Azure subscriptions you have access to 
Get-AzSubscription

# If you need to switch to a different default subscription  
Select-AzSubscription

# Save your credentials in a local JSON file
Save-AzProfile -Path C:\AzureProfileFolder\azureprofile.json 
Select-AzProfile -Path C:\AzureProfileFolder\azureprofile.json

#################################################
### Managing Storage Accounts
#################################################

# Create a resource group
New-AzResourceGroup -Name 'azuremgmt' -Location 'Central US'

# Check if your storage account name is available, it must be globally unique  
Get-AzStorageAccountNameAvailability –Name youraliasazuremgmt

# Create the storage account
New-AzStorageAccount -ResourceGroup azuremgmt -Name youraliasazuremgmt -SkuName Standard_LRS -Location “East US”

# Set the default storage account
Set-AzCurrentStorageAccount -ResourceGroupName azuremgmt -Name youraliasazuremgmt

# Create variables for your resource group and storage account names
$resourceGroup = "azuremgmt"
$storageaccount = "youraliasazuremgmt"

# Retrieve the storage account keys 
$storageAccountKey = Get-AzStorageAccountKey –ResourceGroupName $resourceGroup –Name $storageaccount

# Create a storage account context
$ctx = New-AzureStorageContext -StorageAccountName $storageaccount -StorageAccountKey $storageAccountkey.value[0]  

# Create a container named "vhds" within your storage account 
New-AzureStorageContainer -Name vhds

# Upload VHDs to Azure storage
Add-AzVhd -ResourceGroupName "azuremgmt" -Destination "https://youraliasazuremgmt.blob.core.windows.net/vhds/datadisk1.vhd" -LocalFilePath "C:\Demos\testdisk.vhd"

# Download VHDs from Azure storage 
Save-AzVhd -ResourceGroupName "azuremgmt" -SourceUri "https://youraliasazuremgmt.blob.core.windows.net/vhds/datadisk1.vhd" -LocalFilePath "C:\Demos\datadisk1dl.vhd" 

# Delete your storage account
Remove-AzStorageAccount -ResourceGroupName azuremgmt -Name youraliasazuremgmt

#################################################
### Managing Virtual Machines
#################################################

# Step 1: Create a resource group
New-AzResourceGroup -Name 'azuremgmt' -Location 'Central US'

# Step 2: Create a storage account
New-AzStorageAccount -ResourceGroup azuremgmt -Name youraliasazuremgmt -SkuName Standard_LRS -Location “Central US”

# Step 3: Create Azure Network Security Group
$rule1 = New-AzNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName azuremgmt -Location eastus -Name "NSG-FrontEnd" -SecurityRules $rule1

# Step 4 & 5: Create Azure Virtual Network and Subnet
$subnet = New-AzVirtualNetworkSubnetConfig -Name frontendSubnet -AddressPrefix 10.0.1.0/24
New-AzVirtualNetwork -Name myVnet -ResourceGroupName azuremgmt -Location "Central US" -AddressPrefix 10.0.0.0/16 -Subnet $subnet

# Step 6: Create Azure Public IP Address
New-AzPublicIpAddress -Name myPip -ResourceGroupName azuremgmt -Location "Central US" -AllocationMethod Static

# Get the Public IP Address resource ID
Get-AzPublicIpAddress -Name myPip -ResourceGroupName azuremgmt

# Get the subnet resource ID
Get-AzVirtualNetwork -Name myVnet -ResourceGroupName azuremgmt

# Step 7: Create Network Interface Card (NIC)
New-AzNetworkInterface -Name vmnic1 -ResourceGroupName azuremgmt -Location "Central US" -SubnetId '/subscriptions/<Sub ID>/resourceGroups/azuremgmt/providers/Microsoft.Network/virtualNetworks/myVnet/subnets/frontendSubnet' -PublicIpAddressId '/subscriptions/<Sub ID>/resourceGroups/azuremgmt/providers/Microsoft.Network/publicIPAddresses/mypip'

# Get the NIC resource ID
Get-AzNetworkInterface -Name vmnic1 -ResourceGroupName azuremgmt

# Step 8: Get Virtual Machine publisher, Image Offer, Sku and Image
Get-AzVMImagePublisher -Location eastus 
Get-AzVMImageoffer -Location eastus -publisher MicrosoftWindowsServer
Get-AzVMImageSku -Location eastus -PublisherName MicrosoftWindowsServer -Offer WindowsServer
Get-AzVMImage -Location eastus -PublisherName MicrosoftWindowsServer -Offer WindowsServer -sku 2019-Datacenter

# Step 9: Create an virtual machine configuration file
$VMName = "MyVM"
$ComputerName = "MyWindowsVM"
$VMSize = "Standard_B2s"

$VM = New-AzVMConfig -VMName $VMName -VMSize $VMSize
$VM = Set-AzVMOperatingSystem -VM $VM -Windows -ComputerName $ComputerName -ProvisionVMAgent -EnableAutoUpdate
$VM = Add-AzVMNetworkInterface -VM $VM -Id '/subscriptions/<Sub ID>/resourceGroups/azuremgmt/providers/Microsoft.Network/networkInterfaces/vmnic1'
$VM = Set-AzVMSourceImage -VM $VM -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2012-R2-Datacenter' -Version latest

# Step 10: Create Azure Virtual Machine
New-AzVM -ResourceGroupName azuremgmt -Location "Central US" -VM $VM -Verbose

#################################################
### Managing Virtual Networks
#################################################

# Choose names and locations
Get-AzLocation | Select DisplayName 

# Declare variables 
$RG1 = "TestRG01"
$Location = "East US"
$VNetName1 = "DevVNet01"
$SubnetName1 = "FrontEndSubnet"
$SubnetName2 = "BackEndSubnet"
$SubnetName3 = "GatewaySubnet"

$VNetAddressPrefix = "10.1.0.0/16"
$SubnetAddressPrefix1 = "10.1.7.0/24"
$SubnetAddressPrefix2 = "10.1.8.0/24"
$SubnetAddressPrefix3 = "10.1.254.0/24"
$DnsServer = @("10.1.8.5","10.1.8.6")

# If necessary, create a Resource Group
New-AzResourceGroup -Name $RG1 -Location $Location -Tag @{Dept="IT"; Environment="TestDev"}

# Create a new VNet
$vnet01 = New-AzVirtualNetwork -ResourceGroupName $RG1 -Name $VNetName1 -AddressPrefix $VNetAddressPrefix -Location $location -Tag @{Dept="IT"; Environment="TestDev"}

# Add two subnets to the $vnet01 variable
Add-AzVirtualNetworkSubnetConfig -Name $SubnetName1 -VirtualNetwork $vnet01 -AddressPrefix $SubnetAddressPrefix1
Add-AzVirtualNetworkSubnetConfig -Name $SubnetName2 -VirtualNetwork $vnet01 -AddressPrefix $SubnetAddressPrefix2

# Save your changes to Azure
Set-AzVirtualNetwork -VirtualNetwork $vnet01

# Confirm your changes are saved
Get-AzVirtualNetwork -ResourceGroupName $RG1 -Name $VNetName1 

# Make changes to the existing VNet
# Read VNet configuration into a variable $vnet01
$vnet01 = Get-AzVirtualNetwork -ResourceGroupName $RG1 -Name $VNetName1

# Add a new subnet to the $vnet01 variable
Add-AzVirtualNetworkSubnetConfig -Name $SubnetName3 -VirtualNetwork $vnet01 -AddressPrefix $SubnetAddressPrefix3

# And array of DNS servers to the $vnet01 variable
$vnet01.DhcpOptions.DnsServers = $DnsServer 

# Save your changes to Azure
Set-AzVirtualNetwork -VirtualNetwork $vnet01

# Confirm your changes 
Get-AzVirtualNetwork -ResourceGroupName $RG1 -Name $VNetName1 

# Delete the Virtual Network 
Remove-AzVirtualNetwork -Name $VNetName1 -ResourceGroupName $RG1 -Force

# Delete the entire resource group
Remove-AzResourceGroup -Name $RG1 -Force -Verbose
