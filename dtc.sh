#!/bin/sh -e

check_dpkg () {
	LC_ALL=C dpkg --list | awk '{print $2}' | grep "^${pkg}" >/dev/null || deb_pkgs="${deb_pkgs}${pkg} "
}

unset deb_pkgs
pkg="bison"
check_dpkg
pkg="build-essential"
check_dpkg
pkg="flex"
check_dpkg
pkg="git-core"
check_dpkg

if [ "${deb_pkgs}" ] ; then
	echo "Installing: ${deb_pkgs}"
	sudo apt-get update
	sudo apt-get -y install ${deb_pkgs}
	sudo apt-get clean
fi

#git_sha="origin/master"
#git_sha="27cdc1b16f86f970c3c049795d4e71ad531cca3d"
#git_sha="fdc7387845420168ee5dd479fbe4391ff93bddab"
git_sha="65cc4d2748a2c2e6f27f1cf39e07a5dbabd80ebf"
project="dtc"
server="git://git.kernel.org/pub/scm/linux/kernel/git/jdl"

if [ ! -f ${HOME}/git/${project}/.git/config ] ; then
	git clone ${server}/${project}.git ${HOME}/git/${project}/
fi

if [ ! -f ${HOME}/git/${project}/.git/config ] ; then
	rm -rf ${HOME}/git/${project}/ || true
	echo "error: git failure, try re-runing"
	exit
fi

unset old_address
old_address=$(cat ${HOME}/git/${project}/.git/config | grep "jdl.com" || true)
if [ ! "x${old_address}" = "x" ] ; then
	sed -i -e 's:git.jdl.com/software:git.kernel.org/pub/scm/linux/kernel/git/jdl:g' ${HOME}/git/${project}/.git/config
fi

cd ${HOME}/git/${project}/
make clean
git checkout master -f
git pull || true

test_for_branch=$(git branch --list ${git_sha}-build)
if [ "x${test_for_branch}" != "x" ] ; then
	git branch ${git_sha}-build -D
fi

git checkout ${git_sha} -b ${git_sha}-build
git pull git://github.com/RobertCNelson/dtc.git dtc-fixup-65cc4d2

make clean
make PREFIX=/usr/local/ CC=gcc CROSS_COMPILE= all
echo "Installing into: /usr/local/bin/"
sudo make PREFIX=/usr/local/ install