#!/usr/bin/env bash

stage=$1

rm -f ${stage}-manifest.json
rm -f ${stage}.checksum
packer build -force -only=${stage}.qemu.* -on-error=ask template.pkr.hcl
