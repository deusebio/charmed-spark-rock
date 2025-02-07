#!/bin/bash

# This needs to be a separate file as newgrp will not have effect from setup_environment.sh

echo "Using addons: $MICROK8S_ADDONS"
sudo microk8s enable storage $MICROK8S_ADDONS
sudo microk8s kubectl rollout status deployment/hostpath-provisioner -n kube-system

# Wait for gpu operator components to be ready
while ! sudo microk8s.kubectl logs -n gpu-operator-resources -l app=nvidia-operator-validator | grep "all validations are successful"
do
    echo "--------------------------------------------------------------------------------------------------------------------"
    echo "waiting for validations"
    sudo microk8s.kubectl get pods -A
    sudo microk8s.kubectl logs -n kube-system -l k8s-app=hostpath-provisioner
    sudo microk8s.kubectl describe pod -n gpu-operator-resources nvidia-operator-validator
    sleep 60

    echo "--------------------------------------------------------------------------------------------------------------------"
done

# Setup config
sudo microk8s config > ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config
sudo chmod 600 ~/.kube/config