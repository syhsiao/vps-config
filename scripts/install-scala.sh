#!/bin/bash

# --- Install Scala Toolchain (Coursier) ---
curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > cs
chmod +x cs
./cs setup --yes --jvm 21
/cs install metals
mv cs /usr/local/bin/