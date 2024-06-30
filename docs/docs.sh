#!/bin/bash
haxe docs/docs.hxml
haxelib run dox -i docs -o pages --title "FNF Neutron Engine Documentation" -D source-path "https://github.com/FNF-Neutron-Dev/FNF-Neutron-Engine/tree/main/source" -in "backend" -in "frontend" -in "mobile"
