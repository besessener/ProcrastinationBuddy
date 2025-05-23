#!/bin/bash

#set -e

case "$1" in
  start)
    if ! docker info > /dev/null 2>&1
    then
        echo "docker is not installed/running"
        exit 1
    fi

    echo "Starting docker containers..."
    docker compose pull
    docker compose up --build --force-recreate --detach

    echo "Waiting for Ollama to be ready..."
    until docker exec procrastinationbuddy-backend sh -c  'wget -qO- http://procrastinationbuddy-ollama:11434 | grep -q "Ollama is running"'; do
      echo -n "."
      sleep 1
    done

    echo "Downloading initial model (llama3:8b)..."
    docker exec procrastinationbuddy-backend sh -c "
      wget --post-data='{\"name\": \"llama3:8b\"}' --header='Content-Type: application/json' -qO- http://procrastinationbuddy-ollama:11434/api/pull
    "

    echo -e "\033[0;32m##################################\033[0m"
    echo -e "\033[0;32mAccess UI at http://localhost:8501\033[0m"
    echo -e "\033[0;32m##################################\033[0m"
    ;;

  stop)
    echo "Stopping docker containers..."
    docker compose down
    ;;

  test)
    echo "Running tests..."

    echo "Running API-Tests..."
    pushd tests/api
    ./npmw ci
    output=$(./npmw run bruno) # Bruno returns 0 even if it fails under certain conditions (e.g. not able to resolve hosts)
    echo "$output"
    if echo "$output" | grep -qE "Requests:.*([1-9][0-9]*\s+failed|[1-9][0-9]*\s+error)"; then
      echo "❌ Bruno tests failed: Requests had failures or errors"
      exit 1
    fi
    echo "✅ Bruno tests passed"
    popd

    echo "Running E2E-Tests..."
    pushd tests/e2e
    ./npmw ci
    ./npmw run install
    ./npmw run test
    popd
    ;;

  *)
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  start   Start the services, install models and wait to be ready"
    echo "  stop    Stop all running services"
    echo "  test    Run all (API, E2E) tests"
    exit 1
    ;;
esac
