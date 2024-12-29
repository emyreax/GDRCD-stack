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
  for service in $(jq -r 'keys[]' "${STACK_DIR}/services.json"); do
    if jq -r ".services.\"$service\".enabled" "${STACK_DIR}/services.json" | grep -q "true"; then
      SERVICES+=("$service")
    fi
  done
fi

# ---------------------------------------------------------------------
# Services
# ---------------------------------------------------------------------

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

# Funzione per abilitare un servizio nel file JSON
enableService() {
  local service=$1
  if [[ -f "${STACK_DIR}/services.json" ]]; then
    # Usa jq per impostare il valore del servizio a true
    tmp=$(mktemp)
    jq ".[\"$service\"] = true" "${STACK_DIR}/services.json" > "$tmp" && mv "$tmp" "${STACK_DIR}/services.json"
  fi
}

# Funzione per disabilitare un servizio nel file JSON
disableService() {
  local service=$1
  if [[ -f "${STACK_DIR}/services.json" ]]; then
    # Usa jq per impostare il valore del servizio a false
    tmp=$(mktemp)
    jq ".[\"$service\"] = false" "${STACK_DIR}/services.json" > "$tmp" && mv "$tmp" "${STACK_DIR}/services.json"
  fi
}
