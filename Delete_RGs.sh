#! /bin/bash

# List of resource groups to delete
resource_groups=("rg-avd-avdn-test-use2-network" "rg-avd-avdn-test-use2-service-objects" "rg-avd-avdn-test-use2-pool-compute" "rg-avd-avdn-test-use2-storage" "rg-avd-test-use2-monitoring")

# Loop through each resource group and delete
for rg in "${resource_groups[@]}"; do
    echo "Deleting resource group: $rg"
    az group delete --name $rg --yes --no-wait
done

echo "Resource groups deletion requested. Check Azure portal for status."