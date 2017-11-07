#!/bin/bash

CUR_PWD=$(cd `dirname $0`; pwd)

# 必须是完整路径
ln -s ${CUR_PWD}/../scaffolds ${CUR_PWD}/../../tlzyh.github.io/scaffolds
ln -s ${CUR_PWD}/../source ${CUR_PWD}/../../tlzyh.github.io/source
ln -s ${CUR_PWD}/../themes ${CUR_PWD}/../../tlzyh.github.io/themes
ln -s ${CUR_PWD}/../_config.yml ${CUR_PWD}/../../tlzyh.github.io/_config.yml

