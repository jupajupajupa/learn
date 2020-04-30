templateFile="azuredeploy.json"
today=$(date +"%d-%b-%Y")
DeploymentName="addoutputs-"$today

az deployment group create \
  --name $DeploymentName \
  --resource-group $RG \
  --template-file $templateFile \
  --parameters storageName={your-Prefix-name}