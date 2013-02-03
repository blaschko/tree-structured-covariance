#!/bin/bash

# Author: Matthew Blaschko - matthew.blaschko@inria.fr
# copyright (c) 2013
# downloads Oxford Flowers dataset into correct directory
# see dataset webpage for more information and citations
#    http://www.robots.ox.ac.uk/~vgg/data/flowers/

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# Written (W) 2012-2013 Matthew Blaschko

mkdir OxfordFlowers
cd OxfordFlowers; wget http://www.robots.ox.ac.uk/~vgg/data/flowers/17/distancematrices17gcfeat06.mat; cd ..
cd OxfordFlowers; wget http://www.robots.ox.ac.uk/~vgg/data/flowers/17/distancematrices17itfeat08.mat; cd ..

