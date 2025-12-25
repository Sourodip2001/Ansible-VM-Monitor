#!/bin/bash
#instance IDs with Environment=dev and running state
instance_ids=$(aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

# Exit if no instances found
if [ -z "$instance_ids" ]; then
  echo "No matching instances found"
  exit 0
fi

# Sort instance IDs deterministically
mapfile -t sorted_ids < <(echo "$instance_ids" | tr '\t' '\n' | sort)

# Rename instances sequentially
counter=1
for id in "${sorted_ids[@]}"; do
  name="web-$(printf "%02d" "$counter")"
  echo "Tagging $id as $name"
  aws ec2 create-tags \
    --resources "$id" \
    --tags Key=Name,Value="$name"
  ((counter++))
done

