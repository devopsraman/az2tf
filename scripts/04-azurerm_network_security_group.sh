tfp="azurerm_network_security_group"
echo $tfp
if [ "$1" != "" ]; then
rgsource=$1
else
echo -n "Enter name of Resource Group [$rgsource] > "
read response
if [ -n "$response" ]; then
     rgsource=$response
fi
fi
nsg=`az network nsg list -g $rgsource`
count=`echo $nsg | jq '. | length'`
count=`expr $count - 1`
for i in `seq 0 $count`; do
nsgnam=`echo $nsg | jq ".[(${i})].name" | tr -d '"'`
nsgid=`echo $nsg | jq ".[(${i})].id" | tr -d '"'`
printf "resource \"%s\" \"%s\" { \n" $tfp $nsgnam > nsg-$nsgnam.tf
printf "\t name = \"%s\"  \n" $nsgnam >> nsg-$nsgnam.tf
printf "\t location = \"\${var.loctarget}\"\n"  >> nsg-$nsgnam.tf
printf "\t resource_group_name = \"\${var.rgtarget}\"\n" >> nsg-$nsgnam.tf
printf "}\n" >> nsg-$nsgnam.tf
terraform state rm $tfp.$nsgnam 
terraform import $tfp.$nsgnam $nsgid
done
