#!/bin/bash -x

dist="bookworm"
repacked_path="build/repacked"
mkdir -p ${repacked_path}
mirror_path="/var/spool/apt-mirror/mirror/download.proxmox.com/debian/devel/dists/${dist}/main/binary-amd64/"
#newpkg
ls  $mirror_path |grep librust > build/newpkg
#oldpkg
ls $repacked_path > build/oldpkg
#oldpkg-arm64.deb to amd64.deb
sed -i "s/arm64/amd64/g" build/oldpkg 
#diff
diff -u build/oldpkg build/newpkg |grep +librust|sed "s/^.//g" > build/needpkg
echo "$(date "+%Y/%m/%d %H:%M:%S") Needpkgs:" 
if test -s build/needpkg
then
cat build/needpkg
else
echo "all pkg is up date"
exit 0
fi

for packlist in `cat build/needpkg`;do
extract_path="build/librust/$packlist/extract" 
mkdir $extract_path/DEBIAN -p
dpkg -X $mirror_path$packlist $extract_path > /dev/null
dpkg -e $mirror_path$packlist $extract_path/DEBIAN > /dev/null
sed -i "s/amd64/arm64/g" $extract_path/DEBIAN/control > /dev/null
dpkg-deb -Zxz -b  $extract_path  $repacked_path  > /dev/null
echo "$(date "+%Y/%m/%d %H:%M:%S") repacked $packlist done" >> build/repacked.log
done
echo "$(date "+%Y/%m/%d %H:%M:%S") all package repacked  done" 
echo "$(date "+%Y/%m/%d %H:%M:%S") all package repacked  done" >> build/repacked.log
