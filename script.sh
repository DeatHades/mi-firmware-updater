#!/bin/bash
echo Exporting variables:
miuidate=$(curl -s http://en.miui.com/forum.php | grep http://en.miui.com/download.html | grep -o '[0-9]*[.][0-9]*[.][0-9]*') && echo "Latest miui update is $miuidate"
site=http://bigota.d.miui.com/$miuidate/
echo Fetching updates:
while read device; do
id=$(echo $device | cut -d , -f1)
name=$(echo $device | cut -d , -f2)
{
echo Device: $(cut -d _ -f1 <<< $name) ; echo id: $id
curl -s http://en.miui.com/download-$id.html | grep miui_$name$miuidate | cut -d '"' -f6 | cut -d '"' -f1
} >> data
done <devices
cat data | grep -E "(http|https)://[a-zA-Z0-9./?=-]*" > links
echo Starting:
wget -qq --progress=bar https://github.com/xiaomi-firmware-updater/xiaomi-flashable-firmware-creator/raw/master/create_flashable_firmware.sh && chmod +x create_flashable_firmware.sh
roms=$(cat links | cut -d "/" -f5 | cut -d '"' -f1)
for link in $(echo $roms); do
echo Downloading $link; wget -qq --progress=bar $site$link
./create_flashable_firmware.sh $link
rm $link; done
echo Moving Files:
mkdir Global; mkdir China
for zip in `find -name "*Global*"`; do mv $zip Global/; done
for zip in *.zip; do mv $zip China/; done
echo Uploading:
cd Global; for file in *.zip; do product=$(echo $file | cut -d _ -f3); wput $file ftp://$basketbuilduser:$basketbuildpass@basketbuild.com//Xiaomi-Firmware/Developer/$miuidate/Global/$product/ ; done
for file in *.zip; do product=$(echo $file | cut -d _ -f3); wput $file ftp://$afhuser:$afhpass@uploads.androidfilehost.com//Xiaomi-Firmware/Developer/$miuidate/Global/$product/ ; done
cd ../China; for file in *.zip; do product=$(echo $file | cut -d _ -f3); wput $file ftp://$basketbuilduser:$basketbuildpass@basketbuild.com//Xiaomi-Firmware/Developer/$miuidate/China/$product/ ; done
for file in *.zip; do product=$(echo $file | cut -d _ -f3); wput $file ftp://$afhuser:$afhpass@uploads.androidfilehost.com//Xiaomi-Firmware/Developer/$miuidate/China/$product/ ; done
