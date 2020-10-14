#!/bin/bash
set -e

repo="orange-cloudfoundry/mdproxy4cs"
version="1.0.2"
name="mdproxy4cs-${version}-linux-amd64"
file="${name}.tar.gz"
dir=$(mktemp -d)

cd ${dir}

curl -L https://github.com/${repo}/releases/download/v${version}/${file} --output ${file}
tar xzf ${file}
ls -la ${name}

mkdir -p /usr/share/mdproxy4cs/

cp ${name}/mdproxy4cs                /usr/bin/
cp ${name}/assets/pre-start.sh       /usr/share/mdproxy4cs/pre-start.sh
cp ${name}/assets/mdproxy4cs.service /usr/share/mdproxy4cs/mdproxy4cs.service
cp ${name}/assets/default            /etc/default/mdproxy4cs

systemctl enable /usr/share/mdproxy4cs/mdproxy4cs.service

rm -rf ${dir}
