#!/usr/bin/env python
# -*- coding: utf-8 -*-

import subprocess

import toml

# Lese die pyproject.toml Datei
with open("pyproject.toml", "r") as file:
    pyproject = toml.load(file)

    # Extract direct requirements
    dependencies = pyproject.get("tool", {}).get("poetry", {}).get("dependencies", {})
    dev_dependencies = pyproject.get("tool").get("poetry").get("group").get("dev", {}).get("dependencies", {})

    direct_dependencies = set(dependencies.keys()).union(set(dev_dependencies.keys()))

    # Run 'poetry show --outdated' and capture the result
    result = subprocess.run(["poetry", "show", "--outdated"], capture_output=True, text=True)

    # Filter against the above list
    outdated_packages = result.stdout.splitlines()
    filtered_outdated = [line for line in outdated_packages if line.split()[0] in direct_dependencies]

    # Show em
    if not filtered_outdated:
        print("No outdated packages found.")
    else:
        print("Available updates:")
        for package in filtered_outdated:
            print(package)
