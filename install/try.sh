export AMR_HOME=$( dirname $( dirname $( realpath ${BASH_SOURCE[0]} ) ) )
export PATH=$AMR_HOME:$AMR_HOME/main:$PATH
echo 'AMR_HOME is '$AMR_HOME
