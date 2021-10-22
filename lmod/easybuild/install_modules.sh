#!/bin/bash

# Go to easybuild/easyconfigs folder:
cd /opt/apps/easybuild/repos/easybuild-easyconfigs/easybuild/easyconfigs

# Install GCC (c, c++, fortran compilers)
eb -r g/GCC/GCC-10.3.0.eb
# eb -r g/GCC/GCC-1*
# eb -r g/GCC/GCC-9*
# eb -r g/GCC/GCC-8*


# Install FSL 6.0.3 (neuroimaging software to analyze MRI data)
# eb -r f/FSL/FSL-6.0.3-foss-2019b-Python-3.7.4.eb
# eb -r f/FSL/FSL-6.0.2*
# eb -r f/FSLeyes/FSLeyes-*

# Install FreeSurfer 7.1.1 (neuroimaging software to analyze MRI data)
# eb -r f/FreeSurfer/FreeSurfer-7.1.1-centos* --download-timeout=1000


# # Install OpenMPI (High Performance Message Passing Library)
eb -r o/OpenMPI/OpenMPI-4.1.1-GCC-10.3.0.eb

# # Install OpenBLAS (Basic Linear Algebra Subprograms)
# eb -r o/OpenBLAS/OpenBLAS-0.3.17-GCC-10.3.0.eb
# eb -r o/OpenBLAS/OpenBLAS-0.3.18-GCC-11.2.0.eb


# # Install OpenMolcas (quantum chemistry software package)
# eb -r o/OpenMolcas/OpenMolcas-21.06-intel-2021a.eb
# eb -r o/OpenMolcas/OpenMolcas-20.10-intel-2020a-Python-3.8.2.eb
# eb -r o/ORCA/ORCA-4.1.0-OpenMPI-3.1.3.eb
# eb -r o/ORCA/ORCA-5.0.1-gompi-2021a.eb



# # Install Data Science libs
# eb -r p/pandas/pandas-1.1.2-foss-2020a-Python-3.8.2.eb
# eb -r n/numpy/numpy-1.13.1-intel-2017a-Python-3.6.1.eb
# eb -r s/scikit-learn/scikit-learn-0.24.2-foss-2021a.eb
# eb -r s/scikit-learn/scikit-learn-0.23.2-fosscuda-2020b
# eb -r s/scikit-learn/scikit-learn-0.23.2-intel-2020b.eb

# eb -r s/Spark/Spark-3.1.1-fosscuda-2020b.eb
# eb -r s/Spark/Spark-3.1.1-foss-2020a-Python-3.8.2.eb
# eb -r s/Spark/Spark-2.4.5-intel-2019b-Python-3.7.4-Java-1.8.eb

# eb -r o/OpenRefine/OpenRefine-3.4.1-Java-11.eb
# eb -r r/RDFlib/RDFlib-5.0.0-GCCcore-10.2.0.eb
# eb -r t/Tika/Tika-1.16.eb



# Install Python 2.7, 3.7, 3.8, 3.9
# eb -r p/Python/Python-3.8.6-GCCcore-10.2.0.eb
# eb -r p/Python/Python-2.7.18-GCCcore-10.2.0*
# eb -r p/Python/Python-3.6.6*
# eb -r p/Python/Python-3.7*
# eb -r p/Python/Python-3.8*
# eb -r p/Python/Python-3.9*


# Install Java
# eb -r j/Java/Java-1.8.eb
# eb -r j/Java/Java-1.9*
# eb -r j/Java/Java-11*
# eb -r j/Java/Java-13*
# eb -r j/Java/Java-16*

# eb -r s/sbt/sbt-1.3.13-Java-1.8.eb


# Install R and Julia
# eb -r r/R-bundle-Bioconductor/R-bundle-Bioconductor-3.13-foss-2021a-R-4.1.0.eb
# eb -r j/Julia/Julia-1.6.2-linux-x86_64.eb


# # Install NodeJS
# eb -r n/nodejs/nodejs-14.17.2-GCCcore-10.3.0


# # Install Databases
# eb -r m/MariaDB/MariaDB-10.6.4-GCC-10.3.0.eb
# eb -r m/MariaDB-connector-c/MariaDB-connector-c-3.2.2-GCCcore-10.3.0.eb
# eb -r p/PostgreSQL/PostgreSQL-13.4-GCCcore-11.2.0.eb
# eb -r p/psycopg2/psycopg2-2.8.6-GCCcore-9.3.0-Python-3.8.2.eb

# # Install workspaces
# eb -r j/JupyterLab/JupyterLab-3.0.16-GCCcore-10.3.0.eb
# eb -r j/JupyterHub/JupyterHub-1.4.1-GCCcore-10.3.0.eb
# eb -r c/code-server/code-server-3.7.3.eb

# Install Git
# eb -r g/git/git-2.32.0-GCCcore-10.3.0-nodocs


# # Install workflow modules
# eb -r n/Nextflow/Nextflow-21.08.0.eb
# eb -r d/dask/dask-2021.2.0-intel-2020b.eb

# # Install GPU modules
# eb -r c/CUDA/CUDA-11.4.1.eb
# eb -r c/cuDNN/cuDNN-8.2.2.26-CUDA-11.4.1.eb
# eb -r t/TensorFlow/TensorFlow-2.6.0-foss-2021a.eb
