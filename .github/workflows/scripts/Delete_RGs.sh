#! /bin/bash

# List of resource groups to delete
resource_groups=("avd-nih-arpah-test-use2-monitoring" "avd-nih-arpah-test-use2-network" "avd-nih-arpah-test-use2-pool-compute" "avd-nih-arpah-test-use2-service-objects" "rg-avd-test-use2-monitoring")

# Loop through each resource group and delete
for rg in "${resource_groups[@]}"; do
    echo "Deleting resource group: $rg"
    az group delete --name $rg --yes --no-wait
done

echo "Resource groups deletion requested. Check Azure for status."