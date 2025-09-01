#!/usr/bin/env python3
import random
import subprocess
import sys

def get_pods(namespace="demo"):
    """Return a list of pod names in the given namespace."""
    try:
        result = subprocess.check_output(
            ["kubectl", "get", "pods", "-n", namespace, "-o", "name"],
            text=True
        )
        return [line.strip().split("/")[-1] for line in result.splitlines() if line.strip()]
    except subprocess.CalledProcessError as e:
        print(f"Error fetching pods: {e}", file=sys.stderr)
        return []

def delete_pod(pod, namespace="demo"):
    """Delete a specific pod."""
    try:
        subprocess.check_call(
            ["kubectl", "delete", "pod", pod, "-n", namespace, "--grace-period=0", "--force"]
        )
        print(f"Deleted pod: {pod}")
    except subprocess.CalledProcessError as e:
        print(f"Error deleting pod {pod}: {e}", file=sys.stderr)

def main():
    pods = get_pods()
    if not pods:
        print("No pods found in demo namespace.")
        return
    pod = random.choice(pods)
    delete_pod(pod)

if __name__ == "__main__":
    main()
