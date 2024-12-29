#!/bin/bash

# Set Library Name
LIB_NAME="lib-services.sh"

# Check if STACK_DIR is set
if [[ ! "${STACK_DIR}" ]]; then
  echo "Please define 'STACK_DIR' variable"; exit 1
fi

# Check if lib-core.sh is already imported
if [[ "${PROCESS_SOURCE[*]}" =~ $LIB_NAME ]]; then
  echo "Warning! '${LIB_NAME}' is already imported"; exit 1
fi

# Add lib-core.sh to the list of imported files
PROCESS_SOURCE=("$LIB_NAME")

# ---------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------

# ------------Services--------------#
CORE_SERVICES=("webserver" "database")

# Combine CORE_SERVICES and the services from services.json (only the enabled ones)
SERVICES=()
SERVICES=("${CORE_SERVICES[@]}")
if [[ -f "${STACK_DIR}/services.json" ]]; then
  for service in $(jq -r '.services | keys[]' "${STACK_DIR}/services.json"); do
    if jq -r ".services.\"$service\".enabled" "${STACK_DIR}/services.json" | grep -q "true"; then
      SERVICES+=("$service")
    fi
  done
fi

# ---------------------------------------------------------------------
# Services
# ---------------------------------------------------------------------

# Get only enableb optional services
getOptionalServices() {
  local services=()
  for service in "${SERVICES[@]}"; do
    if [[ "${CORE_SERVICES[*]}" =~ $service ]]; then
      continue
    fi
    services+=("$service")
  done
  echo "${services[@]}"
}

# Get all optional services
getAllOptionalServices() {
  local services=()
  if [[ -f "${STACK_DIR}/services.json" ]]; then
    for service in $(jq -r '.services | keys[]' "${STACK_DIR}/services.json"); do
      services+=("$service")
    done
  fi
  echo "${services[@]}"
}

# Get service description
getServiceDescription() {
  local service=$1
  if [[ -f "${STACK_DIR}/services.json" ]]; then
    jq -r ".services.\"$service\".description" "${STACK_DIR}/services.json"
  fi
}

# Checks if a given service is enabled by reading the services.json file
isServiceEnabled() {
  local service=$1
  if [[ -f "${STACK_DIR}/services.json" ]]; then
    enabled=$(jq -r ".services.\"$service\".enabled" "${STACK_DIR}/services.json")
    if [[ "${enabled}" == "true" ]]; then
      return 0
    fi
  fi
  return 1
}

# Enable a service in the JSON file
enableService() {
  local service=$1
  if [[ ! -f "${STACK_DIR}/services.json" ]]; then
    message --error "services.json not found"
    return 1
  fi

  # Check if service exists
  if ! jq -e ".services.\"$service\"" "${STACK_DIR}/services.json" >/dev/null; then
    message --error "Service '$service' not found"
    return 1
  fi

  # Update enabled status to true
  tmp=$(mktemp)
  jq ".services.\"$service\".enabled = true" "${STACK_DIR}/services.json" > "$tmp" && mv "$tmp" "${STACK_DIR}/services.json"
}

# Disable a service in the JSON file
disableService() {
  local service=$1
  if [[ ! -f "${STACK_DIR}/services.json" ]]; then
    message --error "services.json not found"
    return 1
  fi

  # Check if service exists
  if ! jq -e ".services.\"$service\"" "${STACK_DIR}/services.json" >/dev/null; then
    message --error "Service '$service' not found"
    return 1
  fi

  # Update enabled status to false
  tmp=$(mktemp)
  jq ".services.\"$service\".enabled = false" "${STACK_DIR}/services.json" > "$tmp" && mv "$tmp" "${STACK_DIR}/services.json"
}
