# QMC Hands-on Summer Workshop

[!Champ logo](./images/Champ.png)]

### CHAMP
The Cornell-Holland Ab-initio Materials Package (CHAMP) is a quantum Monte Carlo suite of programs for electronic structure calculations of atomic and molecular systems.

### Requirements
1. cmake >= 3.20
2. gfortran/gcc >= 9.3.0 or Intel Fortran 2020 onward / Intel OneAPI
3. BLAS/LAPACK (OpenBLAS) or Intel MKL
4. openMPI >= 3.0 or Intel MPI
5. [Optional] TREXIO library >= 2.0.0

**Installation of required libraries/packages**

## Install or load cmake
`sudo apt-get install -y cmake`

OR

Download and extract the latest cmake for the precompiled binary
```shell
wget https://github.com/Kitware/CMake/releases/download/v3.24.0-rc1/cmake-3.24.0-rc1-linux-x86_64.tar.gz
tar -xzvf cmake-3.24.0-rc1-linux-x86_64.tar.gz
export PATH=cmake-3.24.0-rc1-linux-x86_64/bin:$PATH
```


### 1. Installation using Intel oneAPI compilers

## Installation without sudo access

Download Intel oneAPI basekit and HPCkit for free from

`wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18673/l_BaseKit_p_2022.2.0.262.sh`

`chmod a+x ./l_BaseKit_p_2022.2.0.262.sh`

`sh ./l_BaseKit_p_2022.2.0.262.sh`

`wget https://registrationcenter-download.intel.com/akdlm/irc_nas/18679/l_HPCKit_p_2022.2.0.191.sh`


`chmod a+x ./l_HPCKit_p_2022.2.0.191.sh`

`sh ./l_HPCKit_p_2022.2.0.191.sh`

After installation export the path to your bashrc.

## prerequisites for Intel oneAPI with sudo access
```shell
        wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
        sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
        rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
        sudo add-apt-repository "deb https://apt.repos.intel.com/oneapi all main"
        sudo apt-get update
```

## Install the components

```shell
    sudo apt-get install -y intel-oneapi-common-vars
    sudo apt-get install -y intel-oneapi-compiler-fortran-2021.3.0
    sudo apt-get install -y intel-oneapi-mkl-2021.3.0
    sudo apt-get install -y intel-oneapi-mkl-devel-2021.3.0
    sudo apt-get install -y intel-oneapi-mpi-2021.3.0
    sudo apt-get install -y intel-oneapi-mpi-devel-2021.3.0
```
## Compile script for CHAMP using Intel

### Intel MKL libraries
```shell
cmake -S. -Bbuild -DCMAKE_Fortran_COMPILER=mpiifort -DBLAS_LIBRARIES="-qmkl=parallel"
cmake --build build -j 8
```


### 2. Installation using GNU Compiler

## Install or load cmake
`sudo apt-get install -y cmake`

*Make sure that the installed version of cmake is higher than 3.20*

*Make sure that the installed version of gfortran/mpif90 is higher than 9.3.0*

## Install or load compilers
```shell
sudo apt install -y gfortran
sudo apt-get install -y gcc
sudo apt install -y openmpi-bin
sudo apt install -y libopenmpi-dev
```

## install or load BLAS/LAPACK
```shell
sudo apt install -y libblacs-mpi-dev
sudo apt install -y liblapack-dev
```
## Compile script for CHAMP

Get the stable version of CHAMP v.2.1.1

`https://github.com/filippi-claudia/champ/releases/tag/v2.1.1`


**Make sure that the BLAS installation is proper. Otherwise, the code might give erroneous results at runtime.**

```bash
cmake -H. -B build -DCMAKE_Fortran_COMPILER=/usr/bin/mpif90 -DBLA_VENDOR=OpenBLAS
cmake --build build
```


# Setup of input files (files already present)

The tutorial folder is located at:

`/lustre/home/filippi/Tutorial-QMC-School`

There are two folders inside
(1) `example01_H2O_HF`
(2) `example01_H2O_DFT`

Each example directory will contain a setup folder, where you can generate the necessary input files for CHAMP from a single trexio file (in HDF5 format)

The scripts for conversion are also included in the folder.

```shell
cd 01_champ_tools/example01_H2O_HF/setup
```

Check the contents of the conversion script

```shell
#!/bin/bash
python ../../trex2champ.py --trex "trexio_H2O_HF.hdf5" \
                           --motype  "RHF" \
                           --backend "HDF5" \
                           --basis_prefix "GRID" \
                           --lcao \
                           --geom \
                           --basis \
                           --ecp \
                           --det

```

Execute this script to generate the files:

```shell
./script_water.sh
```

Move or copy the following files into the pool folder

```shell
ls 01_champ_tools/example01_H2O_HF/pool

champ_v2_trexio_H2O_HF_geom.xyz
champ_v2_trexio_H2O_HF_with_g.bfinfo
ECP.gauss_ecp.dat.H
ECP.gauss_ecp.dat.O
GRID.basis.H
GRID.basis.O
```

The remaining files should be kept in the `01_champ_tools/example01_H2O_HF` directory.

```shell
ls 01_champ_tools/example01_H2O_HF/

champ_v2_trexio_H2O_HF_orbitals.lcao
champ_v2_TREXIO_trexio_H2O_HF_determinants.det
jastrow.jas
run_champ.sh
vmc_h2o_hf.inp


Folders::
pool
setup
```


Example 01 : H20 with HF

The input file `vmc_h2o_hf.inp` looks like:
```
%module general
    title           'H2O HF calculation'
    pool            './pool/'
    pseudopot       ECP
    basis           GRID
    mode            'vmc_one_mpi1'
%endmodule


load molecule        $pool/champ_v2_trexio_H2O_HF_geom.xyz

load basis_num_info  $pool/champ_v2_trexio_H2O_HF_with_g.bfinfo
load orbitals        champ_v2_trexio_H2O_HF_orbitals.lcao
load determinants    champ_v2_TREXIO_trexio_H2O_HF_determinants.det
load jastrow         jastrow.jas

%module electrons
    nup           4
    nelec         8
%endmodule


%module blocking_vmc
    vmc_nstep     20
    vmc_nblk      20000
    vmc_nblkeq    1
    vmc_nconf_new 0
%endmodule

```

The included jastrow file is

```shell
jastrow_parameter   1
  0  1  0           norda,nordb,nordc
   0.60000000   0.00000000     scalek,a21
   0.00000000   0.00000000   (a(iparmj),iparmj=1,nparma)
   0.00000000   0.00000000   (a(iparmj),iparmj=1,nparma)
   0.00000000   1.00000000   (b(iparmj),iparmj=1,nparmb)
 (c(iparmj),iparmj=1,nparmc)
 (c(iparmj),iparmj=1,nparmc)
end
```


# Run the example calculations:

Use the provided script

```shell
mpirun -np 8 /lustre/home/filippi/champ-2.1.0/bin/vmc.mov1  -i vmc_h2o_hf.inp  -o vmc_h2o_hf.out  -e error
```
